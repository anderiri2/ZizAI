#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para auditar, corregir y completar las fotografías del catálogo de ZizAI:
1. Elimina fotos duplicadas dentro de una misma especie (_1.jpg == _2.jpg).
2. Elimina fotos compartidas entre distintas especies (como cantharellus_cibarius_2 /
   cantharellus_subpruinosus_1 y hydnum_repandum_2 / hydnum_rufescens_1) y fotos
   secundarias obtenidas por error de otro taxón.
3. Descarga fotografías verificadas del taxón exacto (vía iNaturalist /v1/taxa/{id}
   taxon_photos, observaciones research-grade de iNaturalist y Wikipedia REST API)
   garantizando que ninguna imagen se repita ni por hash MD5 ni por hash perceptual
   (dHash / RGB diff) en todo el catálogo.
"""

import hashlib
import io
import json
import os
import re
import ssl
import threading
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from PIL import Image, ImageChops, ImageStat

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES_DIR = os.path.join(ROOT_DIR, "assets", "images", "mushrooms")
CATALOG_JSON_PATH = os.path.join(ROOT_DIR, "assets", "data", "mushrooms_catalog.json")

SSL_CTX = ssl.create_default_context()
SSL_CTX.check_hostname = False
SSL_CTX.verify_mode = ssl.CERT_NONE

HEADERS = {
    "User-Agent": "ZizAIAppCatalogBuilder/1.1 (https://zizai.app; contact@zizai.app)"
}


def clean_binomial(scientific_name: str) -> str:
    base = re.sub(r"\s*\(.*?\)", "", scientific_name).strip()
    parts = base.split()
    return " ".join(parts[:2]) if len(parts) >= 2 else base


def get_candidate_names(scientific_name: str) -> list[str]:
    names = [clean_binomial(scientific_name)]
    m = re.search(r"\((.*?)\)", scientific_name)
    if m:
        for alt in m.group(1).split("/"):
            alt_clean = alt.strip()
            if alt_clean and alt_clean not in names:
                names.append(alt_clean)
    return names


def compute_image_signature(data: bytes):
    """Devuelve (md5_hex, dhash_bits, rgb_thumb_32x32) o None si no es imagen válida."""
    if not data or len(data) <= 2048:
        return None
    try:
        with Image.open(io.BytesIO(data)) as im:
            im.load()
            md5_hex = hashlib.md5(data).hexdigest()
            gray = im.convert("L").resize((9, 8), Image.Resampling.LANCZOS)
            dhash_bits = [
                gray.getpixel((c, r)) > gray.getpixel((c + 1, r))
                for r in range(8)
                for c in range(8)
            ]
            rgb_thumb = im.convert("RGB").resize((32, 32), Image.Resampling.LANCZOS)
            return (md5_hex, dhash_bits, rgb_thumb)
    except Exception:
        return None


def are_signatures_duplicate(sig1, sig2) -> bool:
    """Comprueba si dos imágenes son idénticas o versiones redimensionadas/recortadas de la misma foto."""
    if sig1 is None or sig2 is None:
        return False
    md5_1, dhash_1, thumb_1 = sig1
    md5_2, dhash_2, thumb_2 = sig2
    if md5_1 == md5_2:
        return True
    hamming = sum(b1 != b2 for b1, b2 in zip(dhash_1, dhash_2))
    diff = ImageChops.difference(thumb_1, thumb_2)
    mean_rgb_diff = sum(ImageStat.Stat(diff).mean) / 3.0
    if hamming <= 8 or mean_rgb_diff < 16.0:
        return True
    if hamming <= 12 and mean_rgb_diff < 22.0:
        return True
    return False


def fetch_json(url: str, timeout: int = 12):
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, context=SSL_CTX, timeout=timeout) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(1.2 * (attempt + 1))
                continue
            raise
        except Exception:
            if attempt < 2:
                time.sleep(0.5)
                continue
            raise
    return {}


def download_bytes(url: str, timeout: int = 15) -> bytes | None:
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, context=SSL_CTX, timeout=timeout) as resp:
                data = resp.read()
                if len(data) > 2048:
                    return data
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(1.2 * (attempt + 1))
                continue
            return None
        except Exception:
            if attempt < 2:
                time.sleep(0.5)
                continue
    return None


def get_verified_inat_urls(scientific_name: str) -> list[str]:
    """
    Obtiene todas las URLs verificadas para el taxón exacto en iNaturalist:
    - Busca primero el taxon_id cuyo nombre coincida exactamente con alguno de los nombres candidatos.
    - Consulta /v1/taxa/{taxon_id} para obtener taxon_photos (hasta 10 fotos curadas del taxón).
    - También consulta observaciones research-grade como respaldo adicional.
    """
    candidates = get_candidate_names(scientific_name)
    candidates_lower = {c.lower() for c in candidates}
    urls = []
    seen_photo_ids = set()

    matched_taxon_ids = []
    for q in candidates:
        try:
            encoded = urllib.parse.quote(q)
            search_url = f"https://api.inaturalist.org/v1/taxa?q={encoded}&is_active=true&per_page=10"
            data = fetch_json(search_url)
            for taxon in data.get("results", []):
                t_name = taxon.get("name", "").strip().lower()
                m_term = taxon.get("matched_term", "").strip().lower()
                rank = taxon.get("rank", "")
                if rank in ("species", "subspecies", "variety", "complex", "hybrid"):
                    if t_name in candidates_lower or m_term in candidates_lower:
                        tid = taxon.get("id")
                        if tid and tid not in matched_taxon_ids:
                            matched_taxon_ids.append(tid)
        except Exception:
            continue

    for tid in matched_taxon_ids:
        try:
            detail_url = f"https://api.inaturalist.org/v1/taxa/{tid}"
            detail_data = fetch_json(detail_url)
            for taxon in detail_data.get("results", []):
                for tp in taxon.get("taxon_photos", []):
                    photo = tp.get("photo", {})
                    pid = str(photo.get("id") or "")
                    murl = photo.get("medium_url") or photo.get("large_url")
                    if murl and pid not in seen_photo_ids:
                        if pid:
                            seen_photo_ids.add(pid)
                        if murl not in urls:
                            urls.append(murl)
        except Exception:
            continue

    if len(urls) < 4 and matched_taxon_ids:
        tid = matched_taxon_ids[0]
        try:
            obs_url = (
                f"https://api.inaturalist.org/v1/observations?taxon_id={tid}"
                f"&quality_grade=research&photos=true&per_page=6&order_by=votes"
            )
            obs_data = fetch_json(obs_url)
            for obs in obs_data.get("results", []):
                for photo in obs.get("photos", []):
                    pid = str(photo.get("id") or "")
                    sq_url = photo.get("url", "")
                    murl = sq_url.replace("square.", "medium.") if sq_url else ""
                    if murl and pid not in seen_photo_ids:
                        if pid:
                            seen_photo_ids.add(pid)
                        if murl not in urls:
                            urls.append(murl)
        except Exception:
            pass

    return urls


def get_verified_wikipedia_urls(scientific_name: str) -> list[str]:
    """
    Obtiene imágenes desde Wikipedia REST API y Wikimedia Commons verificando que
    pertenezcan a la especie exacta.
    """
    candidates = get_candidate_names(scientific_name)
    candidates_lower = {c.lower() for c in candidates}
    epithets = {c.split()[1].lower() for c in candidates if len(c.split()) >= 2}
    urls = []
    seen_filenames = set()

    for name in candidates:
        title = urllib.parse.quote(name.replace(" ", "_"))
        for lang in ("en", "es"):
            try:
                summary_url = f"https://{lang}.wikipedia.org/api/rest_v1/page/summary/{title}"
                data = fetch_json(summary_url, timeout=8)
                if data.get("type") == "disambiguation":
                    continue
                page_title = data.get("title", "").strip().lower()
                extract = data.get("extract", "").lower()
                if page_title not in candidates_lower:
                    if not any(ep in page_title or ep in extract for ep in epithets):
                        continue
                thumb = data.get("thumbnail", {}).get("source")
                if thumb:
                    fn_match = re.search(r"/thumb/[^/]+/[^/]+/([^/]+)/", thumb)
                    canon_fn = urllib.parse.unquote(fn_match.group(1)).lower() if fn_match else thumb
                    if canon_fn not in seen_filenames:
                        seen_filenames.add(canon_fn)
                        urls.append(thumb)
            except Exception:
                continue

        # Búsqueda exacta en Wikimedia Commons por frase exacta del nombre binomial
        try:
            q = urllib.parse.quote(f'"{name}"')
            commons_url = (
                f"https://commons.wikimedia.org/w/api.php?action=query&generator=search"
                f"&gsrsearch=filetype:bitmap%20{q}&gsrlimit=6&prop=imageinfo"
                f"&iiprop=url&iiurlwidth=500&format=json"
            )
            cdata = fetch_json(commons_url, timeout=10)
            pages = cdata.get("query", {}).get("pages", {})
            for page in pages.values():
                ptitle = page.get("title", "").lower()
                if not any(ep in ptitle for ep in epithets):
                    continue
                if any(bad in ptitle for bad in ("spore", "micro", "map", "dist", "icon", "stamp", "drawing", "illus")):
                    continue
                for ii in page.get("imageinfo", []):
                    turl = ii.get("thumburl") or ii.get("url")
                    if turl and turl.lower().endswith((".jpg", ".jpeg", ".png")):
                        canon_fn = ptitle.replace("file:", "").strip()
                        if canon_fn not in seen_filenames:
                            seen_filenames.add(canon_fn)
                            urls.append(turl)
        except Exception:
            continue

    return urls


def fetch_candidates_for_species(sp: dict) -> tuple[str, list[str]]:
    sid = sp["id"]
    sname = sp["scientificName"]
    wiki_urls = get_verified_wikipedia_urls(sname)
    inat_urls = get_verified_inat_urls(sname)
    combined = []
    for u in inat_urls + wiki_urls:
        if u not in combined:
            combined.append(u)
    return sid, combined


def main():
    with open(CATALOG_JSON_PATH, "r", encoding="utf-8") as f:
        catalog = json.load(f)

    by_id = {sp["id"]: sp for sp in catalog}
    print(f"Auditando catálogo de {len(catalog)} especies...")

    file_sigs = {}
    md5_to_files = {}
    for fn in sorted(os.listdir(IMAGES_DIR)):
        if not fn.endswith(".jpg"):
            continue
        p = os.path.join(IMAGES_DIR, fn)
        with open(p, "rb") as f:
            sig = compute_image_signature(f.read())
        if sig:
            file_sigs[fn] = sig
            md5_to_files.setdefault(sig[0], []).append(fn)

    same_species_dup_ids = set()
    cross_species_dup_files = set()
    single_image_species = set()

    for md5_val, fns in md5_to_files.items():
        if len(fns) > 1:
            sp_ids = {fn.rsplit("_", 1)[0] for fn in fns}
            if len(sp_ids) == 1:
                same_species_dup_ids.add(next(iter(sp_ids)))
            else:
                for fn in fns:
                    cross_species_dup_files.add(fn)

    for sp in catalog:
        sid = sp["id"]
        imgs = sp.get("images", [])
        if len(imgs) < 2:
            single_image_species.add(sid)

    # También incluimos clitocybe_nebularis (cuya _2.jpg venía de results[1] de otro taxón)
    force_replace_slot2 = {"clitocybe_nebularis", "cantharellus_cibarius", "hydnum_repandum"}

    print(f"- Especies con 2 fotos idénticas (_1 == _2): {len(same_species_dup_ids)}")
    print(f"- Archivos compartidos entre especies distintas: {sorted(cross_species_dup_files)}")
    print(f"- Especies con solo 1 foto actualmente: {len(single_image_species)}")

    accepted_sigs = []

    def is_globally_unique(cand_sig) -> bool:
        if cand_sig is None:
            return False
        for _, _, existing_sig in accepted_sigs:
            if are_signatures_duplicate(cand_sig, existing_sig):
                return False
        return True

    species_to_fetch_slot1 = []
    species_to_fetch_slot2 = []

    for sp in catalog:
        sid = sp["id"]
        fn1 = f"{sid}_1.jpg"
        fn2 = f"{sid}_2.jpg"
        sig1 = file_sigs.get(fn1)
        sig2 = file_sigs.get(fn2)

        if sig1 and is_globally_unique(sig1):
            accepted_sigs.append((sid, 1, sig1))
        else:
            species_to_fetch_slot1.append(sid)

        if (
            sig2
            and sid not in same_species_dup_ids
            and sid not in force_replace_slot2
            and fn2 not in cross_species_dup_files
            and is_globally_unique(sig2)
        ):
            accepted_sigs.append((sid, 2, sig2))
        else:
            species_to_fetch_slot2.append(sid)

    print(f"\nEspecies que requieren nueva foto _1.jpg: {len(species_to_fetch_slot1)}")
    print(f"Especies que requieren nueva foto _2.jpg: {len(species_to_fetch_slot2)}")

    targets = sorted(set(species_to_fetch_slot1 + species_to_fetch_slot2))
    print(f"Buscando URLs candidatas para {len(targets)} especies en paralelo...")

    candidates_by_sid = {}
    with ThreadPoolExecutor(max_workers=4) as pool:
        futures = {pool.submit(fetch_candidates_for_species, by_id[sid]): sid for sid in targets}
        done_count = 0
        for fut in as_completed(futures):
            sid = futures[fut]
            try:
                _, urls = fut.result()
                candidates_by_sid[sid] = urls
            except Exception as e:
                print(f"  Error buscando URLs para {sid}: {e}")
                candidates_by_sid[sid] = []
            done_count += 1
            if done_count % 15 == 0 or done_count == len(targets):
                print(f"  Búsqueda completada: {done_count}/{len(targets)}")

    print("Descargando y verificando unicidad global de imágenes...")
    for idx, sid in enumerate(targets, start=1):
        sp = by_id[sid]
        sname = sp["scientificName"]
        candidate_urls = candidates_by_sid.get(sid, [])
        slots_needed = []
        if sid in species_to_fetch_slot1:
            slots_needed.append(1)
        if sid in species_to_fetch_slot2:
            slots_needed.append(2)

        for slot in slots_needed:
            dest_path = os.path.join(IMAGES_DIR, f"{sid}_{slot}.jpg")
            if os.path.exists(dest_path):
                os.remove(dest_path)
            found = False
            for url in candidate_urls:
                raw = download_bytes(url)
                if not raw:
                    continue
                sig = compute_image_signature(raw)
                if sig and is_globally_unique(sig):
                    with open(dest_path, "wb") as out_f:
                        out_f.write(raw)
                    accepted_sigs.append((sid, slot, sig))
                    file_sigs[f"{sid}_{slot}.jpg"] = sig
                    found = True
                    break
            if not found:
                print(f"  [WARN] No se encontró candidata única para {sid}_{slot}.jpg ({sname})")

        if idx % 15 == 0 or idx == len(targets):
            print(f"  Descargas procesadas: {idx}/{len(targets)}")

    # Actualizar lista "images" en catalog preservando el resto de campos intactos
    for sp in catalog:
        sid = sp["id"]
        imgs = []
        for slot in (1, 2):
            rel = f"assets/images/mushrooms/{sid}_{slot}.jpg"
            abs_p = os.path.join(ROOT_DIR, rel)
            if os.path.exists(abs_p) and os.path.getsize(abs_p) > 2048:
                imgs.append(rel)
        if len(imgs) == 2:
            s1 = file_sigs.get(f"{sid}_1.jpg")
            s2 = file_sigs.get(f"{sid}_2.jpg")
            if are_signatures_duplicate(s1, s2):
                os.remove(os.path.join(ROOT_DIR, imgs[1]))
                imgs.pop(1)
        sp["images"] = imgs

    with open(CATALOG_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)
        f.write("\n")

    print("\nCatálogo actualizado correctamente.")


if __name__ == "__main__":
    main()
