# -*- coding: utf-8 -*-
"""Parte 4 del catálogo micológico de ZizAI (Especies M - X)."""

SPECIES_PART_4 = [
    {
        "id": "macrolepiota_procera",
        "scientificName": "Macrolepiota procera",
        "spanishName": "Parasol / Galamperna / Apagador",
        "basqueName": "Galanperna / Kukumelo luzea",
        "family": "Agaricaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Verano y Otoño",
        "habitat": "Claros herbosos de bosque, praderas, brezales, pinares y bordes de caminos.",
        "summary": "La majestuosa 'Galanperna', inconfundible por su gran porte de sombrilla escamosa, su anillo doble corredizo y su pie atigrado en zigzag.",
        "morphology": {
            "cap": "De 12 a 30 cm, ovoide como un palillo de tambor de joven y luego extendido con mamelón central oscuro y gruesas escamas pardas concéntricas.",
            "hymenium": "Láminas libres (separadas del pie por un collar), muy apretadas y ventrudas, blanco-crema.",
            "stem": "Muy alto (15-40 cm), hueco y fibroso, bulboso en la base, decorado con bandas transversales pardas ('piel de serpiente' o atigrado) y un gran anillo doble móvil.",
            "flesh": "Tierna y blanca en el sombrero (el pie es leñoso y se desecha), con exquisito olor y sabor a avellana. Ideal a la plancha o empanada."
        },
        "confusions": [
            {
                "mushroomId": "lepiota_brunneoincarnata",
                "scientificName": "Lepiota brunneoincarnata",
                "commonName": "Lepiota pardo-rojiza mortal (Galanperna txiki hilgarria)",
                "riskLevel": "deadly",
                "difference": "Las Lepiotas mortales son diminutas (sombrero menor de 6 cm). Nunca recolectar parasoles menores de 10 cm de sombrero."
            },
            {
                "mushroomId": "chlorophyllum_rhacodes",
                "scientificName": "Chlorophyllum rhacodes",
                "commonName": "Parasol enrojeciente (Galanperna gorrizta)",
                "riskLevel": "caution",
                "difference": "Tiene el pie totalmente liso (sin dibujo atigrado) y su carne enrojece intensamente al corte."
            }
        ]
    },
    {
        "id": "marasmius_oreades",
        "scientificName": "Marasmius oreades",
        "spanishName": "Senderuela / Carrerilla / Seta de corro",
        "basqueName": "Marasmio jangarria / Sorgin-korroko ziza",
        "family": "Marasmiaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera, Verano y Otoño tras las lluvias",
        "habitat": "Praderas, pastizales de montaña y céspedes formando marcados 'corros de brujas' donde la hierba crece más verde.",
        "summary": "Pequeña joya aromática de los prados vascos y pirenaicos, de pie tenaz que se puede retorcer sin partirse y láminas muy espaciadas.",
        "morphology": {
            "cap": "De 2 a 6 cm, acampanado a plano con un mamelón obtuso central constante; higrófano, color avellana-cuero en húmedo y crema gamuza en seco.",
            "hymenium": "Láminas libres, gruesas y MUY ESPACIADAS entre sí, de color crema pálido.",
            "stem": "Delgado, cilíndrico, muy elástico y tenaz (se retuerce una vuelta entera sin romperse; se desecha al cocinar).",
            "flesh": "Delgada, blanquecina, imputrescible (se seca sin pudrirse y revive con la lluvia), con agradable aroma a almendras amargas/heno."
        },
        "confusions": [
            {
                "mushroomId": "clitocybe_dealbata",
                "scientificName": "Clitocybe rivulosa (Clitocybe dealbata)",
                "commonName": "Clitocibe blanco mortal (Klitokibe zuria)",
                "riskLevel": "deadly",
                "difference": "¡Atención! Crece en los mismos prados, pero es blanquecino-escarchado, deprimido (sin mamelón), con láminas apretadas decurrentes y pie quebradizo."
            }
        ]
    },
    {
        "id": "meripilus_giganteus",
        "scientificName": "Meripilus giganteus",
        "spanishName": "Políporo gigante",
        "basqueName": "Ardagai erraldoia",
        "family": "Meripilaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "En la base y raíces de grandes hayas (Fagus sylvatica) y robles.",
        "summary": "Inmensa roseta de abanicos pardos en la base de las hayas cuyos poros blancos se tiñen de negro al tocarlos.",
        "morphology": {
            "cap": "Roseta multipílea que puede alcanzar hasta 80 cm y varios kilos, formada por grandes abanicos zonados de color pardo castaño.",
            "hymenium": "Poros muy pequeños de color blanco-crema que ennegrecen rápidamente al roce o presión.",
            "stem": "Base común gruesa y tuberculosa.",
            "flesh": "Fibrosa y coriácea, blanca que vira al rosa y luego negro al corte, de sabor ácido."
        },
        "confusions": [
            {
                "mushroomId": "grifola_frondosa",
                "scientificName": "Grifola frondosa",
                "commonName": "Maitake (Gaztainondo-ardagaia)",
                "riskLevel": "excellent",
                "difference": "Grifola frondosa tiene sombreros mucho más pequeños en espátula y sus poros NO ennegrecen al tocarlos."
            }
        ]
    },
    {
        "id": "morchella_conica",
        "scientificName": "Morchella elata (Morchella conica)",
        "spanishName": "Colmenilla cónica / Cagarria negra",
        "basqueName": "Karraspina konikoa",
        "family": "Morchellaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Primavera (Marzo - Mayo)",
        "habitat": "Bosques de coníferas de montaña, choperas, terrenos removidos y zonas quemadas tras incendios.",
        "summary": "Exquisita colmenilla de mitra cónica oscura; como todas las Morchellas, es TÓXICA EN CRUDO y exige deshidratación previa o cocción prolongada.",
        "morphology": {
            "cap": "Mitra cónica hueca de 4 a 10 cm, con costillas longitudinales paralelas casi negras que delimitan alvéolos alargados pardo-oliváceos.",
            "hymenium": "Tapiza el interior de los alvéolos profundos.",
            "stem": "Cilíndrico, completamente hueco, blanquecino-ocráceo cubierto de gránulos furfuráceos.",
            "flesh": "Cérea y frágil. Contiene hemolisinas termolábiles: obligatorio desecar o cocinar más de 20 minutos a alta temperatura."
        },
        "confusions": [
            {
                "mushroomId": "gyromitra_esculenta",
                "scientificName": "Gyromitra esculenta",
                "commonName": "Bonete mortal (Muino-ziza)",
                "riskLevel": "deadly",
                "difference": "Gyromitra esculenta tiene aspecto de cerebro arrugado pardo-rojizo, sin alvéolos abiertos de panal."
            }
        ]
    },
    {
        "id": "morchella_esculenta",
        "scientificName": "Morchella esculenta",
        "spanishName": "Colmenilla redonda / Cagarria / Múrgula",
        "basqueName": "Karraspina arrunta",
        "family": "Morchellaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Primavera (Abril - Mayo)",
        "habitat": "Bosques de ribera (fresnos, olmos, chopos), manzanos viejos y claros herbosos calizos.",
        "summary": "Cotizadísima seta primaveral con sombrero redondo alveolado como un panal de abejas color miel; requiere siempre cocinado completo o secado previo.",
        "morphology": {
            "cap": "Mitra globosa u ovoide de 4 a 12 cm, completamente hueca, con profundos alvéolos irregulares como un panal de color ocre miel o rubio.",
            "hymenium": "En el interior de las cavidades alveolares.",
            "stem": "Cilíndrico, hueco, engrosado en la base, blanco-crema y granuloso.",
            "flesh": "Delgada y frágil, muy aromática. Tóxica en crudo o poco cocinada (síndrome hemolítico y cerebeloso si no se cocina bien)."
        },
        "confusions": [
            {
                "mushroomId": "gyromitra_esculenta",
                "scientificName": "Gyromitra esculenta",
                "commonName": "Bonete mortal (Muino-ziza)",
                "riskLevel": "deadly",
                "difference": "El bonete tiene pliegues cerebriformes cerrados de color castaño rojizo en lugar de celdillas de panal."
            }
        ]
    },
    {
        "id": "mycena_pura",
        "scientificName": "Mycena pura",
        "spanishName": "Micena pura",
        "basqueName": "Mizena arrosa",
        "family": "Mycenaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Primavera a Otoño",
        "habitat": "Muy frecuente sobre hojarasca de hayedos, robledales y pinares.",
        "summary": "Pequeña seta de tonos rosados o lila-violáceos con un inconfundible olor y sabor a rábano crudo.",
        "morphology": {
            "cap": "De 2 a 5 cm, acampanado a aplanado con mamelón y margen estriado por transparencia, color rosa lila o violáceo pálido.",
            "hymenium": "Láminas adnatas o escotadas, ventrudas, blanquecinas a rosa-liláceas.",
            "stem": "Hueco, frágil, liso, del mismo color que el sombrero.",
            "flesh": "Acuosa, con fuerte olor a rábano o patata cruda. Contiene muscarina."
        },
        "confusions": [
            {
                "mushroomId": "laccaria_amethystina",
                "scientificName": "Laccaria amethystina",
                "commonName": "Lacaria amatista (Lakaria ubela)",
                "riskLevel": "good",
                "difference": "Laccaria amethystina tiene láminas muy gruesas y separadas de color violeta oscuro, pie fibroso y NO huele a rábano."
            }
        ]
    },
    {
        "id": "neoboletus_erythropus",
        "scientificName": "Neoboletus luridiformis (Boletus erythropus)",
        "spanishName": "Boleto de pie rojo / Mataparientes",
        "basqueName": "Onddo hankagorria",
        "family": "Boletaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Primavera, Verano y Otoño",
        "habitat": "Hayedos, robledales y bosques de coníferas sobre suelos ácidos.",
        "summary": "Excelente boleto tras cocinarse bien (tóxico en crudo), de sombrero pardo aterciopelado, poros rojos y pie punteado de rojo SIN retículo.",
        "morphology": {
            "cap": "De 7 a 20 cm, hemisférico y carnoso, cutícula seca y aterciopelada de color marrón castaño oscuro.",
            "hymenium": "Poros pequeños y redondos, de color rojo anaranjado a rojo sangre que azulean al instante al tocarlos.",
            "stem": "Grueso y ventrudo, amarillo cubierto de finísimos puntos granulosos rojos (NUNCA tiene red o retículo).",
            "flesh": "Amarillo vivo que al corte vira en un segundo al azul marino oscuro (el color azul desaparece por completo al cocinarlo)."
        },
        "confusions": [
            {
                "mushroomId": "rubroboletus_satanas",
                "scientificName": "Rubroboletus satanas",
                "commonName": "Boleto de Satanás (Satan onddoa)",
                "riskLevel": "toxic",
                "difference": "El Boleto de Satanás tiene el sombrero blanquecino o gris tiza (nunca marrón castaño), retículo en el pie y olor desagradable."
            },
            {
                "mushroomId": "suillellus_luridus",
                "scientificName": "Suillellus luridus",
                "commonName": "Boleto cetrino (Onddo zikina)",
                "riskLevel": "caution",
                "difference": "Suillellus luridus posee un retículo o red alargada muy marcada en el pie."
            }
        ]
    },
    {
        "id": "omphalotus_olearius",
        "scientificName": "Omphalotus olearius",
        "spanishName": "Seta de olivo",
        "basqueName": "Ziza-hori faltsua / Olibondo-ziza",
        "family": "Omphalotaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Verano y Otoño",
        "habitat": "En ramilletes sobre tocones, cepas y raíces de robles, castaños, encinas y olivos.",
        "summary": "Peligrosa seta tóxica de intenso color naranja cobrizo que crece sobre madera y cuyas láminas son bioluminiscentes en la oscuridad.",
        "morphology": {
            "cap": "De 5 a 15 cm, convexo y pronto embudado, fibrilloso, de color naranja vivo a pardo-rojizo cobrizo.",
            "hymenium": "Láminas verdaderas muy apretadas y profundamente decurrentes, amarillo-anaranjado brillante.",
            "stem": "Largo, fibroso, atenuado en la base y unido en haces con otros ejemplares sobre madera.",
            "flesh": "Fibrosa, naranja-azafrán. Contiene iludina S y provoca intoxicaciones gastrointestinales muy severas."
        },
        "confusions": [
            {
                "mushroomId": "cantharellus_cibarius",
                "scientificName": "Cantharellus cibarius",
                "commonName": "Rebozuelo (Ziza horia)",
                "riskLevel": "excellent",
                "difference": "El rebozuelo crece en el suelo (no en ramilletes sobre madera), tiene pliegues gruesos en lugar de láminas finas y carne blanca en el interior."
            }
        ]
    },
    {
        "id": "paxillus_involutus",
        "scientificName": "Paxillus involutus",
        "spanishName": "Paxilo enrollado",
        "basqueName": "Orri-bira hiltzailea",
        "family": "Paxillaceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Verano y Otoño",
        "habitat": "Muy común bajo abedules, robles, hayas y coníferas en zonas húmedas.",
        "summary": "Seta con el borde del sombrero fuertemente enrollado y acanalado; provoca el síndrome paxílico (anemia hemolítica inmunitaria potencialmente mortal).",
        "morphology": {
            "cap": "De 5 a 15 cm, deprimido en el centro con el margen grueso, afieltrado y muy enrollado hacia dentro (involuto); color pardo ocre a herrumbre.",
            "hymenium": "Láminas apretadas, decurrentes, ocre amarillentas que se manchan de pardo oscuro al presionarlas.",
            "stem": "Corto, central o algo excéntrico, concoloro.",
            "flesh": "Gruesa y blanda, amarillenta que pardece al corte. Antiguamente consumida en Europa del Este, hoy se sabe que causa hemólisis letal acumulativa."
        },
        "confusions": [
            {
                "mushroomId": "lactarius_deliciosus",
                "scientificName": "Lactarius deliciosus",
                "commonName": "Níscalo (Esnegorria)",
                "riskLevel": "excellent",
                "difference": "Paxillus involutus no segrega látex al corte y sus láminas son blandas y pardas, nunca naranjas."
            }
        ]
    },
    {
        "id": "phallus_impudicus",
        "scientificName": "Phallus impudicus",
        "spanishName": "Falo hediondo / Satirión",
        "basqueName": "Zakil-perretxikoa / Asto-perretxikoa",
        "family": "Phallaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "Hayedos, robledales y pinares húmedos ricos en madera descompuesta.",
        "summary": "Inconfundible por su forma fálica y su pestilente olor a carroña que se detecta a decenas de metros en el bosque.",
        "morphology": {
            "cap": "Cabeza cónica acampanada con celdillas poligonales recubiertas de una gleba mucilaginosa verde oliva oscuro.",
            "hymenium": "En la gleba viscosa externa que es devorada rápidamente por las moscas.",
            "stem": "De 10 a 20 cm, cilíndrico, hueco, blanco y esponjoso, emergiendo de un 'huevo' basal gelatinoso blanquecino.",
            "flesh": "Esponjosa y frágil; olor fétido insoportable en el adulto."
        },
        "confusions": [
            {
                "mushroomId": "morchella_esculenta",
                "scientificName": "Morchella esculenta",
                "commonName": "Colmenilla (Karraspina)",
                "riskLevel": "caution",
                "difference": "Cuando las moscas limpian la gleba quedan celdillas blancas, pero Phallus impudicus tiene volva basal y olor nauseabundo."
            }
        ]
    },
    {
        "id": "pleurotus_eryngii",
        "scientificName": "Pleurotus eryngii",
        "spanishName": "Seta de cardo",
        "basqueName": "Kardu-ziza",
        "family": "Pleurotaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño y Primavera templada",
        "habitat": "Praderas secas, eriales, cunetas y pastizales calizos de Álava, Navarra y resto de España, creciendo sobre las raíces del cardo corredor (Eryngium campestre).",
        "summary": "Una de las setas más finas y cotizadas de la Península Ibérica, parásita de las raíces del cardo corredor.",
        "morphology": {
            "cap": "De 4 a 12 cm, convexo a plano-deprimido con margen enrollado, cutícula lisa y mate de color pardo bistre, gris-marrón o crema tostado.",
            "hymenium": "Láminas muy decurrentes, espaciadas, de color blanco a crema.",
            "stem": "Frecuentemente excéntrico o lateral, corto y macizo, atenuado en la base unida a la raíz del cardo, blanco.",
            "flesh": "Elástica, consistente, blanca pura, de olor suave y sabor extraordinario a la plancha."
        },
        "confusions": [
            {
                "mushroomId": "clitocybe_dealbata",
                "scientificName": "Clitocybe rivulosa (Clitocybe dealbata)",
                "commonName": "Clitocibe blanco mortal (Klitokibe zuria)",
                "riskLevel": "deadly",
                "difference": "Crece también en pastizales, pero es pequeño, blanco escarchado y no nace sobre raíces de cardo."
            }
        ]
    },
    {
        "id": "pleurotus_ostreatus",
        "scientificName": "Pleurotus ostreatus",
        "spanishName": "Seta de ostra / Belarri landua",
        "basqueName": "Belarri landua / Ostra-ziza",
        "family": "Pleurotaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño e Invierno",
        "habitat": "En grandes grupos imbricados sobre troncos y tocones de hayas, chopos, sauces y robles.",
        "summary": "La popular seta de ostra silvestre, que crece en repisas escalonadas sobre troncos de hayas y árboles de ribera durante los meses fríos.",
        "morphology": {
            "cap": "De 6 a 20 cm, en forma de concha u ostra asimétrica, liso, de color gris pizarra, pardo violáceo o marrón gamuza.",
            "hymenium": "Láminas blancas a crema, muy decurrentes hasta la base del pie.",
            "stem": "Muy corto, lateral y oblicuo, velloso en la base, unido en ramilletes.",
            "flesh": "Blanca, tierna en ejemplares jóvenes y algo tenaz en los viejos, de sabor muy agradable."
        },
        "confusions": [
            {
                "mushroomId": "omphalotus_olearius",
                "scientificName": "Omphalotus olearius",
                "commonName": "Seta de olivo (Olibondo-ziza)",
                "riskLevel": "toxic",
                "difference": "Omphalotus olearius es de color naranja cobrizo brillante en sombrero, láminas y carne."
            }
        ]
    },
    {
        "id": "ramaria_botrytis",
        "scientificName": "Ramaria botrytis",
        "spanishName": "Pie de rata reina / Coliflor rosa",
        "basqueName": "Atzapar puntagorria",
        "family": "Gomphaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Otoño",
        "habitat": "Hayedos y robledales de montaña.",
        "summary": "La única Ramaria recomendable (solo ejemplares jóvenes y desechando las puntas), con aspecto de coliflor blanca y puntas de color rosa-púrpura.",
        "morphology": {
            "cap": "Carpóforo coraliforme de 8 a 18 cm con grueso tronco blanco del que salen ramas cortas terminadas en puntas de color rojo vino o rosa púrpura.",
            "hymenium": "Recubre la superficie externa de las ramificaciones.",
            "stem": "Base gruesa, maciza y carnosa de color blanco.",
            "flesh": "Blanca, quebradiza, con suave aroma afrutado."
        },
        "confusions": [
            {
                "mushroomId": "ramaria_formosa",
                "scientificName": "Ramaria formosa",
                "commonName": "Pie de rata hermoso (Atzapar ederra)",
                "riskLevel": "toxic",
                "difference": "Ramaria formosa tiene las ramas de color rosa salmón y las puntas de color AMARILLO limón; es fuertemente purgante."
            }
        ]
    },
    {
        "id": "ramaria_formosa",
        "scientificName": "Ramaria formosa",
        "spanishName": "Pie de rata hermoso / Coral tóxico",
        "basqueName": "Atzapar ederra",
        "family": "Gomphaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Verano y Otoño",
        "habitat": "Hayedos y robledales.",
        "summary": "Hongo coraliforme tricolor (base blanca, ramas rosa salmón y puntas amarillo limón) que provoca diarreas severas.",
        "morphology": {
            "cap": "Arbusto coralino de 8 a 20 cm con ramas erguidas de color rosa-anaranjado o salmón rematadas por puntas amarillo citrino.",
            "hymenium": "En la superficie de las ramas.",
            "stem": "Tronco basal carnoso blanquecino-rosado.",
            "flesh": "Blanca y quebradiza, de sabor amargo-acre. Provoca gastroenteritis severa."
        },
        "confusions": [
            {
                "mushroomId": "ramaria_botrytis",
                "scientificName": "Ramaria botrytis",
                "commonName": "Pie de rata reina (Atzapar puntagorria)",
                "riskLevel": "good",
                "difference": "Ramaria botrytis tiene ramas blancas y puntas rojo vino (nunca amarillas)."
            }
        ]
    },
    {
        "id": "rubroboletus_satanas",
        "scientificName": "Rubroboletus satanas (Boletus satanas)",
        "spanishName": "Boleto de Satanás",
        "basqueName": "Satan onddoa / Etsai-onddoa",
        "family": "Boletaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Verano y principios de Otoño",
        "habitat": "Bosques de frondosas (robledales, encinares y hayedos soleados) EXCLUSIVAMENTE en suelos calizos.",
        "summary": "El célebre Boleto de Satanás: enorme sombrero blanco-grisáceo como tiza, poros rojos, pie obeso rojo con red y olor carroñero al madurar.",
        "morphology": {
            "cap": "De 10 a 30 cm, muy grueso y pesado, hemisférico, cutícula mate de color blanco sucio, gris tiza o masilla.",
            "hymenium": "Poros pequeños amarillos al nacer pero enseguida rojo sangre o rojo carmín vivo, que azulean al tocarlos.",
            "stem": "Muy corto y obeso (en forma de barril), amarillo arriba y rojo carmín en el centro con un fino retículo rojo.",
            "flesh": "Blanquecina o amarillo pálido que azulea moderadamente al corte; olor desagradable a carne pasada en ejemplares adultos. Muy tóxico."
        },
        "confusions": [
            {
                "mushroomId": "neoboletus_erythropus",
                "scientificName": "Neoboletus luridiformis (Boletus erythropus)",
                "commonName": "Boleto de pie rojo (Onddo hankagorria)",
                "riskLevel": "caution",
                "difference": "Neoboletus luridiformis tiene el sombrero marrón oscuro aterciopelado (nunca blanco-gris), pie punteado sin red y carne amarillo vivo."
            }
        ]
    },
    {
        "id": "russula_aurea",
        "scientificName": "Russula aurea (Russula aurata)",
        "spanishName": "Rúsula dorada",
        "basqueName": "Urre-gibelurdina",
        "family": "Russulaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Verano y Otoño",
        "habitat": "Bosques de frondosas (robledales y hayedos) y coníferas.",
        "summary": "Una de las Russulas más bellas y sabrosas, reconocible por el filo de sus láminas teñido de color amarillo oro brillante.",
        "morphology": {
            "cap": "De 5 a 10 cm, convexo a plano-deprimido, rojo anaranjado o rojo cobre con zonas amarillo oro brillante.",
            "hymenium": "Láminas libres a adnatas, crema pálido pero con la arista (el borde de la lámina) de un vivo color amarillo limón/oro.",
            "stem": "Cilíndrico, quebradizo como tiza, blanco esfumado de amarillo limón.",
            "flesh": "Granulosa, blanca (amarilla bajo la cutícula), de sabor completamente dulce."
        },
        "confusions": [
            {
                "mushroomId": "russula_emetica",
                "scientificName": "Russula emetica",
                "commonName": "Rúsula emética (Gibelgorri oka-eragilea)",
                "riskLevel": "toxic",
                "difference": "Russula emetica tiene láminas y pie de color blanco puro (sin tonos amarillo oro) y su carne es abrasadoramente picante al probar una pizca."
            }
        ]
    },
    {
        "id": "russula_cyanoxantha",
        "scientificName": "Russula cyanoxantha",
        "spanishName": "Carbonera / Urretxa",
        "basqueName": "Urretxa / Gibelurdina",
        "family": "Russulaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Finales de Primavera, Verano y Otoño",
        "habitat": "Muy abundante en hayedos, robledales y castañares del País Vasco.",
        "summary": "La 'Gibelurdina' o 'Urretxa' por excelencia en Euskadi: la única Russula cuyas láminas blancas son elásticas ('lardáceas') y no se rompen al pasar el dedo.",
        "morphology": {
            "cap": "De 5 a 15 cm, carnoso, convexo a deprimido, cutícula húmeda con mezcla de tonos violeta, púrpura, gris pizarra y verde oliva.",
            "hymenium": "Láminas apretadas, blancas, de consistencia flexible y grasienta al tacto (NO se quiebran al pasar la yema del dedo como en el resto de Russulas).",
            "stem": "Robusto, cilíndrico, blanco puro y quebradizo como una tiza.",
            "flesh": "Dura, granulosa, blanca (violácea bajo la cutícula), de sabor suave a avellana. Reacciona en verde al sulfato de hierro."
        },
        "confusions": [
            {
                "mushroomId": "amanita_phalloides",
                "scientificName": "Amanita phalloides",
                "commonName": "Oronja verde (Hiltzaile berdea)",
                "riskLevel": "deadly",
                "difference": "En formas verdosas de Gibelurdina: recordar que ninguna Russula tiene jamás anillo ni volva, y su pie se parte como una tiza."
            }
        ]
    },
    {
        "id": "russula_delica",
        "scientificName": "Russula delica",
        "spanishName": "Rúsula blanca",
        "basqueName": "Gibelzuria",
        "family": "Russulaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "Bosques de frondosas y coníferas.",
        "summary": "Gran rúsula blanca embudada que suele salir semienterrada levantando la hojarasca del bosque.",
        "morphology": {
            "cap": "De 7 a 16 cm, duro, embudado con el borde enrollado, blanco sucio manchado de tierra y ocre.",
            "hymenium": "Láminas bastante espaciadas, decurrentes, blancas con un ligero reflejo verde-azulado en la unión con el pie.",
            "stem": "Muy corto y grueso, blanco.",
            "flesh": "Muy dura, granulosa, blanca (SIN látex al corte), de sabor algo acre y olor que recuerda al pescado en adultos."
        },
        "confusions": [
            {
                "mushroomId": "lactarius_piperatus",
                "scientificName": "Lactarius piperatus",
                "commonName": "Lactario picante (Esneki pipermina)",
                "riskLevel": "non_edible",
                "difference": "Lactarius piperatus tiene láminas muchísimo más apretadas y exuda abundante leche blanca picante al cortarlo."
            }
        ]
    },
    {
        "id": "russula_emetica",
        "scientificName": "Russula emetica",
        "spanishName": "Rúsula emética / Seta de la risa",
        "basqueName": "Gibelgorri oka-eragilea",
        "family": "Russulaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Verano y Otoño",
        "habitat": "Turberas, zonas encharcadas con musgo Sphagnum en pinares y hayedos húmedos.",
        "summary": "Pequeña rúsula de sombrero rojo cereza brillante y láminas blanco puro cuya carne pica como guindilla en la punta de la lengua.",
        "morphology": {
            "cap": "De 4 a 9 cm, convexo a aplanado, cutícula viscosa y separable de un llamativo color rojo escarlata o rojo cereza vivo.",
            "hymenium": "Láminas libres a adnatas, espaciadas, de color blanco puro.",
            "stem": "Cilíndrico, esponjoso y frágil, blanco puro.",
            "flesh": "Blanca y frágil, de sabor abrasadoramente picante. Provoca vómitos y gastroenteritis."
        },
        "confusions": [
            {
                "mushroomId": "russula_aurea",
                "scientificName": "Russula aurea",
                "commonName": "Rúsula dorada (Urre-gibelurdina)",
                "riskLevel": "excellent",
                "difference": "Russula aurea tiene tonos amarillo oro en el borde de las láminas y el sombrero, y su carne es completamente dulce."
            }
        ]
    },
    {
        "id": "russula_vesca",
        "scientificName": "Russula vesca",
        "spanishName": "Rúsula comestible",
        "basqueName": "Gibelurdin haragitsua",
        "family": "Russulaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Finales de Primavera, Verano y Otoño",
        "habitat": "Robledales, hayedos y castañares.",
        "summary": "Excelente rúsula de color rosa-vinoso o jamón cocido cuya cutícula se queda corta en el borde dejando ver la carne blanca ('enseña los dientes').",
        "morphology": {
            "cap": "De 5 a 11 cm, hemisférico a plano-deprimido, color rosa pardo o carne de jamón; la cutícula se retrae 1-2 mm en el margen dejando ver el borde blanco.",
            "hymenium": "Láminas apretadas, blancas con pequeñas manchas color herrumbre con la edad.",
            "stem": "Firme, atenuado en la base, blanco con manchas pardas abajo.",
            "flesh": "Muy dura y crujiente, blanca, de delicioso sabor dulce a avellana."
        },
        "confusions": [
            {
                "mushroomId": "russula_cyanoxantha",
                "scientificName": "Russula cyanoxantha",
                "commonName": "Carbonera (Urretxa)",
                "riskLevel": "excellent",
                "difference": "Ambas son excelentes; R. cyanoxantha tiene tonos más violáceos/verdosos y láminas elásticas."
            }
        ]
    },
    {
        "id": "russula_virescens",
        "scientificName": "Russula virescens",
        "spanishName": "Gorro verde / Rúsula verde",
        "basqueName": "Gibelurdin ezkata-berdea",
        "family": "Russulaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Verano y principios de Otoño",
        "habitat": "Robledales, hayedos y castañares templados.",
        "summary": "Considerada la mejor de todas las Russulas: sombrero verde cardenillo cuarteado en placas poligonales como un melón.",
        "morphology": {
            "cap": "De 6 a 15 cm, globoso a extendido, cutícula seca y mate de color verde cardenillo o verde pistacho que se agrieta en placas poligonales sobre fondo blanco.",
            "hymenium": "Láminas libres, apretadas, blanco-crema.",
            "stem": "Grueso, macizo y quebradizo como tiza, blanco pruinoso.",
            "flesh": "Muy compacta y granulosa, blanca, con exquisito aroma y sabor a avellana."
        },
        "confusions": [
            {
                "mushroomId": "amanita_phalloides",
                "scientificName": "Amanita phalloides",
                "commonName": "Oronja verde (Hiltzaile berdea)",
                "riskLevel": "deadly",
                "difference": "¡Regla vital! Amanita phalloides tiene sombrero liso fibrilloso (no cuarteado en placas), carne fibrosa, anillo en el pie y volva en la base."
            }
        ]
    },
    {
        "id": "sarcoscypha_coccinea",
        "scientificName": "Sarcoscypha coccinea",
        "spanishName": "Copa escarlata",
        "basqueName": "Txano gorria",
        "family": "Sarcoscyphaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Invierno y principios de Primavera",
        "habitat": "Sobre ramitas caídas y musgosas de hayas, avellanos y robles en zonas sombrías y húmedas.",
        "summary": "Precioso hongo invernal en forma de pequeña copa de color rojo rubí intenso que alegra el suelo de los hayedos en invierno.",
        "morphology": {
            "cap": "Ascocarpo en forma de copa de 2 a 5 cm, interior liso de color rojo escarlata brillante y exterior blanquecino-rosado afieltrado.",
            "hymenium": "En la superficie interna roja de la copa.",
            "stem": "Pequeño pie blanquecino anclado a una rama muerta.",
            "flesh": "Delgada y algo coriácea, sin valor gastronómico."
        },
        "confusions": [
            {
                "mushroomId": "aleuria_aurantia",
                "scientificName": "Aleuria aurantia",
                "commonName": "Peziza naranja (Katilu laranja)",
                "riskLevel": "caution",
                "difference": "Aleuria aurantia es de color naranja (no rojo escarlata) y crece directamente sobre tierra en otoño."
            }
        ]
    },
    {
        "id": "scleroderma_citrinum",
        "scientificName": "Scleroderma citrinum (Scleroderma vulgare)",
        "spanishName": "Escleroderma amarilla / Falso pedo de lobo",
        "basqueName": "Astaputz zikina",
        "family": "Sclerodermataceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Verano y Otoño",
        "habitat": "Suelos ácidos y musgosos en hayedos, robledales y pinares.",
        "summary": "Hongo globoso parecido a una patata amarillenta escamosa cuyo interior es negro-violáceo duro y tóxico.",
        "morphology": {
            "cap": "Carpóforo globoso o tuberiforme de 4 a 10 cm, con piel (peridio) muy gruesa y coriácea de color amarillo ocre cubierta de escamas poligonales pardas.",
            "hymenium": "Gleba interna firme que pasa enseguida del blanco fugaz al negro-violáceo veteado de blanco.",
            "stem": "Sin pie, sujeto al sustrato por cordones miceliares blancos.",
            "flesh": "Olor fuerte a goma o gas; provoca intoxicaciones gastrointestinales."
        },
        "confusions": [
            {
                "mushroomId": "lycoperdon_perlatum",
                "scientificName": "Lycoperdon perlatum",
                "commonName": "Pedo de lobo perlado (Astaputz perladuna)",
                "riskLevel": "good",
                "difference": "El pedo de lobo tiene forma de pera con espinas que se desprenden y piel fina."
            },
            {
                "mushroomId": "tuber_melanosporum",
                "scientificName": "Tuber melanosporum",
                "commonName": "Trufa negra (Boilur beltza)",
                "riskLevel": "excellent",
                "difference": "La trufa negra es subterránea (hipogea), tiene corteza negra piramidal y aroma exquisito."
            }
        ]
    },
    {
        "id": "sparassis_crispa",
        "scientificName": "Sparassis crispa",
        "spanishName": "Coliflor de monte / Esponja de pino",
        "basqueName": "Azalore-perretxikoa",
        "family": "Sparassidaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño",
        "habitat": "En la base de troncos y raíces de pinos (Pinus sylvestris, P. radiata, P. pinaster).",
        "summary": "Inconfundible hongo con el aspecto exacto de una gran esponja marina o coliflor rizada color crema al pie de los pinos.",
        "morphology": {
            "cap": "Masa globosa de 15 a 40 cm (hasta varios kilos) compuesta por innumerables lóbulos planos, rizados y ondulados de color crema marfil a ocre.",
            "hymenium": "Sobre ambas caras de las cintas rizadas.",
            "stem": "Base gruesa y carnosa hundida junto a la raíz del pino.",
            "flesh": "Elástica, crujiente y muy aromática en ejemplares jóvenes (limpiar bien bajo el grifo)."
        },
        "confusions": [
            {
                "mushroomId": "ramaria_formosa",
                "scientificName": "Ramaria formosa",
                "commonName": "Pie de rata hermoso (Atzapar ederra)",
                "riskLevel": "toxic",
                "difference": "Las Ramarias tienen ramas cilíndricas coraliformes terminadas en puntas, no cintas planas rizadas como hojas de lechuga."
            }
        ]
    },
    {
        "id": "stropharia_aeruginosa",
        "scientificName": "Stropharia aeruginosa",
        "spanishName": "Estrofaria verde",
        "basqueName": "Estrofaria berdea",
        "family": "Strophariaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Otoño",
        "habitat": "Sobre restos leñosos y hojarasca en hayedos, robledales y pinares.",
        "summary": "Llamativa seta de color azul-verdoso cardenillo muy viscosa salpicada de escamitas blancas en el borde del sombrero.",
        "morphology": {
            "cap": "De 3 a 8 cm, acampanado a convexo, cubierto de una gruesa capa glutinosa azul-verde esmeralda que amarillea con la edad y escamas blancas marginales.",
            "hymenium": "Láminas adnatas, gris-liláceas y luego pardo-purpúreas con la arista blanca.",
            "stem": "Cilíndrico, azul-verdoso, viscoso y escamoso debajo de un anillo membranoso.",
            "flesh": "Blanquecina-azulada, blanda, sin valor culinario."
        },
        "confusions": [
            {
                "mushroomId": "clitocybe_odora",
                "scientificName": "Clitocybe odora",
                "commonName": "Clitocibe anisado (Anis-klitokibea)",
                "riskLevel": "good",
                "difference": "Clitocybe odora es seco (no viscoso), no tiene anillo ni escamas blancas y huele intensamente a anís."
            }
        ]
    },
    {
        "id": "suillellus_luridus",
        "scientificName": "Suillellus luridus (Boletus luridus)",
        "spanishName": "Boleto cetrino / Boleto lúrido",
        "basqueName": "Onddo zikina",
        "family": "Boletaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Verano y Otoño",
        "habitat": "Bosques de frondosas (hayedos, robledales) sobre suelos preferentemente calizos.",
        "summary": "Boleto de poros naranjas-rojos que se distingue de Neoboletus erythropus por tener una red (retículo) muy marcada en el pie; tóxico en crudo.",
        "morphology": {
            "cap": "De 6 a 18 cm, hemisférico, cutícula afieltrada de color pardo oliváceo, ocre gamuza o bronceado.",
            "hymenium": "Poros pequeños de color rojo anaranjado que azulean intensamente al tocarlos (bajo los tubos la carne es rojiza: 'línea de Bataille').",
            "stem": "Grueso, amarillo-anaranjado cubierto de un retículo de mallas alargadas de color rojo oscuro.",
            "flesh": "Amarillenta que azulea rápidamente al corte. Tóxica en crudo; requiere cocción prolongada."
        },
        "confusions": [
            {
                "mushroomId": "rubroboletus_satanas",
                "scientificName": "Rubroboletus satanas",
                "commonName": "Boleto de Satanás (Satan onddoa)",
                "riskLevel": "toxic",
                "difference": "El Boleto de Satanás tiene sombrero blanco tiza, pie mucho más obeso con retículo fino y olor desagradable."
            }
        ]
    },
    {
        "id": "suillus_bovinus",
        "scientificName": "Suillus bovinus",
        "spanishName": "Boleto bovino",
        "basqueName": "Behi-onddoa",
        "family": "Suillaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Otoño",
        "habitat": "En grandes grupos bajo pinares (Pinus sylvestris, P. radiata, P. pinaster).",
        "summary": "Pequeño boleto de pinares con sombrero viscoso ocre-anaranjado y poros angulosos compuestos de carne elástica.",
        "morphology": {
            "cap": "De 4 a 10 cm, convexo a plano, viscoso, color ocre leonado a canela rosado.",
            "hymenium": "Tubos cortos decurrentes y poros anchos, angulosos y compuestos, de color amarillo oliváceo.",
            "stem": "Corto, curvado, sin anillo ni granulaciones, del color del sombrero.",
            "flesh": "Elástica y blanda, amarillenta-rosada, de poco valor gastronómico."
        },
        "confusions": [
            {
                "mushroomId": "chalciporus_piperatus",
                "scientificName": "Chalciporus piperatus",
                "commonName": "Boleto picante (Onddo pipermina)",
                "riskLevel": "non_edible",
                "difference": "Chalciporus piperatus tiene los poros de color rojo canela y sabor muy picante."
            }
        ]
    },
    {
        "id": "suillus_granulatus",
        "scientificName": "Suillus granulatus",
        "spanishName": "Boleto granulado / Babosillo",
        "basqueName": "Pinudi-onddo pikortsua",
        "family": "Suillaceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Primavera y Otoño",
        "habitat": "Pinares (especialmente en suelos calizos).",
        "summary": "Boleto de pino sin anillo cuyos poros y parte alta del pie exudan gotitas lechosas en ejemplares jóvenes; hay que retirar siempre la cutícula viscosa.",
        "morphology": {
            "cap": "De 5 a 12 cm, hemisférico a convexo, muy viscoso en húmedo, marrón rojizo a ocre amarillento (cutícula fácilmente pelable).",
            "hymenium": "Poros pequeños amarillo pálido que en ejemplares jóvenes segregan gotitas opalescentes lechosas.",
            "stem": "Cilíndrico, SIN ANILLO, amarillo pálido salpicado de granulaciones pardas en el ápice.",
            "flesh": "Blanda, amarillo pálido. Es imprescindible pelar la cutícula del sombrero antes de cocinar porque es laxante."
        },
        "confusions": [
            {
                "mushroomId": "suillus_luteus",
                "scientificName": "Suillus luteus",
                "commonName": "Boleto anillado (Pinudi-onddo likits)",
                "riskLevel": "good",
                "difference": "Suillus luteus posee un gran anillo membranoso blanco-violáceo en el pie."
            }
        ]
    },
    {
        "id": "suillus_luteus",
        "scientificName": "Suillus luteus",
        "spanishName": "Boleto anillado / Baboso",
        "basqueName": "Pinudi-onddo likitsa",
        "family": "Suillaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Otoño",
        "habitat": "Muy abundante en pinares de repoblación (Pinus radiata y P. sylvestris) de Euskadi y toda España.",
        "summary": "El clásico boleto de los pinares provisto de un gran anillo membranoso violáceo y cutícula marrón chocolate muy viscosa (pelar antes de cocinar).",
        "morphology": {
            "cap": "De 5 a 12 cm, convexo con ligero mamelón, cubierto de una gruesa capa viscosa marrón chocolate (que se pela entera con facilidad).",
            "hymenium": "Poros pequeños amarillo limón cubiertos al principio por un velo blanco.",
            "stem": "Cilíndrico, provisto de un amplio anillo membranoso blanco por arriba y pardo-violáceo por abajo, con granulaciones en el ápice.",
            "flesh": "Tierna, blanca-amarillenta; buen comestible en ejemplares jóvenes tras retirar siempre la piel viscosa del sombrero."
        },
        "confusions": [
            {
                "mushroomId": "suillus_granulatus",
                "scientificName": "Suillus granulatus",
                "commonName": "Boleto granulado (Pinudi-onddo pikortsua)",
                "riskLevel": "caution",
                "difference": "Suillus granulatus carece por completo de anillo en el pie."
            }
        ]
    },
    {
        "id": "trametes_versicolor",
        "scientificName": "Trametes versicolor",
        "spanishName": "Cola de pavo",
        "basqueName": "Indioilar-buztana",
        "family": "Polyporaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Todo el año",
        "habitat": "En grupos imbricados sobre troncos y tocones muertos de hayas, robles y otras frondosas.",
        "summary": "Precioso políporo leñoso en abanicos finos con bandas concéntricas multicolores que imitan la cola abierta de un pavo real.",
        "morphology": {
            "cap": "Rosetas de abanicos delgados (3-8 cm) aterciopelados con zonas concéntricas de colores negro, pardo, azulado, ocre y margen blanco.",
            "hymenium": "Poros diminutos blancos a crema en la cara inferior.",
            "stem": "Sésil (sin pie), adherido lateralmente a la madera.",
            "flesh": "Coriácea y dura como el cuero (no comestible, aunque estudiada en micoterapia)."
        },
        "confusions": []
    },
    {
        "id": "tricholoma_equestre",
        "scientificName": "Tricholoma equestre (Tricholoma flavovirens)",
        "spanishName": "Seta de los caballeros / Verderol",
        "basqueName": "Zaldun-ziza",
        "family": "Tricholomataceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Otoño tardío",
        "habitat": "Pinares sobre suelos arenosos y ácidos.",
        "summary": "Antiguamente consumida, hoy prohibida su comercialización y considerada mortal: su consumo repetido provoca rabdomiólisis aguda letal.",
        "morphology": {
            "cap": "De 5 a 12 cm, convexo-mamelonado, viscoso en húmedo, amarillo azufre recubierto de finas escamas parduzcas en el centro.",
            "hymenium": "Láminas apretadas, escotadas, de un intenso color amarillo azufre o amarillo canario.",
            "stem": "Macizo, cilíndrico, amarillo azufre.",
            "flesh": "Compacta, blanca con borde amarillo bajo la cutícula, olor débil harinoso. Provoca destrucción muscular (rabdomiólisis)."
        },
        "confusions": [
            {
                "mushroomId": "tricholoma_sulphureum",
                "scientificName": "Tricholoma sulphureum",
                "commonName": "Tricoloma azufrado",
                "riskLevel": "toxic",
                "difference": "Tricholoma sulphureum tiene láminas muy espaciadas, carne enteramente amarilla y un fuerte olor a gas butano."
            }
        ]
    },
    {
        "id": "tricholoma_pardinum",
        "scientificName": "Tricholoma pardinum (Tricholoma tigrinum)",
        "spanishName": "Tricoloma atigrado",
        "basqueName": "Ziza nabarra / Tigre-ziza",
        "family": "Tricholomataceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Finales de Verano y Otoño",
        "habitat": "Hayedos y abetales de montaña sobre suelos calcáreos.",
        "summary": "Seta carnosa y robusta con escamas atigradas grises sobre el sombrero que provoca gastroenteritis muy graves (confundida a menudo con la negrilla).",
        "morphology": {
            "cap": "De 6 a 15 cm, carnoso, hemisférico a convexo con mamelón ancho, cubierto de gruesas escamas imbricadas gris-negruzcas dispuestas como tejas sobre fondo claro.",
            "hymenium": "Láminas escotadas, anchas, blanco-crema con reflejo glauco (a menudo exudan gotitas de agua).",
            "stem": "Muy grueso, macizo y ventrudo, blanquecino con tonos ocres en la base.",
            "flesh": "Firme, blanca, con agradable olor y sabor a harina fresca. Muy tóxica."
        },
        "confusions": [
            {
                "mushroomId": "tricholoma_terreum",
                "scientificName": "Tricholoma terreum",
                "commonName": "Negrilla / Ratón (Ziza arre-grisa)",
                "riskLevel": "caution",
                "difference": "Tricholoma terreum es mucho más pequeño y frágil (sombrero de 3 a 7 cm afieltrado como pelo de ratón), crece en pinares y NO huele a harina."
            }
        ]
    },
    {
        "id": "tricholoma_portentosum",
        "scientificName": "Tricholoma portentosum",
        "spanishName": "Capuchina / Carbonera de pino",
        "basqueName": "Ziza iluna",
        "family": "Tricholomataceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño tardío e Invierno (Octubre - Enero)",
        "habitat": "Pinares (Pinus sylvestris) y bosques mixtos con hayas en suelos ácidos.",
        "summary": "Magnífica seta tardía de sombrero gris pizarra recorrido por fibrillas radiales negras y pie y láminas blancos con reflejos amarillo limón.",
        "morphology": {
            "cap": "De 5 a 12 cm, cónico-acampanado a extendido con mamelón, viscoso en húmedo, gris plomo oscuro recorrido por finas fibrillas negras innatas con reflejo violáceo o amarillo.",
            "hymenium": "Láminas escotadas, blancas con característicos reflejos amarillo limón.",
            "stem": "Cilíndrico, macizo y fibroso, blanco esfumado de amarillo limón.",
            "flesh": "Blanca, frágil, con suave olor y sabor a harina fresca y ostras."
        },
        "confusions": [
            {
                "mushroomId": "tricholoma_pardinum",
                "scientificName": "Tricholoma pardinum",
                "commonName": "Tricoloma atigrado (Tigre-ziza)",
                "riskLevel": "toxic",
                "difference": "Tricholoma pardinum tiene gruesas escamas atigradas (no fibrillas radiales lisas) y carece de tonos amarillo limón en pie y láminas."
            }
        ]
    },
    {
        "id": "tricholoma_sulphureum",
        "scientificName": "Tricholoma sulphureum",
        "spanishName": "Tricoloma azufrado",
        "basqueName": "Sufre-ziza",
        "family": "Tricholomataceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Otoño",
        "habitat": "Hayedos, robledales y bosques mixtos.",
        "summary": "Seta completamente amarillo azufre que se identifica al instante al acercarla a la nariz por su intenso olor a gas ciudad o alquitrán.",
        "morphology": {
            "cap": "De 3 a 8 cm, convexo con mamelón, seco y mate, amarillo azufre con el centro algo parduzco.",
            "hymenium": "Láminas gruesas, muy espaciadas y escotadas, amarillo azufre.",
            "stem": "Fibroso, curvado, amarillo azufre tanto por fuera como por dentro.",
            "flesh": "Amarillo azufre con un potentísimo olor a gas de alumbrado o caucho quemado."
        },
        "confusions": [
            {
                "mushroomId": "cantharellus_cibarius",
                "scientificName": "Cantharellus cibarius",
                "commonName": "Rebozuelo (Ziza horia)",
                "riskLevel": "excellent",
                "difference": "El rebozuelo tiene pliegues decurrentes y aroma afrutado a albaricoque."
            }
        ]
    },
    {
        "id": "tricholoma_terreum",
        "scientificName": "Tricholoma terreum",
        "spanishName": "Negrilla / Ratón / Fredolic",
        "basqueName": "Ziza arre-grisa / Sagu-ziza",
        "family": "Tricholomataceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Otoño tardío e Invierno",
        "habitat": "En grandes colonias bajo pinares (especialmente en suelos calizos de Álava, Navarra y Pirineos).",
        "summary": "Pequeña seta invernal de pinares con sombrero gris afieltrado como el pelo de un ratón; consumir con moderación sin abusar en comidas seguidas.",
        "morphology": {
            "cap": "De 3 a 8 cm, acampanado a convexo con mamelón, cutícula seca y afieltrada recubierta de finas fibrillas lanosas color gris ratón.",
            "hymenium": "Láminas escotadas, frágiles, blancas a gris ceniza pálido.",
            "stem": "Cilíndrico, hueco y quebradizo, blanquecino.",
            "flesh": "Delgada y frágil, blanca-grisácea, TOTALMENTE INODORA (nunca huele a harina)."
        },
        "confusions": [
            {
                "mushroomId": "tricholoma_pardinum",
                "scientificName": "Tricholoma pardinum",
                "commonName": "Tricoloma atigrado (Tigre-ziza)",
                "riskLevel": "toxic",
                "difference": "Tricholoma pardinum es mucho más grande y robusto, tiene escamas gruesas atigradas y un marcado olor a harina."
            }
        ]
    },
    {
        "id": "tuber_melanosporum",
        "scientificName": "Tuber melanosporum",
        "spanishName": "Trufa negra / Diamante negro",
        "basqueName": "Boilur beltza",
        "family": "Tuberaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Invierno (Diciembre - Marzo)",
        "habitat": "Hongo hipogeo (subterráneo) micorrizado con encinas, robles quejigos y avellanos en suelos calizos pedregosos (Montaña Alavesa, Tierra Estella, Aragón, Soria).",
        "summary": "El 'diamante negro' de la gastronomía: hongo subterráneo recolectado con perros truferos en los encinares calizos de Álava, Navarra y el interior peninsular.",
        "morphology": {
            "cap": "Ascocarpo globoso e irregular de 3 a 8 cm, recubierto de una corteza (peridio) negra con verrugas piramidales poligonales.",
            "hymenium": "Gleba interna carnosa, primero violácea y en la madurez negro-purpúrea surcada por finas venas blancas ramificadas.",
            "stem": "Inexistente (hongo hipogeo subterráneo).",
            "flesh": "Dura y compacta, con un perfume penetrante, complejo e inconfundible."
        },
        "confusions": [
            {
                "mushroomId": "scleroderma_citrinum",
                "scientificName": "Scleroderma citrinum",
                "commonName": "Escleroderma amarilla (Astaputz zikina)",
                "riskLevel": "toxic",
                "difference": "Scleroderma crece en la superficie del suelo, tiene corteza amarilla-ocre y olor a goma."
            }
        ]
    },
    {
        "id": "tylopilus_felleus",
        "scientificName": "Tylopilus felleus",
        "spanishName": "Boleto amargo / Hongo de la hiel",
        "basqueName": "Behazun-onddoa / Onddo mingotsa",
        "family": "Boletaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "Pinares, hayedos y robledales ácidos, a veces sobre tocones musgosos.",
        "summary": "El doble amargo del Boletus edulis: no es venenoso, pero un solo ejemplar en la cazuela arruina todo el guiso por su amargor extremo como la hiel.",
        "morphology": {
            "cap": "De 6 a 15 cm, hemisférico a convexo, pardo gamuza a marrón avellana.",
            "hymenium": "Poros inicialmente blancos que al madurar se vuelven de un inconfundible color ROSA SUCIO o rosa salmón.",
            "stem": "Robusto, ocre amarillento decorado con un retículo (red) pardo oscuro muy grueso y en relieve.",
            "flesh": "Blanca y blanda, de sabor intensísimamente amargo al probar una pizca con la punta de la lengua."
        },
        "confusions": [
            {
                "mushroomId": "boletus_edulis",
                "scientificName": "Boletus edulis",
                "commonName": "Hongo blanco (Udazkeneko onddo zuri)",
                "riskLevel": "excellent",
                "difference": "En Boletus edulis los poros pasan del blanco al amarillo-verdoso (NUNCA rosas), el retículo del pie es blanco sobre fondo claro y la carne es dulce."
            },
            {
                "mushroomId": "boletus_reticulatus",
                "scientificName": "Boletus reticulatus",
                "commonName": "Hongo de verano (Udako onddo zuri)",
                "riskLevel": "excellent",
                "difference": "Boletus reticulatus tiene poros blancos/amarillo-verdosos y sabor dulce."
            }
        ]
    },
    {
        "id": "volvopluteus_gloiocephalus",
        "scientificName": "Volvopluteus gloiocephalus (Volvariella gloiocephala)",
        "spanishName": "Volvaria viscosa",
        "basqueName": "Bolbaria mukitsua",
        "family": "Pluteaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Primavera y Otoño",
        "habitat": "Campos abonados, rastrojos, huertas, jardines y praderas nitrificadas.",
        "summary": "Seta esbelta con gran volva blanca en la base, SIN ANILLO y con láminas que se vuelven de color rosa salmón.",
        "morphology": {
            "cap": "De 5 a 14 cm, ovoide a extendido con mamelón obtuso, cutícula muy viscosa en húmedo, de color gris perla a blanco sucio.",
            "hymenium": "Láminas libres, apretadas y ventrudas, primero blancas y pronto rosa salmón por la esporada rosada.",
            "stem": "Alto y esbelto, blanco, totalmente desprovisto de anillo y con una volva sacciforme blanca o grisácea en la base.",
            "flesh": "Blanca y tierna, con ligero olor a rábano que desaparece al cocinarla."
        },
        "confusions": [
            {
                "mushroomId": "amanita_phalloides",
                "scientificName": "Amanita phalloides",
                "commonName": "Oronja verde (Hiltzaile berdea)",
                "riskLevel": "deadly",
                "difference": "¡Mucha precaución con ejemplares jóvenes de láminas aún blancas! Las Amanitas mortales tienen anillo en el pie y sus láminas nunca se vuelven rosas."
            }
        ]
    },
    {
        "id": "xerocomellus_chrysenteron",
        "scientificName": "Xerocomellus chrysenteron (Boletus chrysenteron)",
        "spanishName": "Boleto de carne amarilla / Boleto cuarteado",
        "basqueName": "Onddo urregorria",
        "family": "Boletaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Verano y Otoño",
        "habitat": "Muy común en hayedos, robledales y pinares.",
        "summary": "Pequeño boleto cuyo sombrero pardo mate se cuartea en grietas que dejan ver una línea de carne de color rojo vivo bajo la cutícula.",
        "morphology": {
            "cap": "De 4 a 9 cm, convexo, cutícula seca y aterciopelada pardo-olivácea que se agrieta fácilmente mostrando el tejido subyacente rojo carmín.",
            "hymenium": "Poros grandes y angulosos de color amarillo vivo a verde oliva que azulean débilmente al presionarlos.",
            "stem": "Delgado, fibroso, amarillo intensamente teñido o estriado de rojo carmín.",
            "flesh": "Amarilla (roja bajo la cutícula y en la base del pie), blanda; usar solo sombreros de ejemplares muy jóvenes."
        },
        "confusions": [
            {
                "mushroomId": "xerocomus_subtomentosus",
                "scientificName": "Xerocomus subtomentosus",
                "commonName": "Boleto subtomentoso (Onddo belusatua)",
                "riskLevel": "good",
                "difference": "Xerocomus subtomentosus no presenta tonos rojos en las grietas del sombrero y su pie apenas tiene rojo."
            }
        ]
    },
    {
        "id": "xerocomus_subtomentosus",
        "scientificName": "Xerocomus subtomentosus (Boletus subtomentosus)",
        "spanishName": "Boleto subtomentoso / Boleto afieltrado",
        "basqueName": "Onddo belusatua",
        "family": "Boletaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Verano y Otoño",
        "habitat": "Bosques de frondosas (robles, hayas, castaños) y coníferas.",
        "summary": "Boleto de sombrero aterciopelado pardo-oliváceo y grandes poros amarillo oro brillante.",
        "morphology": {
            "cap": "De 5 a 12 cm, convexo, cutícula seca y aterciopelada como gamuza de color pardo oliváceo o marrón bronce.",
            "hymenium": "Poros anchos y angulosos de un vivo color amarillo cromo a amarillo-verdoso que azulean muy levemente.",
            "stem": "Esbelto, fusiforme, recorrido por costillas longitudinales, amarillento-parduzco.",
            "flesh": "Blanco-amarillenta, tierna en el sombrero y fibrosa en el pie."
        },
        "confusions": [
            {
                "mushroomId": "imleria_badia",
                "scientificName": "Imleria badia",
                "commonName": "Boleto bayo (Onddo gaztaina)",
                "riskLevel": "excellent",
                "difference": "Imleria badia tiene el sombrero liso color castaña (no afieltrado oliváceo) y poros más pequeños que azulean con fuerza."
            }
        ]
    },
    {
        "id": "craterellus_cinereus",
        "scientificName": "Craterellus cinereus (Cantharellus cinereus)",
        "spanishName": "Rebozuelo ceniciento / Trompeta gris",
        "basqueName": "Saltsa-perretxiko errauts-kolorea",
        "family": "Cantharellaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño",
        "habitat": "En colonias bajo hayedos y robledales.",
        "summary": "Muy parecido a la trompeta de los muertos pero con pliegues venosos bien marcados de color gris ceniza azulado en el exterior.",
        "morphology": {
            "cap": "De 2 a 6 cm, embudado y perforado en el centro con margen ondulado, gris negruzco a pardo fuliginoso.",
            "hymenium": "Pliegues decurrentes gruesos, bifurcados e intervenados de color gris ceniza con pruina azulada.",
            "stem": "Hueco, comprimido, gris oscuro a negro.",
            "flesh": "Delgada, membranosa, negra, con excelente aroma afrutado a ciruela mirabel."
        },
        "confusions": [
            {
                "mushroomId": "craterellus_cornucopioides",
                "scientificName": "Craterellus cornucopioides",
                "commonName": "Trompeta de los muertos (Hildakoen tronpeta)",
                "riskLevel": "excellent",
                "difference": "Ambos son excelentes; C. cornucopioides tiene la cara externa casi lisa sin pliegues gruesos."
            }
        ]
    },
    {
        "id": "leotia_lubrica",
        "scientificName": "Leotia lubrica",
        "spanishName": "Leotia viscosa / Cerilla de monte",
        "basqueName": "Leotia mukitsua",
        "family": "Leotiaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Otoño",
        "habitat": "En grupos entre el musgo húmedo de hayedos, robledales y pinares (a menudo mezclada con angulas de monte).",
        "summary": "Pequeño hongo gelatinoso con cabezuela redondeada verde-olivácea y pie amarillo viscoso que suele crecer junto a las angulas de monte.",
        "morphology": {
            "cap": "Cabezuela irregularmente globosa y lobulada de 1 a 3 cm, margen enrollado, lisa por ambos lados (SIN pliegues), color amarillo-verdoso a oliva.",
            "hymenium": "En la superficie superior lisa y viscosa de la cabezuela.",
            "stem": "Cilíndrico, hueco, gelatinoso y resbaladizo, amarillo anaranjado con pequeños puntos verdosos.",
            "flesh": "Gelatinosa, elástica e insípida; sin valor culinario."
        },
        "confusions": [
            {
                "mushroomId": "craterellus_tubaeformis",
                "scientificName": "Craterellus tubaeformis",
                "commonName": "Angula de monte (Mendiko angula)",
                "riskLevel": "excellent",
                "difference": "La angula de monte no es gelatinosa, tiene el sombrero embudado y posee pliegues decurrentes bien marcados debajo."
            }
        ]
    }
]
