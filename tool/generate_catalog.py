#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script generador del catálogo micológico de ZizAI (+125 especies de Euskadi y España).
- Combina y ordena alfabéticamente todas las especies.
- Verifica la integridad de todas las referencias cruzadas de confusiones.
- Descarga fotografías reales con licencia abierta desde Wikipedia / Wikimedia Commons / iNaturalist
  y las almacena localmente en assets/images/mushrooms/ para uso 100% offline en el monte,
  garantizando que no haya fotos repetidas en una misma especie ni fotos compartidas entre especies.
"""

import hashlib
import io
import json
import os
import re
import ssl
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from PIL import Image, ImageChops, ImageStat

from species_part1 import SPECIES_PART_1
from species_part2 import SPECIES_PART_2
from species_part3 import SPECIES_PART_3
from species_part4 import SPECIES_PART_4

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
    """Extrae el nombre binomial principal sin sinónimos entre paréntesis."""
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
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, context=SSL_CTX, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def download_bytes(url: str, timeout: int = 15) -> bytes | None:
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, context=SSL_CTX, timeout=timeout) as resp:
            data = resp.read()
            if len(data) > 2048:
                return data
    except Exception:
        pass
    return None


def get_wikipedia_photo_urls(scientific_name: str, max_photos: int = 4) -> list[str]:
    """Obtiene imágenes desde Wikipedia REST API y Wikimedia Commons verificando la especie."""
    candidates = get_candidate_names(scientific_name)
    candidates_lower = {c.lower() for c in candidates}
    epithets = {c.split()[1].lower() for c in candidates if len(c.split()) >= 2}
    urls = []
    seen_filenames = set()

    for name in candidates:
        title = urllib.parse.quote(name.replace(" ", "_"))
        for lang in ("en", "es", "fr", "eu", "de", "it"):
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
                        if len(urls) >= max_photos:
                            return urls
            except Exception:
                continue

        # Búsqueda en Wikimedia Commons API por nombre binomial exacto
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
                            if len(urls) >= max_photos:
                                return urls
        except Exception:
            continue
    return urls


def get_inaturalist_photo_urls(scientific_name: str, max_photos: int = 4) -> list[str]:
    """Obtiene URLs de fotografías verificadas en iNaturalist para el taxón exacto vía /v1/taxa/{id}."""
    candidates = get_candidate_names(scientific_name)
    candidates_lower = {c.lower() for c in candidates}
    urls = []
    seen_photo_ids = set()
    matched_taxon_ids = []

    for q in candidates:
        try:
            time.sleep(0.25)
            encoded = urllib.parse.quote(q)
            api_url = f"https://api.inaturalist.org/v1/taxa?q={encoded}&is_active=true&per_page=10"
            data = fetch_json(api_url)
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
            time.sleep(0.25)
            detail_url = f"https://api.inaturalist.org/v1/taxa/{tid}"
            detail_data = fetch_json(detail_url)
            for taxon in detail_data.get("results", []):
                for tp in taxon.get("taxon_photos", []):
                    photo = tp.get("photo", {})
                    pid = str(photo.get("id") or "")
                    medium_url = photo.get("medium_url") or photo.get("large_url")
                    if medium_url and pid not in seen_photo_ids:
                        if pid:
                            seen_photo_ids.add(pid)
                        if medium_url not in urls:
                            urls.append(medium_url)
                            if len(urls) >= max_photos:
                                return urls
        except Exception:
            continue

    return urls


def main():
    os.makedirs(IMAGES_DIR, exist_ok=True)
    os.makedirs(os.path.dirname(CATALOG_JSON_PATH), exist_ok=True)

    all_species = SPECIES_PART_1 + SPECIES_PART_2 + SPECIES_PART_3 + SPECIES_PART_4

    by_id = {}
    for sp in all_species:
        by_id[sp["id"]] = sp

    species_list = sorted(by_id.values(), key=lambda x: x["scientificName"].lower())
    print(f"Total especies en el catálogo: {len(species_list)}")

    missing_refs = []
    for sp in species_list:
        for conf in sp.get("confusions", []):
            ref_id = conf.get("mushroomId")
            if ref_id and ref_id not in by_id:
                missing_refs.append((sp["id"], ref_id))

    if missing_refs:
        print(f"ADVERTENCIA: Referencias no encontradas: {missing_refs}")
    else:
        print("Todas las referencias de confusiones habituales son válidas.")

    accepted_sigs = []

    def is_globally_unique(cand_sig) -> bool:
        if cand_sig is None:
            return False
        for existing_sig in accepted_sigs:
            if are_signatures_duplicate(cand_sig, existing_sig):
                return False
        return True

    print("Completando y verificando fotografías únicas para el catálogo offline...")
    for sp in species_list:
        sp_id = sp["id"]
        rel_paths = []
        for idx in (1, 2):
            p = os.path.join(IMAGES_DIR, f"{sp_id}_{idx}.jpg")
            if os.path.exists(p) and os.path.getsize(p) > 2048:
                with open(p, "rb") as f:
                    sig = compute_image_signature(f.read())
                if sig and is_globally_unique(sig):
                    accepted_sigs.append(sig)
                    rel_paths.append(f"assets/images/mushrooms/{sp_id}_{idx}.jpg")
                else:
                    os.remove(p)

        if len(rel_paths) < 2:
            photo_urls = get_inaturalist_photo_urls(sp["scientificName"], max_photos=6)
            for u in get_wikipedia_photo_urls(sp["scientificName"], max_photos=6):
                if u not in photo_urls:
                    photo_urls.append(u)

            for slot in (1, 2):
                target_rel = f"assets/images/mushrooms/{sp_id}_{slot}.jpg"
                if target_rel in rel_paths:
                    continue
                dest_file = os.path.join(IMAGES_DIR, f"{sp_id}_{slot}.jpg")
                for url in photo_urls:
                    raw = download_bytes(url)
                    if not raw:
                        continue
                    sig = compute_image_signature(raw)
                    if sig and is_globally_unique(sig):
                        with open(dest_file, "wb") as f:
                            f.write(raw)
                        accepted_sigs.append(sig)
                        rel_paths.append(target_rel)
                        break

        if not rel_paths:
            rel_paths.append("assets/images/logo_zizai.png")
        sp["images"] = sorted(rel_paths)

    with open(CATALOG_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(species_list, f, ensure_ascii=False, indent=2)

    # Re-apply trilingual translations automatically
    try:
        import subprocess
        import sys
        subprocess.run(
            [sys.executable, "-m", "tool.apply_catalog_translations"],
            cwd=ROOT_DIR,
            check=True,
        )
    except Exception as e:
        print(f"Aviso aplicando traducciones: {e}")

    still_fallback = [sp["id"] for sp in species_list if "logo_zizai" in sp["images"][0]]
    print(f"Catálogo generado exitosamente ({len(species_list)} especies). Sin foto específica: {len(still_fallback)}")


if __name__ == "__main__":
    main()
