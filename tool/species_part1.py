# -*- coding: utf-8 -*-
"""Parte 1 del catálogo micológico de ZizAI (Especies A - C)."""

SPECIES_PART_1 = [
    {
        "id": "agaricus_arvensis",
        "scientificName": "Agaricus arvensis",
        "spanishName": "Bola de nieve / Champiñón anisado",
        "basqueName": "Elur-bola / Barrengorri anisduna",
        "family": "Agaricaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera a Otoño (Mayo - Noviembre)",
        "habitat": "Praderas abonadas, pastizales de montaña, claros de bosque y bordes de caminos herbosos.",
        "summary": "Champiñón silvestre de gran porte, carne blanca que amarillea suavemente al roce y característico olor anisado agradable.",
        "morphology": {
            "cap": "De 8 a 20 cm, globoso de joven y luego convexo-aplanado. Cutícula sedosa de color blanco puro que amarillea al frotamiento.",
            "hymenium": "Láminas libres, apretadas, inicialmente blancas, luego rosadas pálidas y finalmente marrón chocolate oscuro al madurar las esporas.",
            "stem": "Cilíndrico y robusto, algo bulboso en la base, blanco, provisto de un anillo doble amplio con escamas en forma de rueda dentada en su cara inferior.",
            "flesh": "Espesa y firme, blanca, con suave viraje ocre-amarillento y marcado olor a anís o almendras amargas."
        },
        "confusions": [
            {
                "mushroomId": "agaricus_xanthodermus",
                "scientificName": "Agaricus xanthodermus",
                "commonName": "Champiñón amarilleante (Azpibeltz tintausain)",
                "riskLevel": "toxic",
                "difference": "Amarillea de forma inmediata e intensa (color cromo brillante) en la base del pie al corte y desprende un fuerte olor químico a tinta o fenol."
            },
            {
                "mushroomId": "amanita_verna",
                "scientificName": "Amanita verna",
                "commonName": "Oronja blanca mortal (Kuleto zuri hilgarria)",
                "riskLevel": "deadly",
                "difference": "Tiene láminas siempre blancas (nunca rosadas ni marrones) y presenta una volva sacciforme en la base del pie."
            }
        ]
    },
    {
        "id": "agaricus_bisporus",
        "scientificName": "Agaricus bisporus",
        "spanishName": "Champiñón común / Champiñón de París",
        "basqueName": "Barrengorri arrunta",
        "family": "Agaricaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Primavera y Otoño",
        "habitat": "Terrenos estercolados, jardines, pastizales nitrogenados y bordes de caminos.",
        "summary": "El champiñón clásico por excelencia, de sombrero redondeado, carne que enrojece levemente y láminas rosadas a negruzcas.",
        "morphology": {
            "cap": "De 4 a 12 cm, hemisférico a plano-convexo, con cutícula fibrillosa blanca o pardo-ocrácea.",
            "hymenium": "Láminas libres y apretadas, de tono rosa carne de joven y marrón negruzco en la madurez.",
            "stem": "Corto, grueso y cilíndrico, con anillo simple membranoso situado hacia la mitad del pie.",
            "flesh": "Blanca y firme, enrojece ligeramente al corte. Olor fúngico suave y sabor agradable."
        },
        "confusions": [
            {
                "mushroomId": "agaricus_xanthodermus",
                "scientificName": "Agaricus xanthodermus",
                "commonName": "Champiñón amarilleante (Azpibeltz tintausain)",
                "riskLevel": "toxic",
                "difference": "Olor desagradable a yodo/fenol y viraje amarillo vivo en la base del pie."
            }
        ]
    },
    {
        "id": "agaricus_campestris",
        "scientificName": "Agaricus campestris",
        "spanishName": "Champiñón silvestre / Camperol",
        "basqueName": "Larre-barrengorria / Azpibeltza",
        "family": "Agaricaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera y Otoño tras lluvias abundantes",
        "habitat": "Prados y pastizales frecuentados por ganado en llanuras y media montaña del País Vasco y toda la Península.",
        "summary": "El champiñón de prado más buscado tras las tormentas de finales de verano; pie corto afilado en la base y anillo fugaz.",
        "morphology": {
            "cap": "De 5 a 12 cm, globoso y luego convexo-extendido, blanco sedoso o con finas escamas parduzcas en el centro.",
            "hymenium": "Láminas libres de un bello color rosa vivo en ejemplares jóvenes que pasan a pardo chocolate oscuro.",
            "stem": "Corto, lleno, estrechado hacia la base, con un anillo sencillo, fino y fugaz que suele desaparecer con la edad.",
            "flesh": "Blanca y compacta que vira ligeramente al rosa al corte; olor y sabor dulces muy agradables."
        },
        "confusions": [
            {
                "mushroomId": "amanita_phalloides",
                "scientificName": "Amanita phalloides",
                "commonName": "Oronja verde (Hiltzaile berdea)",
                "riskLevel": "deadly",
                "difference": "Las Amanitas tienen volva en la base del pie y sus láminas son siempre blancas."
            },
            {
                "mushroomId": "agaricus_xanthodermus",
                "scientificName": "Agaricus xanthodermus",
                "commonName": "Champiñón amarilleante",
                "riskLevel": "toxic",
                "difference": "Viraje amarillo cromo en la base del pie y olor químico a tinta."
            }
        ]
    },
    {
        "id": "agaricus_sylvaticus",
        "scientificName": "Agaricus sylvaticus",
        "spanishName": "Champiñón de bosque / Champiñón sangrante",
        "basqueName": "Basoetako azpibeltza",
        "family": "Agaricaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Finales de Verano y Otoño",
        "habitat": "Bosques de coníferas (pinares y abetales) y bosques mixtos con hayas o robles.",
        "summary": "Champiñón forestal cubierto de escamas pardas cuya carne enrojece de forma llamativa al cortarla.",
        "morphology": {
            "cap": "De 5 a 10 cm, cubierto de escamas fibrillosas de color marrón rojizo sobre fondo claro.",
            "hymenium": "Láminas libres, gris-rosadas de joven y pardo-negruzcas al madurar.",
            "stem": "Esbelto, cilíndrico con base algo bulbosa, blanquecino que enrojece al roce, con anillo membranoso frágil.",
            "flesh": "Blanca que vira rápidamente al rojo sangre al corte, especialmente en ejemplares jóvenes."
        },
        "confusions": [
            {
                "mushroomId": "agaricus_xanthodermus",
                "scientificName": "Agaricus xanthodermus",
                "commonName": "Champiñón amarilleante",
                "riskLevel": "toxic",
                "difference": "En lugar de enrojecer al corte, amarillea intensamente en la base y huele a fenol."
            }
        ]
    },
    {
        "id": "agaricus_xanthodermus",
        "scientificName": "Agaricus xanthodermus",
        "spanishName": "Champiñón amarilleante / Agárico manchado de amarillo",
        "basqueName": "Azpibeltz tintausain",
        "family": "Agaricaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Verano y Otoño",
        "habitat": "Prados, parques urbanos, bordes de bosque y zonas herbosas nitrificadas.",
        "summary": "Especie tóxica gastrointestinal muy frecuente que se delata por su olor a tinta/fenol y el amarillo vivo al raspar la base del pie.",
        "morphology": {
            "cap": "De 6 a 14 cm, característicamente troncocónico o trapezoidal de joven, blanco que amarillea de forma intensa al roce.",
            "hymenium": "Láminas libres, blanquecinas al principio, luego rosa vivo y finalmente marrón negruzco.",
            "stem": "Largo, cilíndrico con bulbo basal marginado; al cortar la base se tiñe al instante de amarillo cromo brillante.",
            "flesh": "Blanca salvo en la base del pie donde es amarilla intensa. Olor desagradable a tinta china, yodo o fenol (más fuerte al cocinarlo)."
        },
        "confusions": [
            {
                "mushroomId": "agaricus_arvensis",
                "scientificName": "Agaricus arvensis",
                "commonName": "Bola de nieve (Elur-bola)",
                "riskLevel": "excellent",
                "difference": "Huele agradablemente a anís y su amarilleamiento es muy tenue y lento, nunca amarillo cromo en la base del pie."
            }
        ]
    },
    {
        "id": "agrocybe_cylindracea",
        "scientificName": "Cyclocybe aegerita (Agrocybe cylindracea)",
        "spanishName": "Seta de chopo",
        "basqueName": "Makal-ziza",
        "family": "Strophariaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera, Verano y Otoño",
        "habitat": "Crecimiento cespitoso sobre tocones y troncos de chopos, álamos, sauces y olmos en riberas de ríos.",
        "summary": "Muy apreciada seta lignícola que crece en racimos sobre chopos, de sombrero cuarteado color café con leche.",
        "morphology": {
            "cap": "De 4 a 12 cm, convexo a plano, cutícula seca y frecuentemente agrietada, de color pardo oscuro de joven y ocre claro o blanquecino al madurar.",
            "hymenium": "Láminas adnatas, apretadas, primero blanquecinas y después pardo tabaco por las esporas.",
            "stem": "Largo, curvado, fibroso, blanquecino con anillo membranoso alto teñido de marrón por las esporas.",
            "flesh": "Compacta, blanca, con agradable olor afrutado o a harina fresca y excelente sabor."
        },
        "confusions": [
            {
                "mushroomId": "hypholoma_fasciculare",
                "scientificName": "Hypholoma fasciculare",
                "commonName": "Hifoloma de láminas verdes (Suge-ziza mingotsa)",
                "riskLevel": "toxic",
                "difference": "Tiene tonos amarillo-azufre verdosos en las láminas y la carne es intensamente amarga."
            },
            {
                "mushroomId": "galerina_marginata",
                "scientificName": "Galerina marginata",
                "commonName": "Galerina rebordeada",
                "riskLevel": "deadly",
                "difference": "Ejemplares mucho más pequeños y frágiles, de color pardo miel higrófano y olor harinoso rancio."
            }
        ]
    },
    {
        "id": "albatrellus_ovinus",
        "scientificName": "Albatrellus ovinus",
        "spanishName": "Políporo de las ovejas / Lengua de oveja",
        "basqueName": "Ardi-mihia",
        "family": "Albatrellaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Finales de Verano y Otoño",
        "habitat": "Bosques de coníferas de montaña (pinares y abetales), a menudo en grandes grupos.",
        "summary": "Hongo con poros diminutos de aspecto similar a la lengua de gato pero sin aguijones, comestible en ejemplares jóvenes.",
        "morphology": {
            "cap": "De 5 a 15 cm, irregular y lobulado, color blanco marfil que se cuartea y amarillea con la edad.",
            "hymenium": "Poros muy pequeños y cortos, decurrentes, blancos que viran a amarillo verdoso al roce.",
            "stem": "Corto, macizo, frecuentemente excéntrico y blanco.",
            "flesh": "Quebradiza y tierna de joven, blanca con suave aroma almendrado."
        },
        "confusions": [
            {
                "mushroomId": "hydnum_repandum",
                "scientificName": "Hydnum repandum",
                "commonName": "Lengua de gato (Tripaki argia)",
                "riskLevel": "excellent",
                "difference": "Presenta aguijones frágiles bajo el sombrero en lugar de pequeños poros."
            }
        ]
    },
    {
        "id": "aleuria_aurantia",
        "scientificName": "Aleuria aurantia",
        "spanishName": "Peziza naranja",
        "basqueName": "Katilu laranja",
        "family": "Pyronemataceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Otoño",
        "habitat": "Suelos desnudos, taludes, bordes de pistas forestales y claros de bosques húmedos.",
        "summary": "Llamativo hongo en forma de copa o cuenco de color naranja brillante sin pie.",
        "morphology": {
            "cap": "Ascocarpo en forma de copa irregular de 3 a 10 cm, cara interna naranja vivo y cara externa blanquecina pruinosa.",
            "hymenium": "Situado en la superficie interna lisa de color naranja intenso.",
            "stem": "Inexistente (sésil), adherido directamente al sustrato.",
            "flesh": "Muy delgada, frágil y quebradiza, inodora e insípida."
        },
        "confusions": [
            {
                "mushroomId": "sarcoscypha_coccinea",
                "scientificName": "Sarcoscypha coccinea",
                "commonName": "Copa escarlata (Txano gorria)",
                "riskLevel": "non_edible",
                "difference": "Color rojo escarlata intenso, más coriácea y crece en invierno/primavera sobre ramas caídas."
            }
        ]
    },
    {
        "id": "amanita_caesarea",
        "scientificName": "Amanita caesarea",
        "spanishName": "Oronja / Amanita de los Césares",
        "basqueName": "Gorringoa / Kuletoa",
        "family": "Amanitaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Finales de Verano y Otoño templado (Agosto - Octubre)",
        "habitat": "Bosques termófilos de robles (Quercus robur, Q. pyrenaica), encinas, alcornoques y castaños en laderas soleadas.",
        "summary": "La reina de las setas: sombrero naranja vivo, láminas y pie amarillo oro y gran volva blanca en forma de saco.",
        "morphology": {
            "cap": "De 8 a 20 cm, ovoide al emerger del huevo y luego hemisférico-convexo. Cutícula lisa y brillante de color naranja vivo a rojo anaranjado, con margen estriado y generalmente sin restos de velo.",
            "hymenium": "Láminas libres, apretadas y ventrudas de un inconfundible color amarillo dorado.",
            "stem": "Cilíndrico, robusto, amarillo dorado, con anillo estriado también amarillo y una gran volva basal blanca, gruesa y sacciforme.",
            "flesh": "Tierna, blanca en el interior y amarilla bajo la cutícula y corteza del pie; olor suave y sabor delicado."
        },
        "confusions": [
            {
                "mushroomId": "amanita_muscaria",
                "scientificName": "Amanita muscaria",
                "commonName": "Matamoscas / Falsa oronja (Kuleto faltsua)",
                "riskLevel": "toxic",
                "difference": "La Amanita muscaria tiene láminas, pie y anillo siempre BLANCOS (nunca amarillos) y volva fragmentada en verrugas concéntricas."
            }
        ]
    },
    {
        "id": "amanita_citrina",
        "scientificName": "Amanita citrina",
        "spanishName": "Amanita limón / Oronja limona",
        "basqueName": "Lanperna limoia",
        "family": "Amanitaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Otoño",
        "habitat": "Muy común en hayedos, robledales y pinares de suelo ácido.",
        "summary": "Amanita de color amarillo limón pálido o blanquecino con bulbo basal circunciso y fuerte olor a patata cruda.",
        "morphology": {
            "cap": "De 5 a 10 cm, amarillo citrino pálido o blanco en la var. alba, cubierto de placas irregulares blanquecinas o parduzcas del velo.",
            "hymenium": "Láminas libres, apretadas, blancas o con reflejo cremoso.",
            "stem": "Esbelto, blanco-amarillento, con anillo membranoso amplio y un grueso bulbo esférico marginado en la base.",
            "flesh": "Blanca, con un inconfundible olor a patata cruda o rábano y sabor desagradable."
        },
        "confusions": [
            {
                "mushroomId": "amanita_phalloides",
                "scientificName": "Amanita phalloides",
                "commonName": "Oronja verde (Hiltzaile berdea)",
                "riskLevel": "deadly",
                "difference": "Amanita phalloides carece de placas verrugosas regulares, tiene sombrero fibrilloso verde-oliva y volva en forma de saco libre, no bulbo circunciso."
            }
        ]
    },
    {
        "id": "amanita_excelsa",
        "scientificName": "Amanita excelsa (Amanita spissa)",
        "spanishName": "Amanita amplia",
        "basqueName": "Lanperna sendoa",
        "family": "Amanitaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Verano y Otoño",
        "habitat": "Bosques de frondosas y coníferas en el País Vasco y norte peninsular.",
        "summary": "Amanita gris-parda con verrugas harinosas grises, anillo estriado y sin tonos rojizos en la carne (se desaconseja su consumo por su parecido con A. pantherina).",
        "morphology": {
            "cap": "De 6 a 14 cm, pardo grisáceo con placas verrugosas grises harinosas y margen NO estriado.",
            "hymenium": "Láminas libres, anchas y blancas.",
            "stem": "Robusto, blanco con escamas grisáceas, anillo amplio claramente estriado en su cara superior y base napiforme.",
            "flesh": "Blanca e inmutable (no enrojece), con ligero olor a rábano."
        },
        "confusions": [
            {
                "mushroomId": "amanita_pantherina",
                "scientificName": "Amanita pantherina",
                "commonName": "Amanita pantera (Lanperna txarra)",
                "riskLevel": "toxic",
                "difference": "Amanita pantherina tiene el margen del sombrero estriado, verrugas blanco puro, anillo liso (sin estrías) y volva circuncisa en collar."
            },
            {
                "mushroomId": "amanita_rubescens",
                "scientificName": "Amanita rubescens",
                "commonName": "Amanita vinosa (Galdakao lanperna)",
                "riskLevel": "caution",
                "difference": "Amanita rubescens adquiere tonos rojizos o vinosos en la carne, el pie y las mordeduras de insectos."
            }
        ]
    },
    {
        "id": "amanita_muscaria",
        "scientificName": "Amanita muscaria",
        "spanishName": "Matamoscas / Falsa oronja",
        "basqueName": "Kuleto faltsua / Lanperna gorria",
        "family": "Amanitaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Otoño",
        "habitat": "Abedulares, pinares, hayedos y robledales sobre suelos ácidos.",
        "summary": "La icónica seta de los cuentos: sombrero rojo escarlata salpicado de verrugas blancas y láminas y pie blancos.",
        "morphology": {
            "cap": "De 8 a 20 cm, rojo vivo o rojo anaranjado cubierto de verrugas blancas piramidales (que pueden lavarse tras fuertes lluvias). Margen estriado.",
            "hymenium": "Láminas libres, apretadas, blancas.",
            "stem": "Alto y cilíndrico, blanco, con amplio anillo colgante y bulbo basal rodeado de anillos concéntricos de verrugas.",
            "flesh": "Blanca, amarillenta justo bajo la cutícula; inodora. Provoca intoxicaciones neurotóxicas (síndrome micoatropínico)."
        },
        "confusions": [
            {
                "mushroomId": "amanita_caesarea",
                "scientificName": "Amanita caesarea",
                "commonName": "Oronja (Gorringoa)",
                "riskLevel": "excellent",
                "difference": "Cuando la lluvia lava las verrugas de A. muscaria puede parecerse por arriba, pero A. caesarea siempre tiene láminas y pie amarillo oro y volva blanca en saco."
            }
        ]
    },
    {
        "id": "amanita_pantherina",
        "scientificName": "Amanita pantherina",
        "spanishName": "Amanita pantera / Falso galdakao",
        "basqueName": "Lanperna txarra / Pantera-lanperna",
        "family": "Amanitaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Verano y Otoño",
        "habitat": "Bosques de frondosas (robledales y hayedos) y coníferas.",
        "summary": "Especie gravemente tóxica de sombrero marrón con verrugas blancas puras, margen estriado y anillo sin estrías.",
        "morphology": {
            "cap": "De 5 a 12 cm, marrón avellana a pardo oscuro, salpicado de pequeñas verrugas de color blanco puro y con el margen claramente estriado.",
            "hymenium": "Láminas libres, redondeadas, blancas.",
            "stem": "Blanco, esbelto, con anillo membranoso LISO (no estriado) y bulbo basal con reborde neto en forma de cuello de calcetín.",
            "flesh": "Blanca, totalmente inmutable al corte (nunca enrojece)."
        },
        "confusions": [
            {
                "mushroomId": "amanita_rubescens",
                "scientificName": "Amanita rubescens",
                "commonName": "Amanita vinosa / Galdakao (Galdakao lanperna)",
                "riskLevel": "caution",
                "difference": "A. rubescens tiene margen liso, anillo muy estriado y su carne y base del pie se tiñen de color rosa-vinoso."
            }
        ]
    },
    {
        "id": "amanita_phalloides",
        "scientificName": "Amanita phalloides",
        "spanishName": "Oronja verde / Cicuta verde",
        "basqueName": "Hiltzaile berdea / Lanperna ezkata-berdea",
        "family": "Amanitaceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Finales de Verano y Otoño",
        "habitat": "Bosques de frondosas (especialmente robles, hayas, encinas y castaños) y ocasionalmente coníferas.",
        "summary": "La seta más peligrosa de nuestros bosques (responsable de la mayoría de intoxicaciones mortales por síndrome faloidiano).",
        "morphology": {
            "cap": "De 6 a 15 cm, verde oliva, verde amarillento o a veces blanquecino, recorrido por finas fibrillas radiales más oscuras bajo la cutícula.",
            "hymenium": "Láminas libres, apretadas, de color blanco puro.",
            "stem": "Cilíndrico, blanco con reflejos o cebraduras verdosas en zigzag, anillo membranoso blanco y gran volva sacciforme blanca en la base.",
            "flesh": "Blanca, inodora de joven y con olor dulzón desagradable al envejecer. Un solo ejemplar puede resultar letal."
        },
        "confusions": [
            {
                "mushroomId": "russula_virescens",
                "scientificName": "Russula virescens",
                "commonName": "Gorro verde (Gibelurdin ezkata-berdea)",
                "riskLevel": "excellent",
                "difference": "Las Russulas tienen carne granulosa que parte como la tiza y carecen por completo de anillo y de volva."
            },
            {
                "mushroomId": "agaricus_campestris",
                "scientificName": "Agaricus campestris",
                "commonName": "Champiñón silvestre (Azpibeltza)",
                "riskLevel": "excellent",
                "difference": "Los champiñones no tienen volva y sus láminas son rosas o marrones."
            }
        ]
    },
    {
        "id": "amanita_rubescens",
        "scientificName": "Amanita rubescens",
        "spanishName": "Amanita vinosa / Galdakao",
        "basqueName": "Galdakao lanperna / Lanperna gorrizta",
        "family": "Amanitaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Primavera, Verano y Otoño",
        "habitat": "Muy común en todo tipo de bosques (hayedos, robledales y pinares).",
        "summary": "Muy apreciada en Bizkaia ('seta de Galdakao'); excelente comestible solo si se cocina muy bien (es hemolítica en crudo) y se distingue por su enrojecimiento vinoso.",
        "morphology": {
            "cap": "De 6 a 15 cm, pardo rojizo o marrón rosado cubierto de verrugas harinosas gris-rosadas; margen liso (no estriado).",
            "hymenium": "Láminas libres, blancas que se manchan de rojo vinoso al roce o con la edad.",
            "stem": "Robusto, blanquecino-rosado, con amplio anillo blanco fuertemente estriado y bulbo basal napiforme teñido de rojo vino.",
            "flesh": "Tierna, blanca que vira al rosa vinoso al corte y en las galerías de larvas. Tóxica en crudo: requiere cocción completa (>75 °C)."
        },
        "confusions": [
            {
                "mushroomId": "amanita_pantherina",
                "scientificName": "Amanita pantherina",
                "commonName": "Amanita pantera (Lanperna txarra)",
                "riskLevel": "toxic",
                "difference": "Confusión muy peligrosa: A. pantherina NUNCA tiene tonos rojizos/vinosos, tiene el borde del sombrero estriado y el anillo liso."
            }
        ]
    },
    {
        "id": "amanita_vaginata",
        "scientificName": "Amanita vaginata",
        "spanishName": "Cucumela / Amanita enfundada",
        "basqueName": "Kukumelo grisa",
        "family": "Amanitaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Primavera a Otoño",
        "habitat": "Bosques de frondosas y coníferas.",
        "summary": "Amanita esbelta de color gris plomo, margen fuertemente acanalado, provista de volva pero totalmente desprovista de anillo.",
        "morphology": {
            "cap": "De 4 a 9 cm, acampanado y luego plano con mamelón central, color gris metálico y margen muy estriado o acanalado.",
            "hymenium": "Láminas libres, blancas.",
            "stem": "Largo, hueco, frágil, SIN ANILLO y envuelto en la base por una volva blanca profunda en forma de vaina.",
            "flesh": "Delgada, blanca y frágil. Tóxica en crudo, requiere cocción prolongada."
        },
        "confusions": [
            {
                "mushroomId": "amanita_phalloides",
                "scientificName": "Amanita phalloides",
                "commonName": "Oronja verde (Hiltzaile berdea)",
                "riskLevel": "deadly",
                "difference": "A. phalloides tiene anillo en el pie, margen del sombrero liso (sin estrías) y tonos verdosos."
            }
        ]
    },
    {
        "id": "amanita_verna",
        "scientificName": "Amanita verna",
        "spanishName": "Oronja blanca / Cicuta blanca",
        "basqueName": "Kuleto zuri hilgarria",
        "family": "Amanitaceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Primavera y principios de Verano",
        "habitat": "Encinares, robledales y pinares templados.",
        "summary": "Especie primaveral completamente blanca y mortal de necesidad (contiene las mismas amatoxinas que A. phalloides).",
        "morphology": {
            "cap": "De 5 a 10 cm, hemisférico a plano-convexo, liso, de color blanco puro (a veces crema pálido en el centro).",
            "hymenium": "Láminas libres, apretadas, siempre blancas.",
            "stem": "Esbelto, blanco, con anillo membranoso blanco y volva basal sacciforme blanca.",
            "flesh": "Blanca, inodora. Reacciona al hidróxido potásico (KOH) virando al amarillo en la variedad decipiens."
        },
        "confusions": [
            {
                "mushroomId": "agaricus_campestris",
                "scientificName": "Agaricus campestris",
                "commonName": "Champiñón silvestre (Azpibeltza)",
                "riskLevel": "excellent",
                "difference": "El champiñón tiene láminas rosadas o marrones y carece de volva en la base del pie."
            },
            {
                "mushroomId": "leucoagaricus_leucothites",
                "scientificName": "Leucoagaricus leucothites",
                "commonName": "Lepiota blanca (Galanperna zuria)",
                "riskLevel": "caution",
                "difference": "Carece por completo de volva en la base del pie."
            }
        ]
    },
    {
        "id": "amanita_virosa",
        "scientificName": "Amanita virosa",
        "spanishName": "Amanita maloliente / Ángel destructor",
        "basqueName": "Lanperna zuri hilgarria",
        "family": "Amanitaceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Verano y Otoño",
        "habitat": "Bosques húmedos de montaña (hayedos, abedulares y coníferas) sobre suelos ácidos.",
        "summary": "Conocida como el 'Ángel destructor', es una Amanita blanca de sombrero cónico asimétrico y pie lanoso igualmente mortal.",
        "morphology": {
            "cap": "De 5 a 10 cm, característicamente cónico-acampanado y a menudo asimétrico o lobulado, blanco brillante.",
            "hymenium": "Láminas libres, apretadas y blancas.",
            "stem": "Largo, blanco, cubierto de escamas lanosas, con anillo frágil desgarrado y volva blanca envolvente en la base.",
            "flesh": "Blanca que se tiñe de amarillo vivo con KOH; olor desagradable al madurar."
        },
        "confusions": [
            {
                "mushroomId": "agaricus_arvensis",
                "scientificName": "Agaricus arvensis",
                "commonName": "Bola de nieve (Elur-bola)",
                "riskLevel": "excellent",
                "difference": "Bola de nieve huele a anís, no tiene volva y sus láminas pasan del rosa al marrón chocolate."
            }
        ]
    },
    {
        "id": "armillaria_mellea",
        "scientificName": "Armillaria mellea",
        "spanishName": "Armilaria color de miel",
        "basqueName": "Enbor-ziza",
        "family": "Physalacriaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Otoño",
        "habitat": "Crece en grandes ramilletes parásitos o saprófitos sobre tocones y raíces de árboles frondosos y coníferas.",
        "summary": "Seta muy común que crece en grandes haces sobre madera; antiguamente consumida de joven pero hoy desaconsejada por causar intolerancias digestivas.",
        "morphology": {
            "cap": "De 4 a 12 cm, color miel a pardo oliváceo recubierto de pequeñas escamas oscuras en el centro.",
            "hymenium": "Láminas adnatas o algo decurrentes, blanquecinas que se manchan de pardo rojizo.",
            "stem": "Largo, fibroso, estriado, unido por la base a otros ejemplares, con un anillo grueso blanco-amarillento.",
            "flesh": "Blanca en el sombrero, fibrosa en el pie, sabor algo astringente."
        },
        "confusions": [
            {
                "mushroomId": "hypholoma_fasciculare",
                "scientificName": "Hypholoma fasciculare",
                "commonName": "Hifoloma de láminas verdes (Suge-ziza mingotsa)",
                "riskLevel": "toxic",
                "difference": "Carece de anillo membranoso, tiene láminas amarillo-verdosas y sabor muy amargo."
            },
            {
                "mushroomId": "galerina_marginata",
                "scientificName": "Galerina marginata",
                "commonName": "Galerina rebordeada",
                "riskLevel": "deadly",
                "difference": "Más pequeña, de esporada ocre-ferruginosa (la de Armillaria es blanca)."
            }
        ]
    },
    {
        "id": "auricularia_auricula_judae",
        "scientificName": "Auricularia auricula-judae",
        "spanishName": "Oreja de Judas",
        "basqueName": "Judasen belarria",
        "family": "Auriculariaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Todo el año en tiempo húmedo (especialmente Otoño e Invierno)",
        "habitat": "Sobre ramas y troncos de frondosas debilitadas, especialmente saúcos (Sambucus nigra), hayas y robles.",
        "summary": "Hongo gelatinoso y elástico con forma de oreja humana, excelente en salteados y sopas orientales tras cocinarlo.",
        "morphology": {
            "cap": "Carpóforo de 3 a 10 cm en forma de oreja con pliegues venosos, color pardo rojizo o violáceo, aterciopelado por fuera y liso brillante por dentro.",
            "hymenium": "En la cara interna lisa y plegada.",
            "stem": "Casi inexistente, unido lateralmente a la madera.",
            "flesh": "Gelatinosa y elástica en tiempo húmedo; dura y quebradiza cuando se seca (revive al hidratarse)."
        },
        "confusions": [
            {
                "mushroomId": "aleuria_aurantia",
                "scientificName": "Aleuria aurantia",
                "commonName": "Peziza naranja (Katilu laranja)",
                "riskLevel": "caution",
                "difference": "Crece en el suelo, es de color naranja brillante y su carne es quebradiza, no elástica."
            }
        ]
    },
    {
        "id": "boletus_aereus",
        "scientificName": "Boletus aereus",
        "spanishName": "Hongo negro / Boleto bronceado",
        "basqueName": "Onddo beltza / Ontto beltza",
        "family": "Boletaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Verano y Otoño (Junio - Noviembre)",
        "habitat": "Bosques templados de robles, hayas, castaños y encinas con brezales.",
        "summary": "La joya gastronómica de los montes vascos: el auténtico 'Onddo beltza', de sombrero muy oscuro aterciopelado y carne firme e inmutable.",
        "morphology": {
            "cap": "De 7 a 25 cm, hemisférico y luego convexo, con cutícula seca y aterciopelada de color pardo muy oscuro, bronceado o casi negro.",
            "hymenium": "Poros pequeños y redondos, primero blancos puros, luego amarillos y finalmente verde oliva.",
            "stem": "Robusto y rechoncho, color ocre-avellana adornado con un fino retículo pardo claro en la mitad superior.",
            "flesh": "Muy compacta y dura, de color blanco puro totalmente inmutable al corte; aroma fúngico intenso y sabor exquisito a avellana."
        },
        "confusions": [
            {
                "mushroomId": "tylopilus_felleus",
                "scientificName": "Tylopilus felleus",
                "commonName": "Boleto amargo (Behazun-onddo)",
                "riskLevel": "non_edible",
                "difference": "Sus poros se vuelven rosados al madurar, tiene un retículo oscuro muy grueso en el pie y su carne es extremadamente amarga."
            },
            {
                "mushroomId": "boletus_pinophilus",
                "scientificName": "Boletus pinophilus",
                "commonName": "Hongo de los pinos (Pinu-onddoa)",
                "riskLevel": "excellent",
                "difference": "También excelente comestible, pero con sombrero de tono caoba rojizo o granate."
            }
        ]
    },
    {
        "id": "boletus_edulis",
        "scientificName": "Boletus edulis",
        "spanishName": "Hongo blanco / Calabaza / Miguel",
        "basqueName": "Udazkeneko onddo zuri / Ontto zuria",
        "family": "Boletaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Finales de Verano y Otoño (Agosto - Noviembre)",
        "habitat": "Hayedos, robledales, castañares y pinares de montaña sobre suelos ácidos.",
        "summary": "El hongo calabaza por excelencia, reconocible por su sombrero pardo avellana algo viscoso con un fino borde blanco en el margen.",
        "morphology": {
            "cap": "De 8 a 25 cm, hemisférico a convexo, cutícula lisa y algo viscosa en tiempo húmedo, color pardo avellana con el margen característicamente blanquecino.",
            "hymenium": "Tubos largos y poros finos, blancos de joven que pasan a amarillo-verdoso.",
            "stem": "Ventrudo y robusto, blanquecino a ocre claro con un nítido retículo blanco en la parte superior.",
            "flesh": "Blanca e inmutable al corte, con una fina línea pardo-vinosa justo debajo de la cutícula del sombrero. Olor y sabor excelentes."
        },
        "confusions": [
            {
                "mushroomId": "tylopilus_felleus",
                "scientificName": "Tylopilus felleus",
                "commonName": "Boleto amargo (Behazun-onddo)",
                "riskLevel": "non_edible",
                "difference": "Poros rosados en la madurez y sabor amargo intenso."
            }
        ]
    },
    {
        "id": "boletus_pinophilus",
        "scientificName": "Boletus pinophilus",
        "spanishName": "Hongo de los pinos / Boleto pinícola",
        "basqueName": "Pinu-onddoa / Onddo burugorria",
        "family": "Boletaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera, Verano y Otoño",
        "habitat": "Pinares de montaña (Pinus sylvestris, P. radiata) y también hayedos del País Vasco y Pirineos.",
        "summary": "Uno de los cuatro grandes Boletus nobles, de gran tamaño y característico sombrero color caoba o rojo ladrillo.",
        "morphology": {
            "cap": "De 8 a 25 cm, grueso y abombado, cutícula seca y pruinosa de color marrón rojizo, caoba o burdeos.",
            "hymenium": "Poros finos, blancos al principio y luego amarillos y verdosos.",
            "stem": "Muy grueso y obeso, blanquecino con tonos rojizos o anaranjados y retículo fino rojizo-blanquecino.",
            "flesh": "Blanca e inmutable al corte, teñida de rojo vinoso bajo la cutícula; dulce y aromática."
        },
        "confusions": [
            {
                "mushroomId": "boletus_edulis",
                "scientificName": "Boletus edulis",
                "commonName": "Hongo blanco (Udazkeneko onddo zuri)",
                "riskLevel": "excellent",
                "difference": "Ambos son excelentes; B. edulis tiene el sombrero marrón avellana con borde blanco, sin tonos caoba."
            }
        ]
    },
    {
        "id": "boletus_reticulatus",
        "scientificName": "Boletus reticulatus (Boletus aestivalis)",
        "spanishName": "Hongo de verano / Boleto reticulado",
        "basqueName": "Udako onddo zuri",
        "family": "Boletaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Finales de Primavera y Verano (Mayo - Septiembre)",
        "habitat": "Bosques de frondosas (robledales, hayedos y castañares).",
        "summary": "El más temprano de los Boletus nobles, de sombrero color gamuza mate que se agrieta con el calor y pie totalmente reticulado.",
        "morphology": {
            "cap": "De 7 a 20 cm, convexo, cutícula seca, mate y aterciopelada de color pardo gamuza claro, que suele cuartearse en tiempo seco.",
            "hymenium": "Poros blancos de joven y luego amarillo-verdosos.",
            "stem": "Cilíndrico o ventrudo, color avellana claro cubierto en casi toda su longitud por una red (retículo) muy marcada.",
            "flesh": "Blanca e inmutable (incluso bajo la cutícula), algo más esponjosa que en B. aereus y muy dulce (suele ser atacada pronto por larvas)."
        },
        "confusions": [
            {
                "mushroomId": "tylopilus_felleus",
                "scientificName": "Tylopilus felleus",
                "commonName": "Boleto amargo (Behazun-onddo)",
                "riskLevel": "non_edible",
                "difference": "Poros rosados y carne muy amarga."
            }
        ]
    },
    {
        "id": "caloboletus_calopus",
        "scientificName": "Caloboletus calopus (Boletus calopus)",
        "spanishName": "Boleto de pie bonito",
        "basqueName": "Onddo hankagorria",
        "family": "Boletaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "Hayedos y bosques de coníferas en suelos ácidos de montaña.",
        "summary": "Boleto vistoso de sombrero gris pálido, poros amarillos (nunca rojos) y pie rojo carmín con retículo; incomestible por su amargor.",
        "morphology": {
            "cap": "De 7 a 18 cm, hemisférico, cutícula seca y aterciopelada de color gris gamuza o crema pálido.",
            "hymenium": "Poros pequeños de color amarillo limón que azulean al presionarlos.",
            "stem": "Robusto, amarillo arriba y rojo carmín vivo en los dos tercios inferiores, decorado con un retículo claro.",
            "flesh": "Amarillo pálido que azulea moderadamente al corte; sabor fuertemente amargo."
        },
        "confusions": [
            {
                "mushroomId": "rubroboletus_satanas",
                "scientificName": "Rubroboletus satanas",
                "commonName": "Boleto de Satanás (Satan onddoa)",
                "riskLevel": "toxic",
                "difference": "El Boleto de Satanás tiene los poros de color rojo sangre o naranja rojizo, mientras que C. calopus los tiene amarillos."
            }
        ]
    },
    {
        "id": "calocybe_gambosa",
        "scientificName": "Calocybe gambosa",
        "spanishName": "Perretxiko / Seta de San Jorge / Lansarón",
        "basqueName": "Udaberriko ziza / Perretxikoa",
        "family": "Lyophyllaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera (Marzo - Junio)",
        "habitat": "Praderas de montaña, pastizales junto a espinos albares (elorri zuri), endrinos y claros herbosos calizos formando corros de brujas.",
        "summary": "La seta más emblemática de la primavera vasca (da nombre a 'ZizAI' por su nombre 'Udaberriko ziza'), de carne compacta blanca y penetrante olor a harina fresca.",
        "morphology": {
            "cap": "De 4 a 12 cm, carnoso, hemisférico a convexo con el margen muy enrollado e irregular, color blanco marfil a crema gamuza.",
            "hymenium": "Láminas muy apretadas, estrechas y escotadas, de color blanco a crema pálido.",
            "stem": "Corto, robusto y macizo, blanco o crema, sin anillo ni volva.",
            "flesh": "Muy espesa, firme y blanca. Olor y sabor intensos e inconfundibles a harina recién molida."
        },
        "confusions": [
            {
                "mushroomId": "entoloma_sinuatum",
                "scientificName": "Entoloma sinuatum (Entoloma lividum)",
                "commonName": "Seta engañosa / Perfidia (Ziza maltzurra)",
                "riskLevel": "toxic",
                "difference": "Aunque también huele a harina, tiene láminas más separadas que viran al amarillo y luego al rosa salmón, y suele salir más tarde."
            },
            {
                "mushroomId": "inocybe_erubescens",
                "scientificName": "Inocybe erubescens (Inocybe patouillardii)",
                "commonName": "Inocibe enrojeciente (Inozibe hiltzailea)",
                "riskLevel": "deadly",
                "difference": "Sombrero cónico fibrilloso que se mancha de rojo ladrillo al roce o con la edad y NO huele a harina fresca."
            }
        ]
    },
    {
        "id": "cantharellus_cibarius",
        "scientificName": "Cantharellus cibarius",
        "spanishName": "Rebozuelo / Cabrilla / Rossinyol",
        "basqueName": "Ziza horia / Saltsa-perretxiko horia",
        "family": "Cantharellaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Finales de Primavera, Verano y Otoño",
        "habitat": "Bosques de frondosas (hayedos, robledales, castañares) y coníferas entre el musgo.",
        "summary": "Clásico imprescindible de los bosques vascos: color amarillo yema de huevo, pliegues decurrentes en lugar de láminas y aroma afrutado a albaricoque.",
        "morphology": {
            "cap": "De 3 a 10 cm, primero convexo y pronto embudado con el margen lobulado y ondulado, color amarillo oro o yema de huevo.",
            "hymenium": "Formado por pliegues gruesos, bifurcados y muy decurrentes por el pie (no son láminas verdaderas separables), del mismo color amarillo.",
            "stem": "Macizo, liso, estrechado hacia la base, concoloro al sombrero.",
            "flesh": "Firme y fibrosa, blanca-amarillenta (nunca la atacan las larvas), con delicioso olor afrutado a melocotón o albaricoque."
        },
        "confusions": [
            {
                "mushroomId": "omphalotus_olearius",
                "scientificName": "Omphalotus olearius",
                "commonName": "Seta de olivo (Ziza-hori faltsua)",
                "riskLevel": "toxic",
                "difference": "Crece en ramilletes sobre madera (tocones de robles, castaños u olivos), es de color naranja cobrizo y tiene láminas verdaderas apretadas, no pliegues."
            },
            {
                "mushroomId": "hygrophoropsis_aurantiaca",
                "scientificName": "Hygrophoropsis aurantiaca",
                "commonName": "Falso rebozuelo (Ziza-hori faltsua)",
                "riskLevel": "non_edible",
                "difference": "Tiene láminas verdaderas delgadas y bifurcadas de color naranja vivo y carne blanda e inodora."
            }
        ]
    },
    {
        "id": "cantharellus_subpruinosus",
        "scientificName": "Cantharellus pallens (Cantharellus subpruinosus)",
        "spanishName": "Rebozuelo pruinoso",
        "basqueName": "Ziza hori pruinaduna",
        "family": "Cantharellaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera a Otoño",
        "habitat": "Robledales, hayedos y encinares.",
        "summary": "Muy cercano a C. cibarius pero más robusto y carnoso, recubierto de una característica pruina blanquecina sobre el fondo amarillo.",
        "morphology": {
            "cap": "De 4 a 12 cm, carnoso, amarillo yema recubierto de una fina capa blanquecina aterciopelada (pruina) especialmente en ejemplares jóvenes.",
            "hymenium": "Pliegues gruesos decurrentes, primero blanquecino-amarillentos y luego amarillo vivo, que se manchan de ocre-herrumbre al roce.",
            "stem": "Grueso y corto, blanco-amarillento que amarillea/oxida al tocarlo.",
            "flesh": "Espesa, blanca, con aroma afrutado."
        },
        "confusions": [
            {
                "mushroomId": "omphalotus_olearius",
                "scientificName": "Omphalotus olearius",
                "commonName": "Seta de olivo (Ziza-hori faltsua)",
                "riskLevel": "toxic",
                "difference": "Omphalotus olearius crece sobre madera y posee láminas verdaderas en vez de pliegues."
            }
        ]
    },
    {
        "id": "chalciporus_piperatus",
        "scientificName": "Chalciporus piperatus",
        "spanishName": "Boleto picante",
        "basqueName": "Onddo pipermina",
        "family": "Boletaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "Bosques de coníferas y frondosas, a menudo junto a Amanita muscaria.",
        "summary": "Pequeño boleto de poros color canela-rojizo y pie amarillo azufre en la base con un sabor intensamente picante como la pimienta.",
        "morphology": {
            "cap": "De 3 a 7 cm, convexo, pardo cobrizo o canela brillante.",
            "hymenium": "Poros angulosos, anchos, de color canela a rojo herrumbre.",
            "stem": "Delgado, color canela con la base y el micelio de un llamativo amarillo azufre.",
            "flesh": "Amarilla en el pie, inodora pero de sabor muy picante."
        },
        "confusions": [
            {
                "mushroomId": "suillus_bovinus",
                "scientificName": "Suillus bovinus",
                "commonName": "Boleto bovino (Behi-onddoa)",
                "riskLevel": "caution",
                "difference": "Tiene poros amarillo-oliváceos y sabor dulce suave."
            }
        ]
    },
    {
        "id": "chlorophyllum_rhacodes",
        "scientificName": "Chlorophyllum rhacodes (Macrolepiota rhacodes)",
        "spanishName": "Parasol enrojeciente / Apagador menor",
        "basqueName": "Galanperna gorrizta",
        "family": "Agaricaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Finales de Verano y Otoño",
        "habitat": "Bosques ricos en humus, pinares, parques y bordes de caminos.",
        "summary": "Parecida a la Macrolepiota procera pero de pie liso (sin dibujo atigrado) y cuya carne enrojece al corte; puede causar alergias digestivas.",
        "morphology": {
            "cap": "De 8 a 18 cm, cubierto de gruesas escamas poligonales pardas levantadas sobre fondo blanquecino.",
            "hymenium": "Láminas libres, blancas que se manchan de rojizo al roce.",
            "stem": "Cilíndrico con bulbo basal grueso, superficie LISA (sin bandas atigradas) y anillo doble móvil.",
            "flesh": "Blanca que vira rápidamente al naranja-azafrán y rojo al cortarla."
        },
        "confusions": [
            {
                "mushroomId": "macrolepiota_procera",
                "scientificName": "Macrolepiota procera",
                "commonName": "Parasol / Galamperna (Galanperna)",
                "riskLevel": "excellent",
                "difference": "Macrolepiota procera tiene el pie claramente atigrado con bandas en zigzag y su carne no enrojece tan intensamente."
            },
            {
                "mushroomId": "lepiota_brunneoincarnata",
                "scientificName": "Lepiota brunneoincarnata",
                "commonName": "Lepiota pardo-rojiza mortal",
                "riskLevel": "deadly",
                "difference": "Las Lepiotas mortales son de pequeño tamaño (< 6 cm de diámetro de sombrero); nunca recolectar ejemplares menores de 10 cm."
            }
        ]
    }
]
