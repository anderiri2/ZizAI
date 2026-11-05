# -*- coding: utf-8 -*-
"""Script to apply full verified trilingual translations (Basque, English, Spanish) to assets/data/mushrooms_catalog.json."""

import json
import os

from tool.translations_p1 import TRANSLATIONS_P1
from tool.translations_p2 import TRANSLATIONS_P2
from tool.translations_p3 import TRANSLATIONS_P3
from tool.translations_p4 import TRANSLATIONS_P4

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CATALOG_PATH = os.path.join(ROOT_DIR, "assets", "data", "mushrooms_catalog.json")

EXTRA_CONFUSIONS = {
    ("chlorophyllum_rhacodes", "lepiota_brunneoincarnata"): {
        "differenceEu": "Galanperna hilgarriak txikiak dira (txapela < 6 cm); ez bildu sekula 10 cm baino gutxiagoko alerik.",
        "differenceEn": "Deadly dapperlings are small (< 6 cm cap diameter); never harvest any specimen under 10 cm."
    },
    ("cortinarius_orellanus", "cantharellus_cibarius"): {
        "differenceEu": "Ziza horiak tolestura beheranzko horiak eta txapel inbutua ditu, sekula ez orri eskotatu herdoiltsurik.",
        "differenceEn": "Chanterelles have yellow decurrent ridges and a funnel cap, never adnate rust-brown gills."
    },
    ("cortinarius_praestans", "clitocybe_nebularis"): {
        "differenceEu": "Ilarrakak ez du kortinarik, ez du herdoil-koloreko esporarik eta usain oso sarkorra botatzen du.",
        "differenceEn": "Clouded funnel lacks a cortina, produces white spores, and emits a heavy penetrating cyanic odor."
    },
    ("craterellus_tubaeformis", "leotia_lubrica"): {
        "differenceEu": "Leotia lubrica gelatinosoa eta oso likatsua da, eta bere txapel biribilduak ez du inolako tolesturarik azpialdean.",
        "differenceEn": "Leotia lubrica is rubbery-gelatinous and slimy, and its rounded lobed head completely lacks underside veins."
    },
    ("agrocybe_cylindracea", "galerina_marginata"): {
        "differenceEu": "Galerina aleak askoz txikiagoak eta hauskorragoak dira, marroi-ezti kolorekoak eta irin-usain lizundukoak.",
        "differenceEn": "Much smaller and fragile specimens, hygrophanous honey-brown, with a rancid mealy odor."
    },
    ("fistulina_hepatica", "laetiporus_sulphureus"): {
        "differenceEu": "Basoko oilaskoa sufre-horia eta laranja bizia da, ez odol-gorria.",
        "differenceEn": "Chicken of the woods is bright sulphur-yellow and orange, never dark blood-red."
    },
    ("gomphidius_glutinosus", "hygrophorus_latitabundus"): {
        "differenceEu": "Ezko beltzak orriak beti zuriak ditu (espora zuriak) eta ez du oinaren oinarrian kromo-hori distiratsurik.",
        "differenceEn": "Hygrophorus latitabundus has white gills (white spores) and lacks a bright chrome-yellow stem base."
    },
    ("gomphus_clavatus", "cantharellus_cibarius"): {
        "differenceEu": "Ziza horia erabat urre-horia da, inolako tonu more-bioletarik gabe.",
        "differenceEn": "Golden chanterelle is entirely golden-yellow throughout, lacking violet shades."
    },
    ("helvella_lacunosa", "craterellus_cornucopioides"): {
        "differenceEu": "Hildakoen tronpetak inbutu huts jarraitua du, ez zela-formako mitra saihetsduna.",
        "differenceEn": "Horn of plenty is a continuous hollow trumpet, not a saddle-shaped mitre on a fluted stem."
    },
    ("hygrophorus_agathosmus", "hygrophorus_latitabundus"): {
        "differenceEu": "Ezko beltza askoz mardulagoa da, oinean oso mukitsua eta ez du almendra mingots usainik.",
        "differenceEn": "Hygrophorus latitabundus is more robust, very slimy on stem, and lacks the bitter-almond fragrance."
    },
    ("hygrophorus_eburneus", "clitocybe_dealbata"): {
        "differenceEu": "Clitocybe rivulosa lehorra eta hauts-antzekoa da (inoiz ez likatsua), orri estuak ditu eta larreetan hazten da.",
        "differenceEn": "Clitocybe dealbata is dry and frosted (never slimy), with crowded gills, growing in pastures."
    },
    ("hygrophorus_latitabundus", "gomphidius_glutinosus"): {
        "differenceEu": "Lerdeki mukitsuak oinaren oinarrian kromo-hori bizia du eta orriak beltzaxkak bihurtzen zaizkio.",
        "differenceEn": "Gomphidius glutinosus has a vivid chrome-yellow stem base and gills that mature blackish."
    },
    ("hygrophorus_marzuolus", "tricholoma_terreum"): {
        "differenceEu": "Negrilla udazken-negukoa da, txikiagoa eta hauskorragoa, txapel belusduna eta orri eskotatuak ditu (ez beheranzkoak).",
        "differenceEn": "Grey knight is smaller and fragile, with a dry felty cap and emarginate (not decurrent) gills."
    },
    ("hygrophorus_russula", "russula_vesca"): {
        "differenceEu": "Gibelurdinek haragi pikortsua dute klariona bezala hausten dena eta orriak erabat zuriak dituzte orban ardorik gabe.",
        "differenceEn": "Russulas have brittle chalk-like flesh and uniformly white gills without vinaceous stains."
    },
    ("hypholoma_capnoides", "galerina_marginata"): {
        "differenceEu": "Galerina marginatak orri herdoiltsuak ditu, eraztun txikia eta irin usaina.",
        "differenceEn": "Galerina marginata has rusty-cinnamon gills, a small membranous ring, and a mealy odor."
    },
    ("hypholoma_fasciculare", "agrocybe_cylindracea"): {
        "differenceEu": "Makal-zizak eraztun zuri mintzezkoa du, orri zuri/marroi-tabakoak eta sekula ez tonu hori-berdexkarik.",
        "differenceEn": "Poplar mushroom has a white ring, whitish to tobacco-brown gills, and no greenish-yellow tones."
    },
    ("imleria_badia", "boletus_edulis"): {
        "differenceEu": "Onddo zuriak sare zuria du oinean eta poroek ez dute sekula urdintzen ukitzean.",
        "differenceEn": "Boletus edulis has a white reticulated net on the stem and pores that never bruise blue."
    },
    ("infundibulicybe_geotropa", "entoloma_sinuatum"): {
        "differenceEu": "Ziza maltzurrak ez du sekula inbutu formarik ezta orri beheranzkorik ere.",
        "differenceEn": "Entoloma sinuatum never forms a funnel cap and does not possess decurrent gills."
    },
    ("laccaria_laccata", "laccaria_amethystina"): {
        "differenceEu": "Lakaria ubelak kolore more-ubela distiratsua du.",
        "differenceEn": "Laccaria amethystina has a deep vivid amethyst-violet color."
    },
    ("laetiporus_sulphureus", "fistulina_hepatica"): {
        "differenceEu": "Idi-mihia gorri ilun odolkara da eta haragia txuleta baten moduan marmolezkoa du.",
        "differenceEn": "Fistulina hepatica is deep liver-red with marbled flesh bleeding red juice."
    },
    ("leccinum_scabrum", "boletus_edulis"): {
        "differenceEu": "Onddo zuriak oin lodia du sare zuriarekin (ez ezkata beltz zakarrekin) eta haragi askoz gogorragoa.",
        "differenceEn": "Boletus edulis has a stout stem with a fine white net (no rough black scabers) and firmer flesh."
    },
    ("leotia_lubrica", "craterellus_tubaeformis"): {
        "differenceEu": "Mendiko angula ez da gelatinosoa, txapela zulatua du eta tolestura beheranzko markatuak ditu azpian.",
        "differenceEn": "Trumpet chanterelle is not gelatinous, has a hollow funnel cap, and distinct decurrent ridges beneath."
    },
    ("lepista_nuda", "cortinarius_praestans"): {
        "differenceEu": "Kortinario moretsuek kortina dute oinean eta orriak marroi-herdoil kolorez tindatzen zaizkie heltzean.",
        "differenceEn": "Violaceous cortinarius species have a cobweb-like cortina on the stem and rusty-brown mature gills."
    },
    ("lycoperdon_perlatum", "amanita_phalloides"): {
        "differenceEu": "Amanita baten arrautza luzetara ebakitzean txapelaren eta oinaren silueta ikusten da barruan; astaputzan barrualdea trinkoa eta uniformea da.",
        "differenceEn": "Cutting an Amanita button egg longitudinally reveals embryonic cap and stem silhouettes inside; puffballs are uniform throughout."
    },
    ("sparassis_crispa", "ramaria_formosa"): {
        "differenceEu": "Ramariek adar koraliforme zilindrikoak dituzte puntatan amaituak, ez letxuga bezalako zinta lau kizkurrak.",
        "differenceEn": "Ramaria species have cylindrical coral-like branches with pointed tips, not flat ruffled ribbons."
    },
    ("tylopilus_felleus", "boletus_reticulatus"): {
        "differenceEu": "Udako onddo zuriak poro zuri/hori-berdexkak ditu eta zapore gozoa du.",
        "differenceEn": "Boletus reticulatus has white/yellow-greenish pores and a sweet, pleasant nutty flavor."
    }
}

