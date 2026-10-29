// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Bez názvu $number';
  }

  @override
  String get menuFile => 'Súbor';

  @override
  String get menuEdit => 'Upraviť';

  @override
  String get menuView => 'Zobraziť';

  @override
  String get menuImage => 'Obrázok';

  @override
  String get menuLayers => 'Vrstvy';

  @override
  String get menuAdjustments => 'Korekcie';

  @override
  String get menuEffects => 'Efekty';

  @override
  String get menuOpenRecent => 'Nedávno otvorené';

  @override
  String get menuRecentEmpty => 'Žiadne nedávne súbory';

  @override
  String get menuTheme => 'Motív';

  @override
  String get menuSettings => 'Nastavenia';

  @override
  String get menuAccent => 'Farba zvýraznenia';

  @override
  String get menuLanguage => 'Jazyk';

  @override
  String get languageSystem => 'Podľa systému';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Modrá',
      'green': 'Zelená',
      'amber': 'Jantárová',
      'purple': 'Fialová',
      'red': 'Červená',
      'gray': 'Sivá',
      'custom': 'Vlastná…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Vlastná farba zvýraznenia';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Podľa systému';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeLight => 'Svetlý';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nový…',
      'open': 'Otvoriť…',
      'close': 'Zavrieť',
      'save': 'Uložiť',
      'save_as': 'Uložiť ako…',
      'exit': 'Ukončiť',
      'undo': 'Späť',
      'redo': 'Znova',
      'cut': 'Vystrihnúť',
      'copy': 'Kopírovať',
      'paste': 'Prilepiť',
      'paste_into_new_layer': 'Prilepiť do novej vrstvy',
      'paste_into_new_image': 'Prilepiť do nového obrázka',
      'erase_selection': 'Vymazať výber',
      'fill_selection': 'Vyplniť výber',
      'invert_selection': 'Invertovať výber',
      'select_all': 'Vybrať všetko',
      'deselect': 'Zrušiť výber',
      'zoom_in': 'Priblížiť',
      'zoom_out': 'Oddialiť',
      'zoom_to_window': 'Prispôsobiť oknu',
      'zoom_to_selection': 'Prispôsobiť výberu',
      'actual_size': 'Skutočná veľkosť',
      'pixel_grid': 'Mriežka pixelov',
      'rulers': 'Pravítka',
      'crop_to_selection': 'Orezať podľa výberu',
      'resize': 'Zmeniť veľkosť obrázka…',
      'canvas_size': 'Zmeniť veľkosť plátna…',
      'flip_horizontal': 'Preklopiť vodorovne',
      'flip_vertical': 'Preklopiť zvislo',
      'rotate90_cw': 'Otočiť o 90° v smere hodinových ručičiek',
      'rotate90_ccw': 'Otočiť o 90° proti smeru hodinových ručičiek',
      'rotate180': 'Otočiť o 180°',
      'flatten': 'Zlúčiť do jednej vrstvy',
      'add_layer': 'Pridať novú vrstvu',
      'delete_layer': 'Odstrániť vrstvu',
      'duplicate_layer': 'Duplikovať vrstvu',
      'merge_layer_down': 'Zlúčiť nadol',
      'import_from_file': 'Importovať zo súboru…',
      'flip_layer_horizontal': 'Preklopiť vrstvu vodorovne',
      'flip_layer_vertical': 'Preklopiť vrstvu zvislo',
      'move_layer_up': 'Posunúť vrstvu vyššie',
      'move_layer_down': 'Posunúť vrstvu nižšie',
      'layer_properties': 'Vlastnosti vrstvy…',
      'adjust_auto_level': 'Automatické úrovne',
      'adjust_black_and_white': 'Čiernobiele',
      'adjust_brightness_contrast': 'Jas / kontrast…',
      'adjust_curves': 'Krivky…',
      'adjust_hue_saturation': 'Odtieň / sýtosť…',
      'adjust_invert_colors': 'Invertovať farby',
      'adjust_levels': 'Úrovne…',
      'adjust_posterize': 'Posterizácia…',
      'adjust_sepia': 'Sépia',
      'repeat_effect': 'Opakovať efekt',
      'effect_oil_painting': 'Olejomaľba…',
      'effect_gaussian_blur': 'Gaussovo rozostrenie…',
      'effect_motion_blur': 'Rozostrenie pohybom…',
      'effect_pixelate': 'Pixelizácia…',
      'effect_add_noise': 'Pridať šum…',
      'effect_median': 'Medián…',
      'effect_sharpen': 'Doostrenie…',
      'effect_edge_detect': 'Detekcia hrán…',
      'effect_emboss': 'Vytlačenie…',
      'effect_outline': 'Obrys…',
      'toggle_tools': 'Nástroje',
      'toggle_history': 'História',
      'toggle_layers': 'Vrstvy',
      'toggle_colors': 'Farby',
      'next_image': 'Ďalší obrázok',
      'previous_image': 'Predchádzajúci obrázok',
      'help': 'Pomocník',
      'effect_ink_sketch': 'Kresba atramentom…',
      'effect_pencil_sketch': 'Kresba ceruzkou…',
      'effect_fragment': 'Fragmentácia…',
      'effect_radial_blur': 'Radiálne rozostrenie…',
      'effect_surface_blur': 'Plošné rozostrenie…',
      'effect_unfocus': 'Neostrosť…',
      'effect_zoom_blur': 'Rozostrenie priblížením…',
      'effect_bulge': 'Vydutie…',
      'effect_dents': 'Preliačiny…',
      'effect_frosted_glass': 'Matné sklo…',
      'effect_polar_inversion': 'Polárna inverzia…',
      'effect_tile_reflection': 'Dlaždicový odraz…',
      'effect_twist': 'Skrútenie…',
      'effect_reduce_noise': 'Redukcia šumu…',
      'effect_glow': 'Žiara…',
      'effect_red_eye_removal': 'Odstránenie červených očí…',
      'effect_soften_portrait': 'Zjemnenie portrétu…',
      'effect_clouds': 'Oblaky…',
      'effect_julia_fractal': 'Juliov fraktál…',
      'effect_mandelbrot_fractal': 'Mandelbrotov fraktál…',
      'effect_relief': 'Reliéf…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Umelecké',
      'blurs': 'Rozostrenie',
      'distort': 'Deformácia',
      'noise': 'Šum',
      'photo': 'Fotografia',
      'stylize': 'Štylizácia',
      'render': 'Vykreslenie',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Obdĺžnikový výber',
      'move_selected_pixels': 'Presun vybraných pixelov',
      'lasso_select': 'Laso',
      'move_selection': 'Presun výberu',
      'ellipse_select': 'Eliptický výber',
      'zoom': 'Lupa',
      'magic_wand': 'Čarovná palička',
      'pan': 'Ruka',
      'paint_bucket': 'Vedro s farbou',
      'gradient': 'Prechod',
      'paintbrush': 'Štetec',
      'eraser': 'Guma',
      'pencil': 'Ceruzka',
      'color_picker': 'Kvapkadlo',
      'clone_stamp': 'Klonovacia pečiatka',
      'recolor': 'Prefarbenie',
      'text': 'Text',
      'line_curve': 'Čiara / krivka',
      'rectangle': 'Obdĺžnik',
      'rounded_rectangle': 'Zaoblený obdĺžnik',
      'ellipse': 'Elipsa',
      'freeform_shape': 'Voľný tvar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Ťahaním vyberte obdĺžnik. Podržaním klávesu Shift vyberiete štvorec.',
      'move_selected_pixels': 'Ťahaním výber presuniete. Ťahaním pravým tlačidlom ho otočíte, ťahaním úchytov zmeníte jeho veľkosť. Ctrl ponechá kópiu, šípky ho posúvajú po malých krokoch.',
      'lasso_select': 'Ťahaním nakreslite obrys výberu.',
      'move_selection':
          'Ťahaním presuniete obrys výberu. Pixely zostanú na mieste.',
      'ellipse_select':
          'Ťahaním vyberte elipsu. Podržaním klávesu Shift vyberiete kruh.',
      'zoom': 'Kliknutím ľavým tlačidlom priblížite, pravým oddialite. Ťahaním rámčeka priblížite ohraničenú oblasť.',
      'magic_wand': 'Kliknutím na farbu vyberiete oblasť okolo nej. Podržaním klávesu Shift vyberiete túto farbu v celom obrázku.',
      'pan': 'Ťahaním posuniete zobrazenie.',
      'paint_bucket': 'Kliknutie ľavým tlačidlom vyplní primárnou farbou, pravým sekundárnou.',
      'gradient': 'Ťahaním nakreslite prechod. Ťahaním úchytov ho upravíte, klávesom Enter dokončíte.',
      'paintbrush': 'Ľavé tlačidlo maľuje primárnou farbou, pravé sekundárnou.',
      'eraser': 'Ťahaním vymazávate do priehľadnosti.',
      'pencil': 'Kreslí jednopixelové čiary bez vyhladzovania.',
      'color_picker': 'Kliknutie ľavým tlačidlom vyberie primárnu farbu, pravým sekundárnu.',
      'clone_stamp': 'Kliknutím so stlačeným klávesom Ctrl nastavte zdroj a potom z neho ťahaním maľujte.',
      'recolor': 'Tam, kde maľujete, nahrádza sekundárnu farbu primárnou. Kliknutie so stlačeným klávesom Ctrl vyberie farbu.',
      'text': 'Kliknutím umiestnite kurzor a píšte. Ťahaním úchytu alebo ťahaním pravým tlačidlom text presuniete, klávesom Esc dokončíte.',
      'line_curve': 'Ťahaním nakreslite čiaru. Ťahaním úchytov ju ohnete, klávesom Enter dokončíte.',
      'rectangle': 'Ťahaním nakreslite obdĺžnik. Podržaním klávesu Shift nakreslíte štvorec.',
      'rounded_rectangle': 'Ťahaním nakreslite zaoblený obdĺžnik. Podržaním klávesu Shift nakreslíte štvorec.',
      'ellipse':
          'Ťahaním nakreslite elipsu. Podržaním klávesu Shift nakreslíte kruh.',
      'freeform_shape': 'Ťahaním nakreslite uzavretý voľný tvar.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Polomer',
      'angle': 'Uhol',
      'distance': 'Vzdialenosť',
      'centered': 'Od stredu',
      'amount': 'Množstvo',
      'intensity': 'Intenzita',
      'saturation': 'Sýtosť',
      'coverage': 'Pokrytie',
      'seed': 'Semienko',
      'percentile': 'Percentil',
      'cell_size': 'Veľkosť bunky',
      'brush_size': 'Veľkosť štetca',
      'coarseness': 'Hrubosť',
      'thickness': 'Hrúbka',
      'brightness': 'Jas',
      'contrast': 'Kontrast',
      'hue': 'Odtieň',
      'lightness': 'Svetlosť',
      'red': 'Červená',
      'green': 'Zelená',
      'blue': 'Modrá',
      'input_low': 'Vstup: minimum',
      'input_high': 'Vstup: maximum',
      'output_low': 'Výstup: minimum',
      'output_high': 'Výstup: maximum',
      'gamma': 'Gama',
      'ink_outline': 'Obrys atramentom',
      'coloring': 'Zafarbenie',
      'tip_size': 'Veľkosť hrotu ceruzky',
      'color_range': 'Rozsah farieb',
      'fragments': 'Fragmenty',
      'rotation': 'Otočenie',
      'offset_x': 'Posun X',
      'offset_y': 'Posun Y',
      'quality': 'Kvalita',
      'threshold': 'Prah',
      'scale': 'Mierka',
      'refraction': 'Lom',
      'roughness': 'Drsnosť',
      'tension': 'Napätie',
      'max_scatter': 'Maximálny rozptyl',
      'min_scatter': 'Minimálny rozptyl',
      'samples': 'Vzorky',
      'edge_behavior': 'Správanie na okrajoch',
      'tile_size': 'Veľkosť dlaždice',
      'curvature': 'Zakrivenie',
      'size': 'Veľkosť',
      'strength': 'Sila',
      'tolerance': 'Tolerancia',
      'softness': 'Mäkkosť',
      'lighting': 'Osvetlenie',
      'warmth': 'Teplota',
      'power': 'Mocnina',
      'blend_mode': 'Režim miešania',
      'factor': 'Faktor',
      'zoom': 'Priblíženie',
      'invert_colors': 'Invertovať farby',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normálny',
      'multiply': 'Násobenie',
      'additive': 'Sčítanie',
      'colorBurn': 'Stmavenie farieb',
      'colorDodge': 'Zosvetlenie farieb',
      'reflect': 'Odraz',
      'glow': 'Žiara',
      'overlay': 'Prekrytie',
      'difference': 'Rozdiel',
      'negation': 'Negácia',
      'lighten': 'Zosvetlenie',
      'darken': 'Stmavenie',
      'screen': 'Závoj',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Na obrázok nie je dostatok pamäte.',
      'invalid_size': 'Veľkosť obrázka je neplatná.',
      'layer_index': 'Taká vrstva neexistuje.',
      'last_layer': 'Poslednú vrstvu nemožno odstrániť.',
      'no_layer_below': 'Pod touto vrstvou nie je žiadna vrstva, s ktorou by ju bolo možné zlúčiť.',
      'edit_in_progress': 'Najprv dokončite rozpracovanú úpravu.',
      'no_edit': 'Žiadna úprava nie je rozpracovaná.',
      'no_selection': 'Nič nie je vybraté.',
      'nothing_lifted': 'Žiadne pixely nie sú zdvihnuté.',
      'invalid_parameter': 'Hodnota je mimo povoleného rozsahu.',
      'io': 'Súbor nemožno prečítať ani zapísať.',
      'decode': 'Obrázok nemožno prečítať.',
      'encode': 'Obrázok nemožno zapísať.',
      'open_raster': 'Súbor OpenRaster je poškodený.',
      'palette': 'Súbor palety je poškodený.',
      'cancelled': 'Výpočet bol zrušený.',
      'other': 'Vyskytla sa chyba.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Súbor nemožno prečítať ani zapísať.';

  @override
  String get failureInvalidData => 'Údaje nemožno prečítať.';

  @override
  String get failureUnknown => 'Vyskytla sa neočakávaná chyba.';

  @override
  String get panelTools => 'Nástroje';

  @override
  String get panelHistory => 'História';

  @override
  String get panelLayers => 'Vrstvy';

  @override
  String get panelColors => 'Farby';

  @override
  String get panelHide => 'Skryť';

  @override
  String get colorsPrimary => 'Primárna';

  @override
  String get colorsSecondary => 'Sekundárna';

  @override
  String get colorsPrimaryHint =>
      'Primárna farba: maľuje ňou ľavé tlačidlo myši';

  @override
  String get colorsSecondaryHint =>
      'Sekundárna farba: maľuje ňou pravé tlačidlo myši';

  @override
  String get colorsSwap => 'Vymeniť farby (X)';

  @override
  String get colorsReset => 'Obnoviť čiernu a bielu';

  @override
  String get colorsMore => 'Viac';

  @override
  String get colorsLess => 'Menej';

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
      'Kliknutie ľavým tlačidlom nastaví primárnu farbu, pravým sekundárnu';

  @override
  String get settingWidth => 'Šírka';

  @override
  String get settingHardness => 'Tvrdosť';

  @override
  String get settingAntialias => 'Vyhladzovanie';

  @override
  String get settingAlphaBlending => 'Miešanie alfa';

  @override
  String get settingTolerance => 'Tolerancia';

  @override
  String get settingFloodMode => 'Režim vypĺňania';

  @override
  String get floodLocal => 'Súvislý';

  @override
  String get floodGlobal => 'Globálny';

  @override
  String get settingSelectionMode => 'Režim výberu';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Nahradiť',
      'union': 'Pridať',
      'exclude': 'Odobrať',
      'xor': 'XOR',
      'intersect': 'Pretnúť',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Veľkosť výberu';

  @override
  String get drawNormal => 'Ľubovoľná';

  @override
  String get drawFixedRatio => 'Pevný pomer strán';

  @override
  String get drawFixedSize => 'Pevná veľkosť';

  @override
  String get settingResampling => 'Prevzorkovanie';

  @override
  String get resamplingNearest => 'Najbližší sused';

  @override
  String get resamplingBilinear => 'Bilineárne';

  @override
  String get settingGradient => 'Typ';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineárny',
      'linearReflected': 'Lineárny zrkadlový',
      'diamond': 'Kosoštvorcový',
      'radial': 'Radiálny',
      'conical': 'Kužeľový',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Farba';

  @override
  String get gradientTransparency => 'Priehľadnosť';

  @override
  String get settingShape => 'Štýl tvaru';

  @override
  String get shapeOutline => 'Obrys';

  @override
  String get shapeInterior => 'Výplň';

  @override
  String get shapeBoth => 'Obrys a výplň';

  @override
  String get settingAfterPick => 'Po výbere farby';

  @override
  String get pickStay => 'Ponechať tento nástroj';

  @override
  String get pickPrevious => 'Prepnúť na predchádzajúci nástroj';

  @override
  String get pickPencil => 'Prepnúť na Ceruzku';

  @override
  String get settingNone => 'Tento nástroj nemá žiadne nastavenia.';

  @override
  String toolUnavailable(String name) {
    return 'Nástroj „$name“ zatiaľ nie je k dispozícii';
  }

  @override
  String get historyFirst => 'Prejsť na prvý krok';

  @override
  String get historyUndo => 'Späť';

  @override
  String get historyRedo => 'Znova';

  @override
  String get historyLast => 'Prejsť na posledný krok';

  @override
  String get historyNewImage => 'Nový obrázok';

  @override
  String get historyOpenImage => 'Otvorenie obrázka';

  @override
  String get layerVisible => 'Zobraziť alebo skryť vrstvu';

  @override
  String get layerBackground => 'Pozadie';

  @override
  String get layerName => 'Názov';

  @override
  String get layerOpacity => 'Krytie';

  @override
  String get layerBlendMode => 'Režim miešania';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get save => 'Uložiť';

  @override
  String get dontSave => 'Neukladať';

  @override
  String get keepCanvas => 'Zachovať plátno';

  @override
  String get expandCanvas => 'Zväčšiť plátno';

  @override
  String get width => 'Šírka';

  @override
  String get height => 'Výška';

  @override
  String get pixels => 'pixelov';

  @override
  String get newImageTitle => 'Nový obrázok';

  @override
  String get resizeTitle => 'Zmeniť veľkosť obrázka';

  @override
  String get canvasSizeTitle => 'Veľkosť plátna';

  @override
  String get keepRatio => 'Zachovať pomer strán';

  @override
  String get anchor => 'Ukotvenie';

  @override
  String sizeTooLarge(int max) {
    return 'Obrázok je príliš veľký: limit je $max megapixelov.';
  }

  @override
  String get unsavedTitle => 'Uložiť zmeny?';

  @override
  String unsavedMessage(String name) {
    return '„$name“ obsahuje neuložené zmeny.';
  }

  @override
  String get flattenTitle => 'Zlúčiť obrázok do jednej vrstvy?';

  @override
  String flattenMessage(String format) {
    return 'Formát $format nepodporuje vrstvy, preto bude obrázok zlúčený do jednej vrstvy. Túto akciu môžete vrátiť späť v okne História.';
  }

  @override
  String get flatten => 'Zlúčiť';

  @override
  String get jpegQualityTitle => 'Kvalita JPEG';

  @override
  String get quality => 'Kvalita';

  @override
  String get largerTitle => 'Obrázok je väčší ako plátno';

  @override
  String get largerMessage => 'Zväčšiť plátno, aby sa doň obrázok zmestil?';

  @override
  String get reseed => 'Nové semienko';

  @override
  String get rendering => 'Vykresľovanie…';

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
    return 'Otvára sa $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Ukladá sa $name…';
  }

  @override
  String savedTo(String name) {
    return 'Uložené: $name';
  }

  @override
  String get dropHere => 'Pustite na otvorenie';

  @override
  String get dropHint => 'Každý súbor sa otvorí ako nový obrázok';

  @override
  String get imagesList => 'Otvorené obrázky';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Editor rastrových obrázkov s vrstvami. Nástroj vyberiete stlačením písmena; opakované stlačenie S, M alebo O prepína medzi príbuznými nástrojmi. [ a ] menia šírku štetca, X vymení farby, podržanie medzerníka posúva zobrazenie, Ctrl+koliesko myši mení priblíženie a F5–F8 zobrazujú alebo skrývajú okná.';

  @override
  String get settingLineStart => 'Začiatok';

  @override
  String get settingLineEnd => 'Koniec';

  @override
  String get settingDash => 'Prerušovanie';

  @override
  String get settingSwapSize => 'Vymeniť šírku a výšku';

  @override
  String get settingLineStyle => 'Štýl';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plochý',
      'arrow': 'Šípka',
      'arrowFilled': 'Plná šípka',
      'rounded': 'Zaoblený',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Plná',
      'dash': 'Čiarkovaná',
      'dashDot': 'Čiarka a bodka',
      'dashDotDot': 'Čiarka a dve bodky',
      'dot': 'Bodkovaná',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Písmo';

  @override
  String get settingFontSize => 'Veľkosť';

  @override
  String get textBold => 'Tučné';

  @override
  String get textItalic => 'Kurzíva';

  @override
  String get textUnderline => 'Podčiarknuté';

  @override
  String get textStrikeout => 'Prečiarknuté';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Vľavo',
      'center': 'Na stred',
      'right': 'Vpravo',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Obrázky';
}
