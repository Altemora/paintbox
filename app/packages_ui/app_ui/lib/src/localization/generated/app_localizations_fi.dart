// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Nimetön $number';
  }

  @override
  String get menuFile => 'Tiedosto';

  @override
  String get menuEdit => 'Muokkaa';

  @override
  String get menuView => 'Näytä';

  @override
  String get menuImage => 'Kuva';

  @override
  String get menuLayers => 'Tasot';

  @override
  String get menuAdjustments => 'Säädöt';

  @override
  String get menuEffects => 'Tehosteet';

  @override
  String get menuOpenRecent => 'Viimeksi avatut';

  @override
  String get menuRecentEmpty => 'Ei viimeksi avattuja tiedostoja';

  @override
  String get menuTheme => 'Teema';

  @override
  String get menuSettings => 'Asetukset';

  @override
  String get menuAccent => 'Korostusväri';

  @override
  String get menuLanguage => 'Kieli';

  @override
  String get languageSystem => 'Järjestelmän oletus';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Sininen',
      'green': 'Vihreä',
      'amber': 'Meripihka',
      'purple': 'Violetti',
      'red': 'Punainen',
      'gray': 'Harmaa',
      'custom': 'Mukautettu…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Mukautettu korostusväri';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Järjestelmän oletus';

  @override
  String get themeDark => 'Tumma';

  @override
  String get themeLight => 'Vaalea';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Uusi…',
      'open': 'Avaa…',
      'close': 'Sulje',
      'save': 'Tallenna',
      'save_as': 'Tallenna nimellä…',
      'exit': 'Lopeta',
      'undo': 'Kumoa',
      'redo': 'Tee uudelleen',
      'cut': 'Leikkaa',
      'copy': 'Kopioi',
      'paste': 'Liitä',
      'paste_into_new_layer': 'Liitä uudelle tasolle',
      'paste_into_new_image': 'Liitä uutena kuvana',
      'erase_selection': 'Tyhjennä valittu alue',
      'fill_selection': 'Täytä valinta',
      'invert_selection': 'Käännä valinta',
      'select_all': 'Valitse kaikki',
      'deselect': 'Poista valinta',
      'zoom_in': 'Lähennä',
      'zoom_out': 'Loitonna',
      'zoom_to_window': 'Sovita ikkunaan',
      'zoom_to_selection': 'Sovita valintaan',
      'actual_size': 'Todellinen koko',
      'pixel_grid': 'Pikseliruudukko',
      'rulers': 'Viivaimet',
      'crop_to_selection': 'Rajaa valintaan',
      'resize': 'Muuta kokoa…',
      'canvas_size': 'Kankaan koko…',
      'flip_horizontal': 'Peilaa vaakasuunnassa',
      'flip_vertical': 'Peilaa pystysuunnassa',
      'rotate90_cw': 'Kierrä 90° myötäpäivään',
      'rotate90_ccw': 'Kierrä 90° vastapäivään',
      'rotate180': 'Kierrä 180°',
      'flatten': 'Yhdistä tasot',
      'add_layer': 'Lisää uusi taso',
      'delete_layer': 'Poista taso',
      'duplicate_layer': 'Monista taso',
      'merge_layer_down': 'Yhdistä alempaan tasoon',
      'import_from_file': 'Tuo tiedostosta…',
      'flip_layer_horizontal': 'Peilaa taso vaakasuunnassa',
      'flip_layer_vertical': 'Peilaa taso pystysuunnassa',
      'move_layer_up': 'Siirrä tasoa ylöspäin',
      'move_layer_down': 'Siirrä tasoa alaspäin',
      'layer_properties': 'Tason ominaisuudet…',
      'adjust_auto_level': 'Automaattiset väritasot',
      'adjust_black_and_white': 'Mustavalkoinen',
      'adjust_brightness_contrast': 'Kirkkaus / kontrasti…',
      'adjust_curves': 'Käyrät…',
      'adjust_hue_saturation': 'Sävy / kylläisyys…',
      'adjust_invert_colors': 'Käännä värit',
      'adjust_levels': 'Väritasot…',
      'adjust_posterize': 'Posterointi…',
      'adjust_sepia': 'Seepia',
      'repeat_effect': 'Toista tehoste',
      'effect_oil_painting': 'Öljymaalaus…',
      'effect_gaussian_blur': 'Gaussin sumennus…',
      'effect_motion_blur': 'Liikesumennus…',
      'effect_pixelate': 'Pikselöinti…',
      'effect_add_noise': 'Kohinan lisäys…',
      'effect_median': 'Mediaani…',
      'effect_sharpen': 'Terävöinti…',
      'effect_edge_detect': 'Reunantunnistus…',
      'effect_emboss': 'Korkokuva…',
      'effect_outline': 'Ääriviiva…',
      'toggle_tools': 'Työkalut',
      'toggle_history': 'Historia',
      'toggle_layers': 'Tasot',
      'toggle_colors': 'Värit',
      'next_image': 'Seuraava kuva',
      'previous_image': 'Edellinen kuva',
      'help': 'Ohje',
      'effect_ink_sketch': 'Musteluonnos…',
      'effect_pencil_sketch': 'Lyijykynäluonnos…',
      'effect_fragment': 'Pirstalointi…',
      'effect_radial_blur': 'Säteittäinen sumennus…',
      'effect_surface_blur': 'Pintasumennus…',
      'effect_unfocus': 'Epätarkennus…',
      'effect_zoom_blur': 'Zoomaussumennus…',
      'effect_bulge': 'Pullistuma…',
      'effect_dents': 'Lommot…',
      'effect_frosted_glass': 'Huurrelasi…',
      'effect_polar_inversion': 'Polaarinen inversio…',
      'effect_tile_reflection': 'Laattaheijastus…',
      'effect_twist': 'Kierre…',
      'effect_reduce_noise': 'Kohinanpoisto…',
      'effect_glow': 'Hehku…',
      'effect_red_eye_removal': 'Punasilmäisyyden poisto…',
      'effect_soften_portrait': 'Muotokuvan pehmennys…',
      'effect_clouds': 'Pilvet…',
      'effect_julia_fractal': 'Julia-fraktaali…',
      'effect_mandelbrot_fractal': 'Mandelbrot-fraktaali…',
      'effect_relief': 'Reliefi…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Taiteelliset',
      'blurs': 'Sumennukset',
      'distort': 'Vääristykset',
      'noise': 'Kohina',
      'photo': 'Valokuva',
      'stylize': 'Tyylittely',
      'render': 'Renderöinti',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Suorakulmiovalinta',
      'move_selected_pixels': 'Valittujen pikselien siirto',
      'lasso_select': 'Lassovalinta',
      'move_selection': 'Valinnan siirto',
      'ellipse_select': 'Ellipsivalinta',
      'zoom': 'Zoomaus',
      'magic_wand': 'Taikasauva',
      'pan': 'Panorointi',
      'paint_bucket': 'Täyttö',
      'gradient': 'Liukuväri',
      'paintbrush': 'Sivellin',
      'eraser': 'Pyyhekumi',
      'pencil': 'Lyijykynä',
      'color_picker': 'Väripipetti',
      'clone_stamp': 'Kloonausleimasin',
      'recolor': 'Uudelleenväritys',
      'text': 'Teksti',
      'line_curve': 'Viiva / käyrä',
      'rectangle': 'Suorakulmio',
      'rounded_rectangle': 'Pyöristetty suorakulmio',
      'ellipse': 'Ellipsi',
      'freeform_shape': 'Vapaa muoto',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Valitse suorakulmio vetämällä. Pidä Shift painettuna, niin saat neliön.',
      'move_selected_pixels': 'Siirrä valintaa vetämällä. Kierrä sitä vetämällä oikealla painikkeella ja skaalaa sitä vetämällä kahvoista. Ctrl jättää kopion paikalleen; nuolinäppäimet siirtävät valintaa vähän kerrallaan.',
      'lasso_select': 'Piirrä valinnan ääriviiva vetämällä.',
      'move_selection':
          'Siirrä valinnan ääriviivaa vetämällä. Pikselit pysyvät paikallaan.',
      'ellipse_select': 'Valitse ellipsi vetämällä. Pidä Shift painettuna, niin saat ympyrän.',
      'zoom': 'Lähennä napsauttamalla vasemmalla painikkeella ja loitonna napsauttamalla oikealla, tai vedä kehys, niin näkymä sovitetaan siihen.',
      'magic_wand': 'Napsauta väriä, niin sen ympärillä oleva alue valitaan. Pidä Shift painettuna, niin väri valitaan koko kuvasta.',
      'pan': 'Siirrä näkymää vetämällä.',
      'paint_bucket': 'Vasen napsautus täyttää ensisijaisella värillä, oikea toissijaisella.',
      'gradient': 'Piirrä liukuväri vetämällä. Säädä sitä vetämällä kahvoista; viimeistele painamalla Enter.',
      'paintbrush':
          'Vasen painike maalaa ensisijaisella värillä, oikea toissijaisella.',
      'eraser': 'Pyyhi läpinäkyväksi vetämällä.',
      'pencil':
          'Piirtää yhden pikselin levyisiä viivoja ilman reunanpehmennystä.',
      'color_picker':
          'Vasen napsautus poimii ensisijaisen värin, oikea toissijaisen.',
      'clone_stamp':
          'Aseta lähde Ctrl+napsautuksella ja maalaa siitä sitten vetämällä.',
      'recolor': 'Korvaa toissijaisen värin ensisijaisella siellä, missä maalaat. Ctrl+napsautus poimii värin.',
      'text': 'Aseta kohdistin napsauttamalla ja kirjoita. Siirrä tekstiä vetämällä kahvasta tai oikealla painikkeella; viimeistele painamalla Esc.',
      'line_curve': 'Piirrä viiva vetämällä. Taivuta sitä vetämällä kahvoista; viimeistele painamalla Enter.',
      'rectangle': 'Piirrä suorakulmio vetämällä. Pidä Shift painettuna, niin saat neliön.',
      'rounded_rectangle': 'Piirrä pyöristetty suorakulmio vetämällä. Pidä Shift painettuna, niin saat neliön.',
      'ellipse':
          'Piirrä ellipsi vetämällä. Pidä Shift painettuna, niin saat ympyrän.',
      'freeform_shape': 'Piirrä suljettu vapaa muoto vetämällä.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Säde',
      'angle': 'Kulma',
      'distance': 'Etäisyys',
      'centered': 'Keskitetty',
      'amount': 'Määrä',
      'intensity': 'Intensiteetti',
      'saturation': 'Kylläisyys',
      'coverage': 'Kattavuus',
      'seed': 'Siemen',
      'percentile': 'Persentiili',
      'cell_size': 'Solun koko',
      'brush_size': 'Siveltimen koko',
      'coarseness': 'Karkeus',
      'thickness': 'Paksuus',
      'brightness': 'Kirkkaus',
      'contrast': 'Kontrasti',
      'hue': 'Sävy',
      'lightness': 'Vaaleus',
      'red': 'Punainen',
      'green': 'Vihreä',
      'blue': 'Sininen',
      'input_low': 'Syöte: tumma',
      'input_high': 'Syöte: vaalea',
      'output_low': 'Tuloste: tumma',
      'output_high': 'Tuloste: vaalea',
      'gamma': 'Gamma',
      'ink_outline': 'Musteääriviiva',
      'coloring': 'Väritys',
      'tip_size': 'Kynänkärjen koko',
      'color_range': 'Värialue',
      'fragments': 'Sirpaleet',
      'rotation': 'Kierto',
      'offset_x': 'Siirtymä X',
      'offset_y': 'Siirtymä Y',
      'quality': 'Laatu',
      'threshold': 'Kynnys',
      'scale': 'Mittakaava',
      'refraction': 'Taittuminen',
      'roughness': 'Rosoisuus',
      'tension': 'Jännitys',
      'max_scatter': 'Suurin hajonta',
      'min_scatter': 'Pienin hajonta',
      'samples': 'Näytteiden määrä',
      'edge_behavior': 'Reunojen käsittely',
      'tile_size': 'Laatan koko',
      'curvature': 'Kaarevuus',
      'size': 'Koko',
      'strength': 'Vahvuus',
      'tolerance': 'Toleranssi',
      'softness': 'Pehmeys',
      'lighting': 'Valaistus',
      'warmth': 'Lämpö',
      'power': 'Teho',
      'blend_mode': 'Sekoitustila',
      'factor': 'Kerroin',
      'zoom': 'Zoomaus',
      'invert_colors': 'Käännä värit',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normaali',
      'multiply': 'Kertominen',
      'additive': 'Lisäys',
      'colorBurn': 'Värin poltto',
      'colorDodge': 'Värin varjostus',
      'reflect': 'Heijastus',
      'glow': 'Hehku',
      'overlay': 'Sulautus',
      'difference': 'Erotus',
      'negation': 'Negaatio',
      'lighten': 'Vaalennus',
      'darken': 'Tummennus',
      'screen': 'Rasteri',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Kuvalle ei ole riittävästi muistia.',
      'invalid_size': 'Kuvan koko ei kelpaa.',
      'layer_index': 'Tasoa ei ole olemassa.',
      'last_layer': 'Viimeistä tasoa ei voi poistaa.',
      'no_layer_below': 'Alapuolella ei ole tasoa, johon yhdistää.',
      'edit_in_progress': 'Viimeistele ensin keskeneräinen toiminto.',
      'no_edit': 'Keskeneräistä toimintoa ei ole.',
      'no_selection': 'Mitään ei ole valittu.',
      'nothing_lifted': 'Pikseleitä ei ole irrotettu.',
      'invalid_parameter': 'Arvo on sallitun alueen ulkopuolella.',
      'io': 'Tiedostoa ei voitu lukea tai kirjoittaa.',
      'decode': 'Kuvaa ei voitu lukea.',
      'encode': 'Kuvaa ei voitu kirjoittaa.',
      'open_raster': 'OpenRaster-tiedosto on vioittunut.',
      'palette': 'Palettitiedosto on vioittunut.',
      'cancelled': 'Laskenta peruttiin.',
      'other': 'Jokin meni vikaan.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Tiedostoa ei voitu lukea tai kirjoittaa.';

  @override
  String get failureInvalidData => 'Tietoja ei voitu lukea.';

  @override
  String get failureUnknown => 'Tapahtui odottamaton virhe.';

  @override
  String get panelTools => 'Työkalut';

  @override
  String get panelHistory => 'Historia';

  @override
  String get panelLayers => 'Tasot';

  @override
  String get panelColors => 'Värit';

  @override
  String get panelHide => 'Piilota';

  @override
  String get colorsPrimary => 'Ensisijainen';

  @override
  String get colorsSecondary => 'Toissijainen';

  @override
  String get colorsPrimaryHint =>
      'Ensisijainen väri: hiiren vasen painike maalaa sillä';

  @override
  String get colorsSecondaryHint =>
      'Toissijainen väri: hiiren oikea painike maalaa sillä';

  @override
  String get colorsSwap => 'Vaihda värit keskenään (X)';

  @override
  String get colorsReset => 'Palauta mustaksi ja valkoiseksi';

  @override
  String get colorsMore => 'Enemmän';

  @override
  String get colorsLess => 'Vähemmän';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Alfa';

  @override
  String get colorsHue => 'H';

  @override
  String get colorsSat => 'S';

  @override
  String get colorsValue => 'V';

  @override
  String get colorsRed => 'R';

  @override
  String get colorsGreen => 'G';

  @override
  String get colorsBlue => 'B';

  @override
  String get colorsPaletteHint =>
      'Vasen napsautus asettaa ensisijaisen värin, oikea toissijaisen';

  @override
  String get settingWidth => 'Leveys';

  @override
  String get settingHardness => 'Kovuus';

  @override
  String get settingAntialias => 'Reunanpehmennys';

  @override
  String get settingAlphaBlending => 'Alfasekoitus';

  @override
  String get settingTolerance => 'Toleranssi';

  @override
  String get settingFloodMode => 'Täyttötila';

  @override
  String get floodLocal => 'Yhtenäinen alue';

  @override
  String get floodGlobal => 'Koko kuva';

  @override
  String get settingSelectionMode => 'Valintatila';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Korvaa',
      'union': 'Lisää',
      'exclude': 'Vähennä',
      'xor': 'Xor',
      'intersect': 'Leikkaus',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Valinnan koko';

  @override
  String get drawNormal => 'Normaali';

  @override
  String get drawFixedRatio => 'Kiinteä kuvasuhde';

  @override
  String get drawFixedSize => 'Kiinteä koko';

  @override
  String get settingResampling => 'Uudelleennäytteistys';

  @override
  String get resamplingNearest => 'Lähin naapuri';

  @override
  String get resamplingBilinear => 'Bilineaarinen';

  @override
  String get settingGradient => 'Tyyppi';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineaarinen',
      'linearReflected': 'Lineaarinen peilattu',
      'diamond': 'Timantti',
      'radial': 'Säteittäinen',
      'conical': 'Kartiomainen',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Väri';

  @override
  String get gradientTransparency => 'Läpinäkyvyys';

  @override
  String get settingShape => 'Muodon tyyli';

  @override
  String get shapeOutline => 'Ääriviiva';

  @override
  String get shapeInterior => 'Täyttö';

  @override
  String get shapeBoth => 'Ääriviiva ja täyttö';

  @override
  String get settingAfterPick => 'Värin poimimisen jälkeen';

  @override
  String get pickStay => 'Pidä tämä työkalu';

  @override
  String get pickPrevious => 'Vaihda edelliseen työkaluun';

  @override
  String get pickPencil => 'Vaihda Lyijykynään';

  @override
  String get settingNone => 'Tällä työkalulla ei ole asetuksia.';

  @override
  String toolUnavailable(String name) {
    return 'Työkalu ”$name” ei ole vielä käytettävissä';
  }

  @override
  String get historyFirst => 'Siirry ensimmäiseen vaiheeseen';

  @override
  String get historyUndo => 'Kumoa';

  @override
  String get historyRedo => 'Tee uudelleen';

  @override
  String get historyLast => 'Siirry viimeiseen vaiheeseen';

  @override
  String get historyNewImage => 'Uusi kuva';

  @override
  String get historyOpenImage => 'Avaa kuva';

  @override
  String get layerVisible => 'Näytä tai piilota taso';

  @override
  String get layerBackground => 'Tausta';

  @override
  String get layerName => 'Nimi';

  @override
  String get layerOpacity => 'Peittävyys';

  @override
  String get layerBlendMode => 'Sekoitustila';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Peruuta';

  @override
  String get save => 'Tallenna';

  @override
  String get dontSave => 'Älä tallenna';

  @override
  String get keepCanvas => 'Säilytä kangas';

  @override
  String get expandCanvas => 'Laajenna kangasta';

  @override
  String get width => 'Leveys';

  @override
  String get height => 'Korkeus';

  @override
  String get pixels => 'pikseliä';

  @override
  String get newImageTitle => 'Uusi kuva';

  @override
  String get resizeTitle => 'Muuta kuvan kokoa';

  @override
  String get canvasSizeTitle => 'Kankaan koko';

  @override
  String get keepRatio => 'Säilytä kuvasuhde';

  @override
  String get anchor => 'Ankkuri';

  @override
  String sizeTooLarge(int max) {
    return 'Kuva on liian suuri: enimmäiskoko on $max megapikseliä.';
  }

  @override
  String get unsavedTitle => 'Tallennetaanko muutokset?';

  @override
  String unsavedMessage(String name) {
    return 'Kohteessa ”$name” on tallentamattomia muutoksia.';
  }

  @override
  String get flattenTitle => 'Yhdistetäänkö tasot?';

  @override
  String flattenMessage(String format) {
    return 'Muoto $format ei säilytä tasoja, joten kuvan tasot yhdistetään yhdeksi tasoksi. Voit kumota tämän Historia-ikkunassa.';
  }

  @override
  String get flatten => 'Yhdistä';

  @override
  String get jpegQualityTitle => 'JPEG-laatu';

  @override
  String get quality => 'Laatu';

  @override
  String get largerTitle => 'Kuva on suurempi kuin kangas';

  @override
  String get largerMessage =>
      'Laajennetaanko kangasta, jotta kuva mahtuu siihen?';

  @override
  String get reseed => 'Uusi siemen';

  @override
  String get rendering => 'Lasketaan…';

  @override
  String statusPointer(int x, int y) {
    return '$x, $y';
  }

  @override
  String statusSelection(int width, int height) {
    return '$width × $height';
  }

  @override
  String statusZoom(String percent) {
    return '$percent %';
  }

  @override
  String statusOpening(String name) {
    return 'Avataan $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Tallennetaan $name…';
  }

  @override
  String savedTo(String name) {
    return 'Tallennettu: $name';
  }

  @override
  String get dropHere => 'Avaa pudottamalla';

  @override
  String get dropHint => 'Jokainen tiedosto avataan uutena kuvana';

  @override
  String get imagesList => 'Avoimet kuvat';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Rasterikuvaeditori, jossa on tasot. Valitse työkalu painamalla kirjainta; painamalla S, M tai O uudelleen vaihdat toisiinsa liittyvien työkalujen välillä. [ ja ] muuttavat siveltimen leveyttä, X vaihtaa värit keskenään, välilyönnin pitäminen painettuna panoroi näkymää, Ctrl+hiiren rulla zoomaa ja F5–F8 näyttävät tai piilottavat ikkunat.';

  @override
  String get settingLineStart => 'Alku';

  @override
  String get settingLineEnd => 'Loppu';

  @override
  String get settingDash => 'Katkoviiva';

  @override
  String get settingSwapSize => 'Vaihda leveys ja korkeus keskenään';

  @override
  String get settingLineStyle => 'Tyyli';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Tasainen',
      'arrow': 'Nuoli',
      'arrowFilled': 'Täytetty nuoli',
      'rounded': 'Pyöristetty',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Yhtenäinen',
      'dash': 'Viiva',
      'dashDot': 'Viiva-piste',
      'dashDotDot': 'Viiva-piste-piste',
      'dot': 'Piste',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Fontti';

  @override
  String get settingFontSize => 'Koko';

  @override
  String get textBold => 'Lihavoitu';

  @override
  String get textItalic => 'Kursivoitu';

  @override
  String get textUnderline => 'Alleviivattu';

  @override
  String get textStrikeout => 'Yliviivattu';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Vasen',
      'center': 'Keskitetty',
      'right': 'Oikea',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Kuvat';
}
