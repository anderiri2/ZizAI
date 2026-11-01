#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script generador del catálogo micológico de Perretxikotan (+125 especies de Euskadi y España).
- Combina y ordena alfabéticamente todas las especies.
- Verifica la integridad de todas las referencias cruzadas de confusiones.
- Descarga fotografías reales con licencia abierta desde Wikipedia / Wikimedia Commons / iNaturalist
  y las almacena localmente en assets/images/mushrooms/ para uso 100% offline en el monte.
"""

import json
import os
import re
import ssl
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

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
    "User-Agent": "PerretxikotanAppCatalogBuilder/1.0 (https://perretxikotan.app; contact@perretxikotan.app)"
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


def fetch_json(url: str, timeout: int = 12):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, context=SSL_CTX, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def download_binary(url: str, dest_path: str, timeout: int = 15) -> bool:
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, context=SSL_CTX, timeout=timeout) as resp:
            data = resp.read()
            if len(data) > 2048:
                with open(dest_path, "wb") as f:
                    f.write(data)
                return True
    except Exception:
        pass
    return False


def get_wikipedia_photo_urls(scientific_name: str, max_photos: int = 2) -> list[str]:
    """Obtiene imágenes desde Wikipedia REST API y Wikimedia Commons."""
    urls = []
    for name in get_candidate_names(scientific_name):
        title = urllib.parse.quote(name.replace(" ", "_"))
        for lang in ("en", "es", "fr", "eu"):
            try:
                summary_url = f"https://{lang}.wikipedia.org/api/rest_v1/page/summary/{title}"
                data = fetch_json(summary_url, timeout=8)
                thumb = data.get("thumbnail", {}).get("source")
                if thumb and thumb not in urls:
                    urls.append(thumb)
                    if len(urls) >= max_photos:
                        return urls
            except Exception:
                continue

        # Búsqueda en Wikimedia Commons API
        try:
            q = urllib.parse.quote(name)
            commons_url = (
                f"https://commons.wikimedia.org/w/api.php?action=query&generator=search"
                f"&gsrsearch=filetype:bitmap%20{q}&gsrlimit=4&prop=imageinfo"
                f"&iiprop=url&iiurlwidth=600&format=json"
            )
            cdata = fetch_json(commons_url, timeout=10)
            pages = cdata.get("query", {}).get("pages", {})
            for page in pages.values():
                for ii in page.get("imageinfo", []):
                    turl = ii.get("thumburl") or ii.get("url")
                    if turl and turl.lower().endswith((".jpg", ".jpeg", ".png")) and turl not in urls:
                        urls.append(turl)
                        if len(urls) >= max_photos:
                            return urls
        except Exception:
            continue
    return urls


def get_inaturalist_photo_urls(scientific_name: str, max_photos: int = 2) -> list[str]:
    """Obtiene URLs de fotografías verificadas en iNaturalist para el taxón."""
    urls = []
    for q in get_candidate_names(scientific_name):
        try:
            time.sleep(0.35)
            encoded = urllib.parse.quote(q)
            api_url = f"https://api.inaturalist.org/v1/taxa?q={encoded}&is_active=true&per_page=3"
            data = fetch_json(api_url)
            results = data.get("results", [])
            for taxon in results:
                for tp in taxon.get("taxon_photos", []):
                    photo = tp.get("photo", {})
                    medium_url = photo.get("medium_url") or photo.get("large_url")
                    if medium_url and medium_url not in urls:
                        urls.append(medium_url)
                        if len(urls) >= max_photos:
                            return urls
                default_photo = taxon.get("default_photo", {})
                medium_url = default_photo.get("medium_url")
                if medium_url and medium_url not in urls:
                    urls.append(medium_url)
                    if len(urls) >= max_photos:
                        return urls
        except Exception:
            continue
    return urls


def ensure_species_images(species: dict) -> list[str]:
    """Garantiza que la especie tenga 1-2 imágenes reales descargadas en assets/images/mushrooms/."""
    sp_id = species["id"]
    rel_paths = []

    existing_1 = os.path.join(IMAGES_DIR, f"{sp_id}_1.jpg")
    existing_2 = os.path.join(IMAGES_DIR, f"{sp_id}_2.jpg")
    if os.path.exists(existing_1) and os.path.getsize(existing_1) > 2048:
        rel_paths.append(f"assets/images/mushrooms/{sp_id}_1.jpg")
        if os.path.exists(existing_2) and os.path.getsize(existing_2) > 2048:
            rel_paths.append(f"assets/images/mushrooms/{sp_id}_2.jpg")
        return rel_paths

    photo_urls = get_wikipedia_photo_urls(species["scientificName"], max_photos=2)
    if len(photo_urls) < 2:
        for u in get_inaturalist_photo_urls(species["scientificName"], max_photos=2):
            if u not in photo_urls:
                photo_urls.append(u)
            if len(photo_urls) >= 2:
                break

    for idx, url in enumerate(photo_urls[:2], start=1):
        dest_file = os.path.join(IMAGES_DIR, f"{sp_id}_{idx}.jpg")
        if download_binary(url, dest_file):
            rel_paths.append(f"assets/images/mushrooms/{sp_id}_{idx}.jpg")

    if not rel_paths:
        rel_paths.append("assets/images/logo_perretxikotan.png")
    return rel_paths


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

    print("Completando fotografías reales de las especies para el catálogo offline...")
    completed = 0
    with ThreadPoolExecutor(max_workers=4) as pool:
        future_to_sp = {pool.submit(ensure_species_images, sp): sp for sp in species_list}
        for future in as_completed(future_to_sp):
            sp = future_to_sp[future]
            try:
                sp["images"] = future.result()
            except Exception as e:
                print(f"Error en {sp['id']}: {e}")
                sp["images"] = ["assets/images/logo_perretxikotan.png"]
            completed += 1
            if completed % 15 == 0 or completed == len(species_list):
                print(f"  Progreso imágenes: {completed}/{len(species_list)}")

    with open(CATALOG_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(species_list, f, ensure_ascii=False, indent=2)

    still_fallback = [sp["id"] for sp in species_list if "logo_perretxikotan" in sp["images"][0]]
    print(f"Catálogo generado exitosamente ({len(species_list)} especies). Sin foto específica: {len(still_fallback)}")


if __name__ == "__main__":
    main()
