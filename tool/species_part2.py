# -*- coding: utf-8 -*-
"""Parte 2 del catálogo micológico de Perretxikotan (Especies C - L)."""

SPECIES_PART_2 = [
    {
        "id": "chroogomphus_rutilus",
        "scientificName": "Chroogomphus rutilus",
        "spanishName": "Pata de perdiz / Gomfidio viscoso",
        "basqueName": "Lerdeki kobrekolorea",
        "family": "Gomphidiaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Otoño",
        "habitat": "Exclusivo de pinares (Pinus sylvestris, P. radiata, P. nigra), a menudo compartiendo hábitat con níscalos y boletos.",
        "summary": "Seta de pinares con sombrero cónico-mamelonado color cobre viscoso y láminas muy espaciadas y decurrentes.",
        "morphology": {
            "cap": "De 4 a 10 cm, cónico-campanulado con mamelón central puntiagudo, cutícula viscosa de color pardo cobrizo o vinoso.",
            "hymenium": "Láminas gruesas, muy espaciadas, arqueado-decurrentes, primero ocre-purpúreas y finalmente negruzcas por las esporas.",
            "stem": "Cilíndrico, atenuado en la base, amarillo-anaranjado con zonas fibrillosas vinosas.",
            "flesh": "Color salmón o anaranjado, amarillo cromo en la base del pie; inodora y de sabor suave (se vuelve violácea al cocinarla)."
        },
        "confusions": [
            {
                "mushroomId": "cortinarius_orellanus",
                "scientificName": "Cortinarius orellanus",
                "commonName": "Cortinario de montaña (Sare-ziza hilgarria)",
                "riskLevel": "deadly",
                "difference": "Cortinarius orellanus tiene sombrero seco y fibrilloso (nunca viscoso), láminas escotadas (no decurrentes) de color canela-herrumbre y crece bajo frondosas."
            }
        ]
    },
    {
        "id": "clathrus_archeri",
        "scientificName": "Clathrus archeri (Anthurus archeri)",
        "spanishName": "Dedos del diablo / Estrella roja",
        "basqueName": "Olagarro-perretxikoa / Deabruaren hatzak",
        "family": "Phallaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "Praderas húmedas, claros de hayedos y robledales del País Vasco y cornisa cantábrica (especie alóctona de origen australiano muy extendida en Euskadi).",
        "summary": "Inconfundible hongo con aspecto de pulpo o estrella de mar roja con brazos cubiertos de gleba negra maloliente.",
        "morphology": {
            "cap": "Nace de un huevo blanquecino gelatinoso del que emergen de 4 a 8 brazos largos y puntiagudos de color rojo coral.",
            "hymenium": "Gleba mucilaginosa de color verde oliva negruzco sobre la cara interna de los brazos.",
            "stem": "Base corta envuelta en la volva blanca del huevo inicial.",
            "flesh": "Esponjosa y frágil, con un intenso olor fétido a carne podrida para atraer moscas dispersoras de esporas."
        },
        "confusions": [
            {
                "mushroomId": "clathrus_ruber",
                "scientificName": "Clathrus ruber",
                "commonName": "Jaula roja (Kaiola gorria)",
                "riskLevel": "non_edible",
                "difference": "Sus brazos están unidos formando una esfera enrejada en lugar de abrirse como los tentáculos de un pulpo."
            }
        ]
    },
    {
        "id": "clathrus_ruber",
        "scientificName": "Clathrus ruber",
        "spanishName": "Jaula roja / Linterna del diablo",
        "basqueName": "Kaiola gorria",
        "family": "Phallaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Primavera y Otoño",
        "habitat": "Jardines, parques, encinares y bosques templados con abundante materia orgánica.",
        "summary": "Curioso hongo en forma de esfera o celosía enrejada de color rojo anaranjado y olor nauseabundo.",
        "morphology": {
            "cap": "Receptáculo globoso en forma de malla o jaula poligonal de 6 a 12 cm de altura de color rojo vivo.",
            "hymenium": "Gleba oscura y viscosa en la cara interna de la red.",
            "stem": "Sin pie, con volva blanca basal procedente del huevo.",
            "flesh": "Esponjosa y muy frágil, de olor fétido."
        },
        "confusions": [
            {
                "mushroomId": "clathrus_archeri",
                "scientificName": "Clathrus archeri",
                "commonName": "Dedos del diablo (Olagarro-perretxikoa)",
                "riskLevel": "non_edible",
                "difference": "Clathrus archeri abre sus brazos libres como tentáculos de pulpo."
            }
        ]
    },
    {
        "id": "clitocybe_dealbata",
        "scientificName": "Clitocybe rivulosa (Clitocybe dealbata)",
        "spanishName": "Clitocibe blanco / Señorita",
        "basqueName": "Klitokibe zuria",
        "family": "Tricholomataceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Otoño",
        "habitat": "Prados, céspedes, pastizales y bordes herbosos de caminos (a menudo conviviendo en los mismos corros que la senderuela).",
        "summary": "Pequeña seta blanquecina extremadamente tóxica (altísimo contenido en muscarina) que crece en prados junto a Marasmius oreades.",
        "morphology": {
            "cap": "De 2 a 5 cm, convexo y pronto aplanado o deprimido, blanquecino con aspecto escarchado o satinado y zonas concéntricas crema-rosadas.",
            "hymenium": "Láminas apretadas, adnatas a ligeramente decurrentes, blanquecinas.",
            "stem": "Corto, fibroso, frecuentemente curvado, blanquecino.",
            "flesh": "Delgada, blanca, olor harinoso-espermatico. Provoca síndrome muscarínico grave."
        },
        "confusions": [
            {
                "mushroomId": "marasmius_oreades",
                "scientificName": "Marasmius oreades",
                "commonName": "Senderuela (Marasmio jangarria)",
                "riskLevel": "excellent",
                "difference": "La senderuela tiene sombrero mamelonado color cuero, láminas muy separadas y libres (no decurrentes) y un pie elástico que se retuerce sin romperse."
            },
            {
                "mushroomId": "clitopilus_prunulus",
                "scientificName": "Clitopilus prunulus",
                "commonName": "Molinera / Chivata (Errotaria)",
                "riskLevel": "excellent",
                "difference": "La molinera es muy frágil, huele intensamente a harina fresca y sus láminas muy decurrentes se vuelven rosadas al madurar."
            }
        ]
    },
    {
        "id": "clitocybe_nebularis",
        "scientificName": "Clitocybe nebularis (Lepista nebularis)",
        "spanishName": "Pardilla / Ilarraka",
        "basqueName": "Ilarraka / Pago-ziza",
        "family": "Tricholomataceae",
        "edibility": "caution",
        "edibilityLabel": "Comestible con precaución",
        "season": "Otoño tardío (Octubre - Diciembre)",
        "habitat": "Hayedos, robledales y pinares formando grandes hileras o corros de brujas.",
        "summary": "Muy tradicional en el País Vasco ('Ilarraka'), aunque contiene nebularina y provoca intolerancias severas a muchas personas; requiere desechar el agua de cocción.",
        "morphology": {
            "cap": "De 7 a 20 cm, carnoso, convexo a plano-deprimido, color gris ceniza o pardo neblinoso cubierto de una pruina blanquecina.",
            "hymenium": "Láminas apretadas, arqueadas y ligeramente decurrentes, de color blanco-crema fácilmente separables de la carne.",
            "stem": "Robusto, claviforme (más ancho en la base), fibroso y esponjoso con la edad, blanco-grisáceo.",
            "flesh": "Espesa y blanca, con un olor muy fuerte, aromático y peculiar que persiste al cocinarla."
        },
        "confusions": [
            {
                "mushroomId": "entoloma_sinuatum",
                "scientificName": "Entoloma sinuatum",
                "commonName": "Seta engañosa / Perfidia (Ziza maltzurra)",
                "riskLevel": "toxic",
                "difference": "¡Confusión frecuente en Euskadi! Entoloma sinuatum tiene láminas escotadas (NO decurrentes) que pasan del amarillo pálido al rosa salmón y huele a harina."
            }
        ]
    },
    {
        "id": "clitocybe_odora",
        "scientificName": "Clitocybe odora",
        "spanishName": "Clitocibe anisado / Anisada verde",
        "basqueName": "Anis-klitokibea",
        "family": "Tricholomataceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Verano y Otoño",
        "habitat": "Entre la hojarasca de hayedos, robledales y pinares.",
        "summary": "Inconfundible seta de color verde azulado o verde grisáceo con un potentísimo aroma a licor de anís.",
        "morphology": {
            "cap": "De 3 a 8 cm, convexo a plano-deprimido, de singular color verde azulado o verde glauco que palidece en tiempo seco.",
            "hymenium": "Láminas adnatas a ligeramente decurrentes, más pálidas que el sombrero.",
            "stem": "Cilíndrico, elástico, blanquecino-verdoso con base tomentosa.",
            "flesh": "Blanquecina-verdosa con intenso olor a anís verde. Buena para aromatizar guisos en pequeñas cantidades."
        },
        "confusions": [
            {
                "mushroomId": "stropharia_aeruginosa",
                "scientificName": "Stropharia aeruginosa",
                "commonName": "Estrofaria verde (Estrofaria berdea)",
                "riskLevel": "non_edible",
                "difference": "Stropharia aeruginosa es muy viscosa, tiene escamas blancas en el sombrero, anillo en el pie, láminas oscuras y NO huele a anís."
            }
        ]
    },
    {
        "id": "clitopilus_prunulus",
        "scientificName": "Clitopilus prunulus",
        "spanishName": "Molinera / Chivata",
        "basqueName": "Errotaria / Irin-ziza",
        "family": "Entolomataceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Verano y Otoño",
        "habitat": "Claros herbosos y musgosos de hayedos, robledales y pinares.",
        "summary": "Llamada la 'chivata' porque comparte micorrizas y hábitat exacto con el Boletus edulis; cuando ves una molinera, mira alrededor porque suele haber hongos cerca.",
        "morphology": {
            "cap": "De 4 a 10 cm, convexo a deprimido con margen ondulado e involuto, cutícula mate aterciopelada (como piel de gamuza blanca o gris perla).",
            "hymenium": "Láminas muy decurrentes, apretadas, primero blancas y al madurar de un característico color rosa salmón.",
            "stem": "Corto, a menudo algo excéntrico, blanco y pruinoso.",
            "flesh": "Muy blanda y frágil (se deshace fácilmente), blanca, con intensísimo olor a harina fresca."
        },
        "confusions": [
            {
                "mushroomId": "clitocybe_dealbata",
                "scientificName": "Clitocybe rivulosa (Clitocybe dealbata)",
                "commonName": "Clitocibe blanco mortal (Klitokibe zuria)",
                "riskLevel": "deadly",
                "difference": "Peligrosa confusión con ejemplares jóvenes: Clitocybe rivulosa tiene carne elástica/fibrosa (no blanda ni frágil), crece en prados abiertos y sus láminas NUNCA se vuelven rosadas."
            }
        ]
    },
    {
        "id": "coprinus_comatus",
        "scientificName": "Coprinus comatus",
        "spanishName": "Barbuda / Matacandil / Chipirón de monte",
        "basqueName": "Urbeltz galparduna / Txipiroia",
        "family": "Agaricaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Primavera y Otoño",
        "habitat": "Praderas abonadas, jardines, cunetas y bordes de caminos.",
        "summary": "Conocida en Euskadi como 'txipiroi de monte' por su textura tierna; solo debe consumirse muy joven cuando las láminas son totalmente blancas.",
        "morphology": {
            "cap": "De 5 a 15 cm de altura, cilíndrico u ovoide cerrado como un paraguas plegado, blanco cubierto de grandes escamas lanosas ('barbas').",
            "hymenium": "Láminas libres muy apretadas, primero blancas, luego rosadas y en pocas horas negras, disolviéndose en tinta negra (delicuescentes).",
            "stem": "Largo, hueco, blanco y sedoso, con un pequeño anillo móvil.",
            "flesh": "Muy tierna y delicada, blanca. Debe cocinarse pocas horas después de recolectarse antes de que ennegrezca."
        },
        "confusions": [
            {
                "mushroomId": "coprinopsis_atramentaria",
                "scientificName": "Coprinopsis atramentaria (Coprinus atramentarius)",
                "commonName": "Coprino antialcohólico (Urbeltz tintakara)",
                "riskLevel": "toxic",
                "difference": "Tiene el sombrero gris plomo acanalado sin grandes escamas blancas lanosas y provoca el síndrome coprínico si se consume alcohol."
            }
        ]
    },
    {
        "id": "coprinopsis_atramentaria",
        "scientificName": "Coprinopsis atramentaria (Coprinus atramentarius)",
        "spanishName": "Coprino entintado / Coprino antialcohólico",
        "basqueName": "Urbeltz tintakara",
        "family": "Psathyrellaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Primavera a Otoño",
        "habitat": "En ramilletes densos sobre restos de madera enterrada en jardines, prados y bosques.",
        "summary": "Contiene coprina (efecto disulfiram/Antabús): si se toma alcohol hasta 72 horas después de comerla provoca taquicardia, enrojecimiento facial y vómitos.",
        "morphology": {
            "cap": "De 3 a 8 cm, ovoide-acampanado, gris ceniza o gris parduzco, fuertemente surcado y con finas escamitas en el ápice.",
            "hymenium": "Láminas apretadas, blanquecinas que se licúan rápidamente en tinta negra.",
            "stem": "Cilíndrico, hueco, blanco con una zona anular fugaz cerca de la base.",
            "flesh": "Delgada, grisácea, delicuescente."
        },
        "confusions": [
            {
                "mushroomId": "coprinus_comatus",
                "scientificName": "Coprinus comatus",
                "commonName": "Barbuda (Urbeltz galparduna)",
                "riskLevel": "excellent",
                "difference": "Coprinus comatus es blanco puro, cilíndrico-alargado y cubierto de mechas o escamas lanosas."
            }
        ]
    },
    {
        "id": "cortinarius_caperatus",
        "scientificName": "Cortinarius caperatus (Rozites caperatus)",
        "spanishName": "Seta arrugada / Rozites arrugada",
        "basqueName": "ziza zimurra",
        "family": "Cortinariaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Finales de Verano y Otoño",
        "habitat": "Hayedos y pinares de montaña sobre suelos ácidos con arándanos.",
        "summary": "El único cortinario tradicionalmente apreciado en la cocina, caracterizado por su sombrero arrugado recubierto de una pruina lila-blanquecina y su anillo membranoso.",
        "morphology": {
            "cap": "De 5 a 12 cm, globoso y luego extendido con mamelón, color ocre leonado cubierto en el centro de una escarcha blanquecino-violácea y margen arrugado.",
            "hymenium": "Láminas adnatas con el borde aserrado, de color arcilla a ocre ferruginoso.",
            "stem": "Cilíndrico, blanquecino-ocre con un anillo membranoso bien formado y ápice lila tenue de joven.",
            "flesh": "Blanquecina, tierna, de olor y sabor suaves."
        },
        "confusions": [
            {
                "mushroomId": "cortinarius_orellanus",
                "scientificName": "Cortinarius orellanus",
                "commonName": "Cortinario de montaña (Sare-ziza hilgarria)",
                "riskLevel": "deadly",
                "difference": "Cortinarius orellanus carece de anillo membranoso (solo tiene restos de cortina aracnoidea) y es de color pardo-naranja zorruno."
            }
        ]
    },
    {
        "id": "cortinarius_orellanus",
        "scientificName": "Cortinarius orellanus",
        "spanishName": "Cortinario de montaña",
        "basqueName": "Sare-ziza hilgarria",
        "family": "Cortinariaceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Finales de Verano y Otoño",
        "habitat": "Robledales, hayedos y castañares en suelos ácidos.",
        "summary": "Especie mortal que contiene orellanina, una nefrotóxina traicionera cuyos síntomas de fallo renal pueden tardar de 3 a 14 días en manifestarse.",
        "morphology": {
            "cap": "De 3 a 8 cm, cónico-convexo con mamelón obtuso, cutícula seca y aterciopelada de color pardo anaranjado o rojo zorro.",
            "hymenium": "Láminas gruesas y espaciadas, escotadas, color naranja-canela vivo a herrumbre.",
            "stem": "Cilíndrico, amarillo dorado a leonado, con fugaz cortina amarillenta.",
            "flesh": "Amarillenta-rojiza con olor débil a rábano."
        },
        "confusions": [
            {
                "mushroomId": "cantharellus_cibarius",
                "scientificName": "Cantharellus cibarius",
                "commonName": "Rebozuelo (Ziza horia)",
                "riskLevel": "excellent",
                "difference": "El rebozuelo tiene pliegues decurrentes amarillos y sombrero embudado, nunca láminas escotadas color herrumbre."
            }
        ]
    },
    {
        "id": "cortinarius_praestans",
        "scientificName": "Cortinarius praestans",
        "spanishName": "Cortinario excelente",
        "basqueName": "Sare-ziza bikaina",
        "family": "Cortinariaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Otoño",
        "habitat": "Hayedos y robledales sobre suelos calizos (Navarra, Álava y Gipuzkoa).",
        "summary": "Cortinario gigante y muy carnoso (parece un gran boleto de joven) con restos de velo blanco violáceo y margen arrugado.",
        "morphology": {
            "cap": "De 10 a 25 cm, muy carnoso, hemisférico, pardo violáceo a castaño con placas blanquecinas del velo y margen estriado-arrugado.",
            "hymenium": "Láminas apretadas, blanquecinas con tinte lila y luego color arcilla-canela.",
            "stem": "Muy grueso y bulboso, cubierto de bandas sedosas blanquecino-violáceas.",
            "flesh": "Espesa, firme, blanquecina e inodora."
        },
        "confusions": [
            {
                "mushroomId": "clitocybe_nebularis",
                "scientificName": "Clitocybe nebularis",
                "commonName": "Pardilla (Ilarraka)",
                "riskLevel": "caution",
                "difference": "La pardilla no tiene cortina ni esporada color herrumbre y huele de forma muy penetrante."
            }
        ]
    },
    {
        "id": "craterellus_cornucopioides",
        "scientificName": "Craterellus cornucopioides",
        "spanishName": "Trompeta de los muertos / Cuerno de la abundancia",
        "basqueName": "Hildakoen tronpeta / Saltsa-perretxiko beltza",
        "family": "Cantharellaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño e Invierno templado (Septiembre - Enero)",
        "habitat": "En grupos numerosos entre el musgo y la hojarasca húmeda de hayedos y robledales.",
        "summary": "Pese a su lúgubre nombre y color negro, es una seta culinaria extraordinaria ('la trufa de los pobres'), ideal tanto fresca como deshidratada y molida.",
        "morphology": {
            "cap": "De 3 a 8 cm, profundamente infundibuliforme (en forma de trompeta hueca hasta la base del pie) con borde ondulado, negro en húmedo y gris pardo en seco.",
            "hymenium": "Cara externa casi lisa o apenas arrugada (SIN láminas ni pliegues marcados), de color gris ceniza azulado.",
            "stem": "Continuación tubular y hueca del sombrero, estrechándose hacia la base negra.",
            "flesh": "Muy delgada, elástica y membranosa, negra, con delicioso aroma afrutado a ciruela/trufa al secarse."
        },
        "confusions": [
            {
                "mushroomId": "craterellus_cinereus",
                "scientificName": "Craterellus cinereus (Cantharellus cinereus)",
                "commonName": "Rebozuelo ceniciento",
                "riskLevel": "excellent",
                "difference": "También excelente comestible; presenta pliegues decurrentes bien marcados en la cara exterior."
            }
        ]
    },
    {
        "id": "craterellus_lutescens",
        "scientificName": "Craterellus lutescens (Cantharellus lutescens)",
        "spanishName": "Angula de monte / Trompeta amarilla",
        "basqueName": "Saltsa-perretxiko horiluna / Mendiko angula",
        "family": "Cantharellaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño tardío e Invierno (Octubre - Febrero)",
        "habitat": "En grandes colonias sobre musgo húmedo en pinares (Pinus sylvestris, P. radiata).",
        "summary": "Conocida junto a C. tubaeformis como 'angula de monte'; se distingue por su pie de color naranja vivo brillante y su cara inferior casi lisa.",
        "morphology": {
            "cap": "De 2 a 6 cm, embudado y perforado en el centro, margen muy rizado, color pardo oscuro fibrilloso.",
            "hymenium": "Superficie externa casi lisa o con venas muy bajas (sin pliegues laminares definidos), de color amarillo-anaranjado o salmón.",
            "stem": "Hueco, comprimido, de un llamativo color amarillo-naranja brillante.",
            "flesh": "Delgada y elástica, con un intenso y exquisito aroma afrutado a mirabel o ciruela."
        },
        "confusions": [
            {
                "mushroomId": "craterellus_tubaeformis",
                "scientificName": "Craterellus tubaeformis",
                "commonName": "Rebozuelo atrompetado / Angula de monte (Saltsa-perretxiko horiluna)",
                "riskLevel": "excellent",
                "difference": "Ambos son excelentes; C. tubaeformis tiene pliegues bien formados gris-amarillentos bajo el sombrero y pie amarillo más apagado."
            }
        ]
    },
    {
        "id": "craterellus_tubaeformis",
        "scientificName": "Craterellus tubaeformis (Cantharellus tubaeformis)",
        "spanishName": "Angula de monte / Rebozuelo atrompetado",
        "basqueName": "mendiko angula / Tronpeta horia",
        "family": "Cantharellaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño e Invierno",
        "habitat": "Suelos ácidos y musgosos en pinares, hayedos y robledales, y sobre madera muy descompuesta.",
        "summary": "La célebre 'angula de monte' de la cocina vasca otoñal, con sombrero pardo umbilicado, pliegues grises y pie hueco amarillo.",
        "morphology": {
            "cap": "De 2 a 6 cm, convexo-umbilicado a infundibuliforme (a menudo perforado hacia el pie), pardo grisáceo a marrón oscuro.",
            "hymenium": "Pliegues decurrentes bien marcados, gruesos y bifurcados, de color amarillo ocre a gris violáceo.",
            "stem": "Largo, hueco, surcado longitudinalmente, de color amarillo mostaza o amarillo oro.",
            "flesh": "Elástica y delgada, de excelente sabor y textura en revueltos y guisos."
        },
        "confusions": [
            {
                "mushroomId": "leotia_lubrica",
                "scientificName": "Leotia lubrica",
                "commonName": "Leotia viscosa",
                "riskLevel": "non_edible",
                "difference": "Leotia lubrica es gelatinosa/viscosa y su sombrero redondeado y lobulado carece por completo de pliegues en la cara inferior."
            }
        ]
    },
    {
        "id": "entoloma_sinuatum",
        "scientificName": "Entoloma sinuatum (Entoloma lividum)",
        "spanishName": "Seta engañosa / Perfidia",
        "basqueName": "Ziza maltzurra / Azpigorri maltzurra",
        "family": "Entolomataceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Finales de Verano y Otoño",
        "habitat": "Bosques de frondosas (robledales y hayedos) sobre suelos arcillosos o calizos.",
        "summary": "Responsable del mayor número de intoxicaciones en el País Vasco por su gran parecido con la Pardilla (Ilarraka) y su engañoso buen olor a harina.",
        "morphology": {
            "cap": "De 6 a 18 cm, carnoso, convexo con mamelón ancho, cutícula sedosa de color gris marfil, crema-ocre o pardo pálido.",
            "hymenium": "Láminas libres o claramente ESCOTADAS (nunca decurrentes), primero de un característico amarillo mantequilla y al madurar rosa salmón.",
            "stem": "Robusto, macizo, blanco y sedoso, engrosado en la base.",
            "flesh": "Blanca y firme, con agradable olor a harina fresca que engaña al recolector. Provoca gastroenteritis aguda severa."
        },
        "confusions": [
            {
                "mushroomId": "clitocybe_nebularis",
                "scientificName": "Clitocybe nebularis",
                "commonName": "Pardilla (Ilarraka)",
                "riskLevel": "caution",
                "difference": "La Pardilla tiene láminas decurrentes blanquecinas (nunca amarillas ni rosas) y un olor aromático penetrante distinto a la harina."
            },
            {
                "mushroomId": "calocybe_gambosa",
                "scientificName": "Calocybe gambosa",
                "commonName": "Perretxiko (Udaberriko ziza)",
                "riskLevel": "excellent",
                "difference": "El Perretxiko es primaveral y tiene láminas muy apretadas y estrechas de color blanco-crema constante."
            }
        ]
    },
    {
        "id": "fistulina_hepatica",
        "scientificName": "Fistulina hepatica",
        "spanishName": "Lengua de buey / Hígado de buey",
        "basqueName": "Idi-mihia / Idi-gibela",
        "family": "Fistulinaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Finales de Verano y Otoño",
        "habitat": "Sobre troncos vivos o tocones de robles (Quercus) y castaños (Castanea sativa).",
        "summary": "Sorprendente hongo lignícola que parece un filete de carne o hígado crudo sangrante adherido al tronco de robles y castaños.",
        "morphology": {
            "cap": "De 10 a 25 cm, en forma de lengua o consola lateral carnosa, superficie gelatinosa roja sangre a granate oscuro.",
            "hymenium": "Tubos cilíndricos independientes entre sí con poros blanco-amarillentos que se manchan de pardo rojizo al tocarlos.",
            "stem": "Lateral, muy corto o ausente.",
            "flesh": "Gruesa, jugosa, veteada de rojo y blanco exactamente igual que la carne vacuna, exuda jugo rojizo y tiene sabor ácido."
        },
        "confusions": [
            {
                "mushroomId": "laetiporus_sulphureus",
                "scientificName": "Laetiporus sulphureus",
                "commonName": "Pollo de bosque (Basoko oilaskoa)",
                "riskLevel": "caution",
                "difference": "El pollo de bosque es de color amarillo azufre y naranja brillante, nunca rojo sangre."
            }
        ]
    },
    {
        "id": "flammulina_velutipes",
        "scientificName": "Flammulina velutipes",
        "spanishName": "Colibia de pie aterciopelado / Enoki silvestre",
        "basqueName": "Neguko ziza hankabelusa",
        "family": "Physalacriaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Finales de Otoño e Invierno (resiste las heladas)",
        "habitat": "En ramilletes sobre troncos y tocones de frondosas (sauces, chopos, olmos, hayas).",
        "summary": "Seta invernal capaz de fructificar bajo la nieve, con sombrero viscoso naranja-miel y pie negro aterciopelado.",
        "morphology": {
            "cap": "De 2 a 8 cm, convexo a plano, muy viscoso en tiempo húmedo, de color amarillo-naranja a miel rojizo más oscuro en el centro.",
            "hymenium": "Láminas adnatas, poco apretadas, blanquecinas a crema amarillento (esporada blanca).",
            "stem": "Curvado, sin anillo, tenaz, cubierto de un fino terciopelo marrón oscuro a negro desde la base.",
            "flesh": "Blanco-amarillenta, elástica; solo se consumen los sombreros."
        },
        "confusions": [
            {
                "mushroomId": "galerina_marginata",
                "scientificName": "Galerina marginata",
                "commonName": "Galerina rebordeada (Galerina hilgarria)",
                "riskLevel": "deadly",
                "difference": "¡Mucha atención! Galerina marginata tiene un pequeño anillo en el pie (que NO es negro aterciopelado), láminas color canela por su esporada parda y olor harinoso."
            }
        ]
    },
    {
        "id": "galerina_marginata",
        "scientificName": "Galerina marginata",
        "spanishName": "Galerina rebordeada",
        "basqueName": "Galerina hilgarria",
        "family": "Hymenogastraceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Otoño e Invierno",
        "habitat": "Sobre madera muerta y tocones musgosos de coníferas y frondosas.",
        "summary": "Pequeña seta lignícola mortal (contiene las mismas amatoxinas que Amanita phalloides) que puede confundirse con especies comestibles de tronco.",
        "morphology": {
            "cap": "De 2 a 5 cm, convexo-acampanado a plano con mamelón, higrófano, color miel o pardo ocre en húmedo y ocre pálido en seco.",
            "hymenium": "Láminas adnatas, apretadas, ocre pálido a marrón herrumbre al madurar.",
            "stem": "Delgado, pardo con fibrillas blanquecinas plateadas debajo de un pequeño anillo membranoso fugaz.",
            "flesh": "Delgada, pardo-ocrácea, con claro olor y sabor a harina rancia."
        },
        "confusions": [
            {
                "mushroomId": "kuehneromyces_mutabilis",
                "scientificName": "Kuehneromyces mutabilis",
                "commonName": "Foliota cambiante",
                "riskLevel": "good",
                "difference": "Kuehneromyces mutabilis tiene el pie cubierto de escamas erizadas por debajo del anillo y olor aromático fúngico (no harinoso)."
            },
            {
                "mushroomId": "flammulina_velutipes",
                "scientificName": "Flammulina velutipes",
                "commonName": "Enoki silvestre (Neguko ziza)",
                "riskLevel": "good",
                "difference": "Flammulina tiene el sombrero viscoso, pie aterciopelado negro sin anillo y láminas blanco-crema."
            }
        ]
    },
    {
        "id": "ganoderma_lucidum",
        "scientificName": "Ganoderma lucidum",
        "spanishName": "Pipa / Reishi",
        "basqueName": "Ardagai pipaduna",
        "family": "Ganodermataceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Verano y Otoño",
        "habitat": "En la base de troncos y tocones de robles, encinas y castaños.",
        "summary": "Espectacular hongo leñoso de aspecto barnizado o lacado en tonos caoba y ámbar con pie lateral en forma de pipa.",
        "morphology": {
            "cap": "De 5 a 20 cm, arriñonado o en abanico, superficie brillante como si estuviera lacada, rojo caoba en el centro y amarillo-blanco en el borde de crecimiento.",
            "hymenium": "Poros diminutos blanquecinos que se manchan de pardo al tocarlos.",
            "stem": "Lateral, cilíndrico y nudoso, con la misma costra lacada brillante color caoba oscuro.",
            "flesh": "Suberosa y leñosa (dura como la madera), utilizada tradicionalmente en infusiones medicinales pero no comestible en cocina."
        },
        "confusions": []
    },
    {
        "id": "gomphidius_glutinosus",
        "scientificName": "Gomphidius glutinosus",
        "spanishName": "Gomfidio mucoso / Llenega gris",
        "basqueName": "Lerdeki mukitsua",
        "family": "Gomphidiaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Otoño",
        "habitat": "Bosques de coníferas de montaña (especialmente abetos y piceas, y pinares húmedos).",
        "summary": "Seta cubierta de una gruesa capa de mucílago transparente y base del pie de un intenso color amarillo limón.",
        "morphology": {
            "cap": "De 5 a 12 cm, convexo a deprimido, color pardo grisáceo con manchas negras, envuelto en un velo glutinoso muy viscoso (hay que retirar la cutícula antes de cocinar).",
            "hymenium": "Láminas gruesas, espaciadas y muy decurrentes, blanquecinas y finalmente gris-negruzcas.",
            "stem": "Cilíndrico, viscoso con zona anular glutinosa, blanco arriba y amarillo cromo vivo en la base.",
            "flesh": "Blanca y tierna en el sombrero, amarillo limón en la base del pie."
        },
        "confusions": [
            {
                "mushroomId": "hygrophorus_latitabundus",
                "scientificName": "Hygrophorus latitabundus",
                "commonName": "Mocosa / Llenega negra (Ezko beltza)",
                "riskLevel": "excellent",
                "difference": "La llenega tiene las láminas siempre blancas (esporada blanca) y no tiene la base del pie amarillo cromo."
            }
        ]
    },
    {
        "id": "gomphus_clavatus",
        "scientificName": "Gomphus clavatus",
        "spanishName": "Oreja de cerdo / Clava truncada",
        "basqueName": "Txerri-belarria",
        "family": "Gomphaceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Verano y Otoño",
        "habitat": "Hayedos y abetales montanos sobre suelos calcáreos (Pirineo navarro y sierras calizas vascas).",
        "summary": "Singular seta en forma de maza truncada o cono invertido con pliegues externos de un bello color violeta lila.",
        "morphology": {
            "cap": "De 4 a 10 cm, turbinado con la parte superior plana o deprimida y borde ondulado, ocre-amarillento a lila.",
            "hymenium": "Pliegues venosos anastomosados muy decurrentes por la cara externa, de color violeta amatista a púrpura-ocráceo.",
            "stem": "Corto, a menudo soldado en la base con otros ejemplares.",
            "flesh": "Espesa, blanca y tierna (protegida en muchas regiones por su rareza)."
        },
        "confusions": [
            {
                "mushroomId": "cantharellus_cibarius",
                "scientificName": "Cantharellus cibarius",
                "commonName": "Rebozuelo (Ziza horia)",
                "riskLevel": "excellent",
                "difference": "El rebozuelo es íntegramente amarillo oro sin tonos violetas."
            }
        ]
    },
    {
        "id": "grifola_frondosa",
        "scientificName": "Grifola frondosa",
        "spanishName": "Maitake / Carnero de los castaños",
        "basqueName": "Gaztainondo-ardagaia",
        "family": "Meripilaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Finales de Verano y Otoño",
        "habitat": "En la base de viejos robles y castaños.",
        "summary": "Gran masa coraliforme de múltiples sombreros superpuestos en forma de abanico o espátula gris-parda; muy apreciada de joven.",
        "morphology": {
            "cap": "Conjunto globoso de 20 a 50 cm compuesto por decenas de sombreros espatulados de 3 a 7 cm, color pardo grisáceo con margen ondulado.",
            "hymenium": "Poros pequeños y decurrentes de color blanco puro (NO ennegrecen al tocarlos).",
            "stem": "Tronco basal blanco muy ramificado.",
            "flesh": "Blanca, fibrosa pero tierna en ejemplares jóvenes, con agradable olor fúngico."
        },
        "confusions": [
            {
                "mushroomId": "meripilus_giganteus",
                "scientificName": "Meripilus giganteus",
                "commonName": "Políporo gigante",
                "riskLevel": "non_edible",
                "difference": "Meripilus giganteus tiene sombreros mucho más grandes y sus poros blancos se manchan de negro al presionarlos."
            }
        ]
    },
    {
        "id": "gyromitra_esculenta",
        "scientificName": "Gyromitra esculenta",
        "spanishName": "Bonete / Falsa colmenilla",
        "basqueName": "Muino-ziza / Mitra muinoduna",
        "family": "Discinaceae",
        "edibility": "deadly",
        "edibilityLabel": "Mortal",
        "season": "Primavera (Marzo - Junio)",
        "habitat": "Bosques de coníferas de montaña (pinares silvestres y abetales).",
        "summary": "Pese a su antiguo nombre científico ('esculenta'), contiene giromitrina (hidrazinas volátiles y acumulativas) y es potencialmente mortal.",
        "morphology": {
            "cap": "De 4 a 10 cm, con aspecto de cerebro muy plegado y circunvolucionado (NO tiene alvéolos de panal), de color marrón rojizo o castaño oscuro.",
            "hymenium": "Sobre la superficie externa de los pliegues cerebriformes.",
            "stem": "Corto, hueco o cavernoso, blanquecino o ligeramente rosado.",
            "flesh": "Cérea y quebradiza. Tóxica mortal incluso por inhalación de los vapores de cocción."
        },
        "confusions": [
            {
                "mushroomId": "morchella_esculenta",
                "scientificName": "Morchella esculenta",
                "commonName": "Colmenilla (Karraspina)",
                "riskLevel": "caution",
                "difference": "Las auténticas colmenillas (Morchella) tienen alvéolos profundos como un panal de abejas, nunca pliegues con forma de cerebro."
            }
        ]
    },
    {
        "id": "helvella_crispa",
        "scientificName": "Helvella crispa",
        "spanishName": "Oreja de gato blanca / Silla de montar blanca",
        "basqueName": "Mitra zuria",
        "family": "Helvellaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Otoño",
        "habitat": "Bordes de caminos forestales, claros de hayedos, robledales y pinares.",
        "summary": "Inconfundible seta otoñal con sombrero lobulado en forma de silla de montar blanquecina y pie profundamente acostillado y cavernoso.",
        "morphology": {
            "cap": "Mitra de 3 a 7 cm compuesta por 2 a 4 lóbulos ondulados en silla de montar, color blanco crema a ocre pálido.",
            "hymenium": "En la cara superior de los lóbulos.",
            "stem": "De 4 a 10 cm, blanco, recorrido longitudinalmente por profundas costillas y surcos con huecos internos.",
            "flesh": "Elástica y tenaz; contiene trazas de giromitrina y es hemolítica, por lo que hoy se considera tóxica."
        },
        "confusions": [
            {
                "mushroomId": "helvella_lacunosa",
                "scientificName": "Helvella lacunosa",
                "commonName": "Oreja de gato negra (Mitra beltza)",
                "riskLevel": "toxic",
                "difference": "De morfología casi idéntica pero de color gris plomo a negro pizarra."
            }
        ]
    },
    {
        "id": "helvella_lacunosa",
        "scientificName": "Helvella lacunosa",
        "spanishName": "Oreja de gato negra / Mitra negra",
        "basqueName": "Mitra beltza",
        "family": "Helvellaceae",
        "edibility": "toxic",
        "edibilityLabel": "Tóxica",
        "season": "Otoño",
        "habitat": "Bordes de senderos, zonas carboneras y bosques de frondosas y coníferas.",
        "summary": "Hermana oscura de Helvella crispa, con mitra lobulada negra y pie surcado por costillas longitudinales grisáceas.",
        "morphology": {
            "cap": "Mitra irregular de 3 a 8 cm en silla de montar de color gris oscuro a negro.",
            "hymenium": "Sobre la superficie externa de los lóbulos.",
            "stem": "Robusto, grisáceo, profundamente lacunoso y acostillado.",
            "flesh": "Delgada, grisácea; tóxica en crudo y desaconsejada por contener hidrazinas."
        },
        "confusions": [
            {
                "mushroomId": "craterellus_cornucopioides",
                "scientificName": "Craterellus cornucopioides",
                "commonName": "Trompeta de los muertos (Hildakoen tronpeta)",
                "riskLevel": "excellent",
                "difference": "La trompeta de los muertos tiene forma de embudo hueco continuo, no una mitra en silla de montar sobre pie acostillado."
            }
        ]
    },
    {
        "id": "hydnum_repandum",
        "scientificName": "Hydnum repandum",
        "spanishName": "Lengua de gato / Gamuza",
        "basqueName": "Tripaki argia / Negu-ziza",
        "family": "Hydnaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño e Invierno (Septiembre - Febrero)",
        "habitat": "Hayedos, robledales y pinares formando hileras o corros.",
        "summary": "Una de las setas más seguras y apreciadas en Euskadi ('Tripaki argia'), facilísima de identificar por tener aguijones bajo el sombrero en vez de láminas.",
        "morphology": {
            "cap": "De 4 a 15 cm, carnoso, irregular y abollado con margen lobulado, cutícula seca aterciopelada de color crema, gamuza o salmón pálido.",
            "hymenium": "Formado por aguijones o espinas cónicas, frágiles y decurrentes del mismo color crema-gamuza que se desprenden fácilmente al pasar el dedo.",
            "stem": "Corto, grueso, a menudo excéntrico, blanquecino que amarillea al roce.",
            "flesh": "Dura y quebradiza, blanca (nunca se agusanada), sabor suave con un ligerísimo toque picante/amargo en ejemplares viejos (raspar los aguijones)."
        },
        "confusions": [
            {
                "mushroomId": "hydnum_rufescens",
                "scientificName": "Hydnum rufescens",
                "commonName": "Lengua de gato rojiza (Tripaki gorrizta)",
                "riskLevel": "excellent",
                "difference": "Igualmente buen comestible; es más pequeña, de color naranja rojizo más vivo y aguijones NO decurrentes."
            }
        ]
    },
    {
        "id": "hydnum_rufescens",
        "scientificName": "Hydnum rufescens",
        "spanishName": "Lengua de gato rojiza / Gamuza rojiza",
        "basqueName": "Tripaki gorrizta",
        "family": "Hydnaceae",
        "edibility": "excellent",
        "edibilityLabel": "Excelente comestible",
        "season": "Otoño e Invierno",
        "habitat": "Bosques de frondosas (hayedos y robledales) y coníferas.",
        "summary": "Hermana más esbelta y de color naranja-teja de la lengua de gato común, igualmente segura y deliciosa.",
        "morphology": {
            "cap": "De 3 a 8 cm, más regular y delgado que H. repandum, de color naranja ladrillo o leonado vivo.",
            "hymenium": "Aguijones frágiles color crema-anaranjado que se detienen netamente al llegar al pie (no decurrentes).",
            "stem": "Más largo, central y esbelto, blanquecino-anaranjado.",
            "flesh": "Quebradiza, blanca-anaranjada; excelente en guisos tras retirar los aguijones en ejemplares adultos."
        },
        "confusions": [
            {
                "mushroomId": "hydnum_repandum",
                "scientificName": "Hydnum repandum",
                "commonName": "Lengua de gato (Tripaki argia)",
                "riskLevel": "excellent",
                "difference": "Hydnum repandum es más grande, color crema-gamuza claro y tiene aguijones decurrentes por el pie."
            }
        ]
    },
    {
        "id": "hygrophoropsis_aurantiaca",
        "scientificName": "Hygrophoropsis aurantiaca",
        "spanishName": "Falso rebozuelo",
        "basqueName": "Ziza-hori faltsua",
        "family": "Hygrophoropsidaceae",
        "edibility": "non_edible",
        "edibilityLabel": "Sin valor culinario",
        "season": "Otoño",
        "habitat": "Pinares y bosques de coníferas sobre acículas o restos de madera en descomposición.",
        "summary": "Seta de pinares muy parecida a la Ziza horia (Cantharellus cibarius) pero con láminas verdaderas bifurcadas naranja vivo y carne fofa.",
        "morphology": {
            "cap": "De 3 a 8 cm, convexo a embudado con margen enrollado, cutícula tomentosa naranja-amarillenta a pardo-anaranjada.",
            "hymenium": "Láminas verdaderas (no pliegues), delgadas, apretadas, repetidamente bifurcadas en 'Y' y de color naranja intenso.",
            "stem": "Delgado, elástico, a menudo curvado, naranja a pardo oscuro en la base.",
            "flesh": "Blanda, esponjosa e inodora, sin interés gastronómico e indigesta en cantidad."
        },
        "confusions": [
            {
                "mushroomId": "cantharellus_cibarius",
                "scientificName": "Cantharellus cibarius",
                "commonName": "Rebozuelo (Ziza horia)",
                "riskLevel": "excellent",
                "difference": "El verdadero rebozuelo tiene pliegues gruesos como nervios (no láminas finas), carne firme y aroma afrutado a albaricoque."
            }
        ]
    },
    {
        "id": "hygrophorus_agathosmus",
        "scientificName": "Hygrophorus agathosmus",
        "spanishName": "Higróforo de buen olor / Llenega gris olorosa",
        "basqueName": "Ezko миngots-usainduna",
        "family": "Hygrophoraceae",
        "edibility": "good",
        "edibilityLabel": "Buen comestible",
        "season": "Otoño",
        "habitat": "Bosques de coníferas (pinares y abetales).",
        "summary": "Higróforo gris perla viscoso con un inconfundible y delicioso olor a almendras amargas o pegamento escolar.",
        "morphology": {
            "cap": "De 4 a 9 cm, convexo-mamelonado, viscoso, color gris ceniza o gris perla uniforme.",
            "hymenium": "Láminas espaciadas, gruesas y céreas, adnato-decurrentes, blancas.",
            "stem": "Cilíndrico, seco, blanco con granulaciones en el ápice.",
            "flesh": "Tierna, blanca, con intenso aroma a almendras amargas (ácido cianhídrico en trazas aromáticas)."
        },
        "confusions": [
            {
                "mushroomId": "hygrophorus_latitabundus",
                "scientificName": "Hygrophorus latitabundus",
                "commonName": "Mocosa / Llenega negra (Ezko beltza)",
                "riskLevel": "excellent",
                "difference": "Hygrophorus latitabundus es mucho más robusto, muy mucoso en el pie y no huele a almendras amargas."
            }
        ]
    }
]