EDIBILITY_LABELS = {
    "excellent": {
        "es": "Excelente comestible",
        "eu": "Jangarri bikaina",
        "en": "Choice edible"
    },
    "good": {
        "es": "Buen comestible",
        "eu": "Jangarri ona",
        "en": "Good edible"
    },
    "caution": {
        "es": "Comestible con precaución",
        "eu": "Jangarria kontuz (ondo prestatuta)",
        "en": "Edible with caution"
    },
    "non_edible": {
        "es": "Sin valor culinario",
        "eu": "Balio kulinariorik gabea",
        "en": "Inedible"
    },
    "toxic": {
        "es": "Tóxica",
        "eu": "Toxikoa",
        "en": "Toxic"
    },
    "deadly": {
        "es": "Mortal",
        "eu": "Hilgarria",
        "en": "Deadly poisonous"
    }
}


def clean_prefix(text: str) -> str:
    """Removes redundant prefixes like 'Txapela: ', 'Cap: ' etc."""
    import re
    p = re.compile(
        r'^(Txapela|Himenioa(\s*/\s*Orriak)?|Hanka(\s*/\s*Oina)?|Haragia(\s*/\s*Mamia)?|'
        r'Sombrero|Himenio|Pie|Carne|Cap|Hymenium(\s*/\s*[A-Za-z\-]+)?|'
        r'Stem(\s*/\s*[A-Za-z\-]+)?|Flesh(\s*&\s*[A-Za-z\-]+)?)\s*:\s*',
        re.IGNORECASE
    )
    return p.sub('', text).strip()


