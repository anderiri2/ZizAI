<div align="center">

🌐 **Language / Hizkuntza / Idioma**: [**English**](README.md) | **Euskara** | [**Español**](README.es.md)

</div>

---

# 🍄 ZizAI — Lineaz Kanpoko Gida Mikologikoa, Setalen Mapa Pribatua eta GPS Ibilbideak

**ZizAI** perretxiko-bilketaren zaleentzako **Flutter**-en garatutako plataforma anitzeko aplikazioa da (Android eta iOS). Arkitektura **%100 autonomoarekin (zerbitzari propiorik gabe eta %100 pribatua)** funtzionatzen du, datu guztiak gailuan bertan (`SQLite`) gordez eta erabiltzailearen Google kontu pertsonala **Google Drive (`appDataFolder`)** segurtasun-kopia pribatuetarako erabiltzeko aukera emanez.

🌐 **Webgune Ofiziala (GitHub Pages)**: [https://anderiri2.github.io/ZizAI/](https://anderiri2.github.io/ZizAI/)

---

## 🧪 Google Play-rako Beta Tester Bila Gabiltza! (14 eguneko proba)

> [!IMPORTANT]
> **ZizAI Google Play Store-n argitaratzen lagundu nahi diguzu?**
> Garatzaile independenteen aplikazioak produkzioan argitaratu ahal izateko, Google Play-k **gutxienez 12 erabiltzailek aplikazioa 14 egunez jarraian modu jarraituan probatzea** eskatzen du proba itxi batean.

### 🤝 Zertan datza zure laguntza?
1. **Proba itxian izena ematea** zure Google Play (Android) kontuarekin.
2. **ZizAI instalatzea** sarbidea aktibatzen dizugunean.
3. **Aplikazioa 14 egunez jarraian instalatuta mantentzea** eta aldian-aldian irekitzea bere funtzioak probatzeko (lineaz kanpoko katalogoa, satelite/topo mapak, GPS ibilbideak eta babeskopiak).

👉 **Parte hartu nahi duzu?** [**Ireki Issue bat hemen GitHub-en**](https://github.com/AnderIri2/ZizAI/issues/new?title=Beta+Tester+Google+Play&body=Kaixo,+ZizAI-ren+14+eguneko+proban+parte+hartu+nahi+dut.) beta tester zerrendan izena emateko. Mila esker proiektua babesteagatik! 🍄

---

## ✨ Ezaugarri Nagusiak

### 1. 📖 Perretxikoak (%100 Lineaz Kanpoko Katalogo Mikologikoa — 126 Espezie eta 252 Benetako Argazki)
- **Lokalizazio Hirueledun Osoa**: testuak eta fitxak **Euskaraz**, **Gaztelaniaz** eta **Ingelesez** (sistemaren hizkuntza automatikoki detektatzen du, ingeleseko lehenespenerako babesarekin).
- **A–Z** ordenazio alfabetikoa **Euskararen**, **Gaztelaniaren**, **Ingelesaren** edo **Izen Zientifikoaren (Latina)** arabera hautagarria.
- Denbora errealeko bilatzailea (azentu-markekiko sentikorra ez dena) eta iragazki azkarrak (*Bikainak*, *Jangarriak*, *Kontuz*, *Toxikoak/Hilgarriak*, *Udazkena*, *Udaberria*, *Gogokoak*).
- Fitxa xehatua benetako argazkien karruselarekin, morfologia 4 bloketan (*Txapela*, *Himenioa*, *Hanka*, *Mamia, Usaina eta Zaporea*), habitata, garaia, jangarritasun-maila 6 gradutan eta fitxen artean estekatutako **Nahasketa Ohiko Interaktiboak**.
- **Kokapen Interaktibo Zuzena Mapan**: *"Gorde perretxiko honen kokapena Mapan"* botoia, mapa banner interaktibo batekin irekitzen duena markatzailea ukitu bakar batez kokatzeko.

### 2. 🗺️ Mapa Orokorra: Satelite, Topografia Geruzak eta Lineaz Kanpoko Deskarga
- **3 Geruza Kartografiko Aldagarri**:
  - **Bereizmen Handiko Satelitea (`Esri World Imagery`)**: etiketa artifizialik gabeko ortofoto hutsa, baso-masak argi identifikatzeko (pinudiak, pagadiak, hariztiak, soilguneak eta baso-pistak).
  - **Topografikoa sestra-kurbekin (`OpenTopoMap`)**: erliebea eta hipsometria maldak eta desnibelak planifikatzeko.
  - **Estandarra (`OpenStreetMap`)**: baso-pisten, bideen eta sarbide-errepideen sarea.
- **Orientazio Bertikal Finkoko Markatzaileak (`rotate: true`)**: ale-kopurua eta espeziearen ikonoa automatikoki kontra-biratzen dira mapa biratzean beti irakurgarri eta zuzen mantentzeko.
- **Perretxiko-lekuak Gordetzeko Modu Anitzak**:
  - **Satelite bidezko GPS Kokapena**: radar modala (`GpsAcquisitionSheet`), gorde aurretik satelite-finkapen zehatza (< 15 m) bermatzen duena.
  - **Markatu Hatzarekin Mapan (Itu Interaktiboarekin)**: zehaztasun handiko erdiko erretikula gurutze-mirarekin, kontraste-haloekin eta pin flotatzailearekin; mapako edozein puntutan hatzarekin ukitzea ahalbidetzen du itua berehala erdiratzeko edo mapa hatzarekin mugitzeko doikuntza milimetrikoak egiteko.
  - **Koordenatuen Eskuzko Sarrera**: latitudea eta longitudea zuzenean sartzeko aukera.
- **Cache Automatikoa eta Lineaz Kanpoko Deskargak (`OfflineCachingTileProvider` & `OfflineMapsSheet`)**: kontsultatutako lauzak diskoan gordetzen ditu eta eskualde pertsonalizatuak edo 6 parke natural mikologiko (*Gorbeia*, *Urbasa eta Andia*, *Irati*, *Aralar*, *Urkiola*, *Izki*) deskargatzeko aukera ematen du, bai modu topografikoan bai satelite moduan, estaldurarik gabeko eremuetan erabiltzeko.
- **Iragazkien eta Ibilbideen Panel Bateratua**: markatzaileak espezie jakin baten arabera (bilatzaile eta argazkiekin), jangarritasun-mailaren arabera, puntu solteak vs irteerak iragazten ditu, eta GPS ibilbideen gainjarri aldiberekoa udazkeneko kolore-paletarekin.

### 3. 🥾 Mendiko Irteerak eta GPS Ibilbideak
- **GPS Eskuratze eta Finkapen Mekanismoa (`GPS Fix Acquisition`)**:
  - Pantaila modala (`GpsAcquisitionSheet`) radar animazioarekin eta metroko zehaztasunaren irakurketa jarraituarekin *Hasi irteera* sakatzean.
  - **Abiarazte adimenduna**: zehaztasun optimoa ($< 15\text{ m}$) lortzean grabazioa automatikoki hasten du 2 segundoko atzerako kontaketa eta baieztapen haptikoaren ondoren.
  - Berehalako hasiera behartzeko botoia eta zehaztasun-pilula flotatzaile ez-intrusiboa (`GpsStatusPill`) mapan erdiratzeko eta koordenatuak markatzeko.
  - **Zarata-iragazki aktiboa**: irakurketa akastunen baztertze automatikoa ($> 35\text{ m}$) eta telegarraio-jauzien blokeoa ($> 400\text{ m}$).
- **Perretxikoen Bilatzaile Erreaktiboa (`MushroomSearchPicker`)**:
  - Aurkikuntza bat erregistratzean integratutako ukipen-hautatzailea, espeziearen txartel bisualarekin (miniatura, izen zientifikoa, herri-izenak eta jangarritasun-bereizgarria).
  - Sarbide azkarreko barra (*quick chips*) udazkeneko ohiko espezieentzat (*Boletus*, *Cantharellus*, *Lactarius*, *Amanita caesarea*, etab.).
  - Pantaila osoko bilaketa teklatua fokatuta eta berehalako iragazketa edozein izen hirueledun edo zientifikoren arabera.
- **Grabazio eta Irteera Modu Malguak**:
  - **Zuzeneko GPS Ibilbidea**: denbora errealeko jarraipena ibilbidearen polilerroarekin, desbideratzerik gabeko kronometroarekin, distantziarekin, Android bigarren planoko jakinarazpenarekin eta saskiaren zenbaketarekin.
  - **Zuzeneko Eskuzko Irteera (Saski Modua)**: %0 satelite-bateria kontsumoa, aurkikuntzak mapa interaktiboan ukituz erregistratuz (`MapSpotPickerScreen`).
  - **Iraganeko Atzera Begirako Irteera**: ondorengo erregistroa datarekin, iraupenarekin eta mapan perretxiko-lekuen hautaketarekin.
- **Mapa Ikuspegi Handitua (`LiveOutingMapScreen`)**: pantaila osoko murgiltze modua satelite/topo/estandar aldagailuarekin, kronometro flotatzailearekin eta erregistro azkarrarekin (*"Erregistratu nire uneko GPSan"* edo *"Kokatu mapan"*).
- **Historia eta Laburpen Txartelak**: benetako mini-mapa kartografikoa (`_OutingRouteMiniMap`) ibilbidearen GPS polilerroarekin, iraupenarekin, distantziarekin eta saskiaren banaketarekin (ale-kopurua eta pisua gramotan).

### 4. ☁️ Segurtasun-kopia Integrala Google Drive-n (`appDataFolder`) Bategite Adimendunarekin
- Erabiltzailearen jarduera guztia (`spots.json`, `outings.json`, `favorites.json`, `offline_regions.json` eta `photos/` argazki-karpeta) `zizai_backup.zip` barruan paketatzen du.
- **Bategite Adimenduna (Smart Merge ID bidez)**: hodeiko urruneko datuak eta tokikoak konbinatzen ditu lehendik dauden irteerak edo perretxiko-lekuak gainidatzi edo bikoiztu gabe (ordezkapen osoko aukerarekin).
- **Kopia Automatikoaren Aukera**: irteera bat amaitzean jarduera Google Drive-n automatikoki sinkronizatzeko aukera.
- **Tokiko ZIP Argazkia** esportatzeko eta inportatzeko euskarria telefonoan bertan Google konexiorik gabe.

### 5. ⚙️ Alboko Panel Irristakorra (`SettingsDrawer`)
- Pantaila nagusiko goiko ezkerreko **ZizAI** ikonoa/logoa sakatuz irekitzen den alboko menua.
- Hizkuntza-hautatzaile dinamikoa (**Euskara**, **Castellano**, **English**).
- Google kontuaren kudeaketa (`appDataFolder`), tokiko ZIP kopietarako sarbide zuzena, **%100 Pribatutasun Bermearen** txartela eta **Segurtasun Mikologikoko Dekalogoa**.

---

## 📱 Onartutako Android eta iOS Bertsioak

| Plataforma | Gutxieneko Bertsioa | Helburuko Bertsioa | Gailuen Estaldura |
| :--- | :--- | :--- | :--- |
| **Android** | **Android 7.0 Nougat (`minSdk = 24`)** | **Android 15 (`targetSdk = 35`)** | Mugikor aktiboen ~%99 |
| **iOS** | **iOS 14.0 (`platform :ios, '14.0'`)** | **iOS 18 SDK** | iPhone 6s / SE-tik aurrera (~%98) |

---

## 🌿 Bertsio-kontrolaren Fluxua (Gitflow)

Biltegiak kodearen bizi-zikloa `feature/*` adarren, `develop`-eko integrazioaren eta `main`-eko etiketa bidezko argitalpenen bidez kudeatzen du:

- `v0.1.0`: Aplikazioaren oinarria, udazkeneko gaia, splash-a, saio-hasiera eta 126 espezieko lineaz kanpoko katalogoa.
- `v0.2.0` (`feature/outings-gps-routes`): Mendiko Irteeren GPS grabagailua, laburpen-txartelak eta iragazkia Mapa Orokorrean.
- `v0.3.0` (`feature/offline-map-regions`): Mapen lineaz kanpoko cachea eta estaldurarik gabeko eremu mikologikoen deskarga.
- `v1.0.0` (`feature/full-activity-drive-backup`): Segurtasun-kopia integrala Google Drive-n (`appDataFolder`) Bategite Adimendunarekin eta tokiko ZIP kopiekin.
- `v1.1.0` (`feature/amanita-caesarea-branding`): *Amanita caesarea* logo eta ikono natibo berriak eta 3 faseko irekiera-splash animatua.
- `v1.2.0` (`feature/trilingual-eu-es-en`): Euskarri hirueledun osoa (`EU` / `ES` / `EN`).
- `v1.3.0` (`feature/custom-caesarea-logo-and-2s-splash`): *Amanita caesarea* logo ilustratua baso iluneko hondoaren gainean eta 2.0 segundoko splash botaniko animatua.
- `v1.4.0` (`feature/settings-drawer-manual-outings`): Ezkerreko panel irristakorra (`SettingsDrawer`), GPSrik gabeko eskuzko eta atzera begirako irteerak.
- `v1.5.0` (`feature/catalog-map-picker-filters-redesign`): Perretxikoen kokapen interaktiboa katalogotik, mapako iragazkien eta ibilbideen panel modal bateratua, irteerako pantaila osoa (`LiveOutingMapScreen`) eta kateak %100ean hizkuntza aktiboan.
- `v1.5.1` (`feature/icon-and-minimap-fixes`): Pantaila osoko ikono moldakor natiboa Android/iOS-en ertz zuririk gabe, benetako mini-mapa kartografikoa irteera-txarteletan eta 4 fitxako beheko nabigazioa (`Perretxikoak`, `Mapa`, `Irteerak`, `Babeskopia`).
- `v1.6.0` (`feature/gps-satellite-mushroom-search`): Satelite bidezko mapa-geruza hutsa (Esri World Imagery), GPS seinalearen eta zehaztasunaren eskuratzea (`GpsAcquisitionSheet`), perretxikoen bilatzaile erreaktiboa (`MushroomSearchPicker`), markatzaileen orientazio bertikal finkoa (`rotate: true`) eta ZizAI izenera birmarkatze integrala.
- `v1.7.0` (`feature/map-gps-accuracy-manual-basket-background`): Radar bidezko GPS finkapen-hautatzailea mapan perretxikoak gordetzean, eskuzko irteerak saski mikologiko huts gisa birdiseinatuta, bigarren planoko Foreground Service jakinarazpen egonkorrarekin eta desbideratzerik gabeko kronometroa.
- `v1.7.1`: Itu interaktiboa gurutze-mirarekin eta mapan hatzarekin ukituz puntuak kokatzeko modua.
- `v1.7.2`: Mapa-geruzen hautatzailea irteeretan, GPS ibilbidearen jarraipen hutsa, bigarren planoko jakinarazpenen hobekuntzak Android-en, Drive-ko `appDataFolder` baimena saioa hastean eta katalogoko argazkien bikoiztasunen ezabaketa (252 benetako argazki bakar).

---

## 🚀 Nola Exekutatu Proiektua

```bash
flutter pub get
flutter test
flutter run
```

Optimizatutako release bitarra konpilatzeko:
```bash
flutter build apk --release
```

Zure Google Cloud proiektuaren OAuth konfiguratzeko (Android SHA-1 / iOS `REVERSED_CLIENT_ID`), kontsultatu [`GOOGLE_SETUP.md`](GOOGLE_SETUP.md).

---

## 📄 Lizentzia

Proiektu hau **GNU General Public License v3.0 (GPLv3)** lizentziapean dago, 7. Atalaren araberako baimen gehigarriekin denda mugikorretan (Google Play / App Store) banatzeko.

- **Iturburu Kodea**: [GNU GPLv3](LICENSE) lizentzia librea.
- **Marka eta Logotipoak**: **ZizAI** izena, markaren tipografia eta logotipo ofiziala Ander Iriondoren jabetza esklusiboa dira eta erreserbatuta daude (edozein fork-ek beste izen eta marka bat erabili behar du).
- **Argazki Edukia eta Katalogoa**: `assets/images/mushrooms/` karpetako jatorrizko argazkiak eta fitxa deskribatzaileak (C) 2026 Ander Iriondo egile-eskubideek babestuta daude aplikazioan soilik erabiltzeko.