def main():
    all_trans = {}
    all_trans.update(TRANSLATIONS_P1)
    all_trans.update(TRANSLATIONS_P2)
    all_trans.update(TRANSLATIONS_P3)
    all_trans.update(TRANSLATIONS_P4)

    with open(CATALOG_PATH, "r", encoding="utf-8") as f:
        catalog = json.load(f)

    species_map = {m["id"]: m for m in catalog}

    updated_count = 0
    for m in catalog:
        m_id = m["id"]
        t = all_trans.get(m_id)
        if not t:
            print(f"Warning: no translation for {m_id}")
            continue

        ed = m["edibility"]
        ed_lbls = EDIBILITY_LABELS.get(ed, EDIBILITY_LABELS["non_edible"])
        m["edibilityLabel"] = ed_lbls["es"]
        m["edibilityLabelEu"] = ed_lbls["eu"]
        m["edibilityLabelEn"] = ed_lbls["en"]

        if "summary" in t and t["summary"]:
            m["summary"] = t["summary"]
        m["summaryEu"] = t["summaryEu"]
        m["summaryEn"] = t["summaryEn"]

        m["habitatEu"] = t["habitatEu"]
        m["habitatEn"] = t["habitatEn"]

        m["seasonEu"] = t["seasonEu"]
        m["seasonEn"] = t["seasonEn"]

        # Clean base morphology
        if "morphology" in m:
            for k in ["cap", "hymenium", "stem", "flesh"]:
                if k in m["morphology"]:
                    m["morphology"][k] = clean_prefix(m["morphology"][k])

        # Morphology EU
        m["morphologyEu"] = {
            k: clean_prefix(v) for k, v in t["morphologyEu"].items()
        }

        # Morphology EN
        m["morphologyEn"] = {
            k: clean_prefix(v) for k, v in t["morphologyEn"].items()
        }

        # Confusions
        for conf in m.get("confusions", []):
            target_id = conf["mushroomId"]
            target_m = species_map.get(target_id)
            if target_m:
                conf["commonName"] = target_m["spanishName"]
                conf["commonNameEu"] = target_m["basqueName"]
                conf["commonNameEn"] = target_m.get("englishName", target_m["scientificName"])
                conf["riskLevel"] = target_m["edibility"]

            # Difference translations
            diff_eu = None
            diff_en = None

            if "confusions" in t and target_id in t["confusions"]:
                diff_eu = t["confusions"][target_id].get("differenceEu")
                diff_en = t["confusions"][target_id].get("differenceEn")

            if not diff_eu and (m_id, target_id) in EXTRA_CONFUSIONS:
                diff_eu = EXTRA_CONFUSIONS[(m_id, target_id)].get("differenceEu")
                diff_en = EXTRA_CONFUSIONS[(m_id, target_id)].get("differenceEn")

            if diff_eu:
                conf["differenceEu"] = diff_eu
            else:
                conf["differenceEu"] = conf.get("difference", "")

            if diff_en:
                conf["differenceEn"] = diff_en
            else:
                conf["differenceEn"] = conf.get("difference", "")

        updated_count += 1

    with open(CATALOG_PATH, "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)

    print(f"Successfully updated and localized {updated_count} mushrooms in {CATALOG_PATH}.")


if __name__ == "__main__":
    main()
