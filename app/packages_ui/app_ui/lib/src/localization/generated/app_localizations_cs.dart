// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Bez názvu $number';
  }

  @override
  String get menuFile => 'Soubor';

  @override
  String get menuEdit => 'Úpravy';

  @override
  String get menuView => 'Zobrazení';

  @override
  String get menuImage => 'Obrázek';

  @override
  String get menuLayers => 'Vrstvy';

  @override
  String get menuAdjustments => 'Korekce';

  @override
  String get menuEffects => 'Efekty';

  @override
  String get menuOpenRecent => 'Nedávno otevřené';

  @override
  String get menuRecentEmpty => 'Žádné nedávné soubory';

  @override
  String get menuTheme => 'Motiv';

  @override
  String get menuSettings => 'Nastavení';

  @override
  String get menuAccent => 'Barva zvýraznění';

  @override
  String get menuLanguage => 'Jazyk';

  @override
  String get languageSystem => 'Podle systému';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Modrá',
      'green': 'Zelená',
      'amber': 'Jantarová',
      'purple': 'Fialová',
      'red': 'Červená',
      'gray': 'Šedá',
      'custom': 'Vlastní…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Vlastní barva zvýraznění';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Podle systému';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeLight => 'Světlý';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nový…',
      'open': 'Otevřít…',
      'close': 'Zavřít',
      'save': 'Uložit',
      'save_as': 'Uložit jako…',
      'exit': 'Ukončit',
      'undo': 'Zpět',
      'redo': 'Znovu',
      'cut': 'Vyjmout',
      'copy': 'Kopírovat',
      'paste': 'Vložit',
      'paste_into_new_layer': 'Vložit do nové vrstvy',
      'paste_into_new_image': 'Vložit do nového obrázku',
      'erase_selection': 'Vymazat výběr',
      'fill_selection': 'Vyplnit výběr',
      'invert_selection': 'Invertovat výběr',
      'select_all': 'Vybrat vše',
      'deselect': 'Zrušit výběr',
      'zoom_in': 'Přiblížit',
      'zoom_out': 'Oddálit',
      'zoom_to_window': 'Přizpůsobit oknu',
      'zoom_to_selection': 'Přizpůsobit výběru',
      'actual_size': 'Skutečná velikost',
      'pixel_grid': 'Pixelová mřížka',
      'rulers': 'Pravítka',
      'crop_to_selection': 'Oříznout podle výběru',
      'resize': 'Změnit velikost obrázku…',
      'canvas_size': 'Změnit velikost plátna…',
      'flip_horizontal': 'Překlopit vodorovně',
      'flip_vertical': 'Překlopit svisle',
      'rotate90_cw': 'Otočit o 90° po směru hodinových ručiček',
      'rotate90_ccw': 'Otočit o 90° proti směru hodinových ručiček',
      'rotate180': 'Otočit o 180°',
      'flatten': 'Sloučit do jedné vrstvy',
      'add_layer': 'Přidat novou vrstvu',
      'delete_layer': 'Odstranit vrstvu',
      'duplicate_layer': 'Duplikovat vrstvu',
      'merge_layer_down': 'Sloučit dolů',
      'import_from_file': 'Importovat ze souboru…',
      'flip_layer_horizontal': 'Překlopit vrstvu vodorovně',
      'flip_layer_vertical': 'Překlopit vrstvu svisle',
      'move_layer_up': 'Posunout vrstvu nahoru',
      'move_layer_down': 'Posunout vrstvu dolů',
      'layer_properties': 'Vlastnosti vrstvy…',
      'adjust_auto_level': 'Automatické úrovně',
      'adjust_black_and_white': 'Černobílé',
      'adjust_brightness_contrast': 'Jas / kontrast…',
      'adjust_curves': 'Křivky…',
      'adjust_hue_saturation': 'Odstín / sytost…',
      'adjust_invert_colors': 'Invertovat barvy',
      'adjust_levels': 'Úrovně…',
      'adjust_posterize': 'Posterizace…',
      'adjust_sepia': 'Sépie',
      'repeat_effect': 'Opakovat efekt',
      'effect_oil_painting': 'Olejomalba…',
      'effect_gaussian_blur': 'Gaussovské rozostření…',
      'effect_motion_blur': 'Rozostření pohybem…',
      'effect_pixelate': 'Pixelizace…',
      'effect_add_noise': 'Přidat šum…',
      'effect_median': 'Medián…',
      'effect_sharpen': 'Doostření…',
      'effect_edge_detect': 'Detekce hran…',
      'effect_emboss': 'Vytlačení…',
      'effect_outline': 'Obrys…',
      'toggle_tools': 'Nástroje',
      'toggle_history': 'Historie',
      'toggle_layers': 'Vrstvy',
      'toggle_colors': 'Barvy',
      'next_image': 'Další obrázek',
      'previous_image': 'Předchozí obrázek',
      'help': 'Nápověda',
      'effect_ink_sketch': 'Kresba inkoustem…',
      'effect_pencil_sketch': 'Kresba tužkou…',
      'effect_fragment': 'Fragmentace…',
      'effect_radial_blur': 'Radiální rozostření…',
      'effect_surface_blur': 'Plošné rozostření…',
      'effect_unfocus': 'Neostrost…',
      'effect_zoom_blur': 'Rozostření přiblížením…',
      'effect_bulge': 'Vyboulení…',
      'effect_dents': 'Promáčknutí…',
      'effect_frosted_glass': 'Matné sklo…',
      'effect_polar_inversion': 'Polární inverze…',
      'effect_tile_reflection': 'Dlaždicový odraz…',
      'effect_twist': 'Zkroucení…',
      'effect_reduce_noise': 'Redukce šumu…',
      'effect_glow': 'Záře…',
      'effect_red_eye_removal': 'Odstranění červených očí…',
      'effect_soften_portrait': 'Změkčení portrétu…',
      'effect_clouds': 'Mraky…',
      'effect_julia_fractal': 'Juliův fraktál…',
      'effect_mandelbrot_fractal': 'Mandelbrotův fraktál…',
      'effect_relief': 'Reliéf…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Umělecké',
      'blurs': 'Rozostření',
      'distort': 'Deformace',
      'noise': 'Šum',
      'photo': 'Fotografie',
      'stylize': 'Stylizace',
      'render': 'Vykreslení',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Obdélníkový výběr',
      'move_selected_pixels': 'Přesun vybraných pixelů',
      'lasso_select': 'Laso',
      'move_selection': 'Přesun výběru',
      'ellipse_select': 'Eliptický výběr',
      'zoom': 'Lupa',
      'magic_wand': 'Kouzelná hůlka',
      'pan': 'Ruka',
      'paint_bucket': 'Plechovka barvy',
      'gradient': 'Přechod',
      'paintbrush': 'Štětec',
      'eraser': 'Guma',
      'pencil': 'Tužka',
      'color_picker': 'Kapátko',
      'clone_stamp': 'Klonovací razítko',
      'recolor': 'Přebarvení',
      'text': 'Text',
      'line_curve': 'Čára / křivka',
      'rectangle': 'Obdélník',
      'rounded_rectangle': 'Zaoblený obdélník',
      'ellipse': 'Elipsa',
      'freeform_shape': 'Volný tvar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select':
          'Tažením vyberte obdélník. Podržením klávesy Shift vyberete čtverec.',
      'move_selected_pixels': 'Tažením výběr přesunete. Tažením pravým tlačítkem jej otočíte, tažením úchytů změníte jeho velikost. Ctrl ponechá kopii, šipky jím posouvají po malých krocích.',
      'lasso_select': 'Tažením nakreslete obrys výběru.',
      'move_selection':
          'Tažením přesunete obrys výběru. Pixely zůstanou na místě.',
      'ellipse_select':
          'Tažením vyberte elipsu. Podržením klávesy Shift vyberete kruh.',
      'zoom': 'Kliknutím levým tlačítkem přiblížíte, pravým oddálíte. Tažením rámečku přiblížíte ohraničenou oblast.',
      'magic_wand': 'Kliknutím na barvu vyberete oblast kolem ní. Podržením klávesy Shift vyberete tuto barvu v celém obrázku.',
      'pan': 'Tažením posunete zobrazení.',
      'paint_bucket':
          'Kliknutí levým tlačítkem vyplní primární barvou, pravým sekundární.',
      'gradient': 'Tažením nakreslete přechod. Tažením úchytů jej upravíte, klávesou Enter dokončíte.',
      'paintbrush': 'Levé tlačítko maluje primární barvou, pravé sekundární.',
      'eraser': 'Tažením mažete do průhlednosti.',
      'pencil': 'Kreslí jednopixelové čáry bez vyhlazování.',
      'color_picker':
          'Kliknutí levým tlačítkem nabere primární barvu, pravým sekundární.',
      'clone_stamp': 'Kliknutím se stisknutou klávesou Ctrl nastavte zdroj a poté z něj tažením malujte.',
      'recolor': 'Tam, kde malujete, nahrazuje sekundární barvu primární. Kliknutí se stisknutou klávesou Ctrl nabere barvu.',
      'text': 'Kliknutím umístěte kurzor a pište. Tažením úchytu nebo tažením pravým tlačítkem text přesunete, klávesou Esc dokončíte.',
      'line_curve': 'Tažením nakreslete čáru. Tažením úchytů ji ohnete, klávesou Enter dokončíte.',
      'rectangle': 'Tažením nakreslete obdélník. Podržením klávesy Shift nakreslíte čtverec.',
      'rounded_rectangle': 'Tažením nakreslete zaoblený obdélník. Podržením klávesy Shift nakreslíte čtverec.',
      'ellipse':
          'Tažením nakreslete elipsu. Podržením klávesy Shift nakreslíte kruh.',
      'freeform_shape': 'Tažením nakreslete uzavřený volný tvar.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Poloměr',
      'angle': 'Úhel',
      'distance': 'Vzdálenost',
      'centered': 'Od středu',
      'amount': 'Množství',
      'intensity': 'Intenzita',
      'saturation': 'Sytost',
      'coverage': 'Pokrytí',
      'seed': 'Semínko',
      'percentile': 'Percentil',
      'cell_size': 'Velikost buňky',
      'brush_size': 'Velikost štětce',
      'coarseness': 'Hrubost',
      'thickness': 'Tloušťka',
      'brightness': 'Jas',
      'contrast': 'Kontrast',
      'hue': 'Odstín',
      'lightness': 'Světlost',
      'red': 'Červená',
      'green': 'Zelená',
      'blue': 'Modrá',
      'input_low': 'Vstup: minimum',
      'input_high': 'Vstup: maximum',
      'output_low': 'Výstup: minimum',
      'output_high': 'Výstup: maximum',
      'gamma': 'Gama',
      'ink_outline': 'Obrys inkoustem',
      'coloring': 'Zbarvení',
      'tip_size': 'Velikost hrotu tužky',
      'color_range': 'Rozsah barev',
      'fragments': 'Fragmenty',
      'rotation': 'Otočení',
      'offset_x': 'Posun X',
      'offset_y': 'Posun Y',
      'quality': 'Kvalita',
      'threshold': 'Práh',
      'scale': 'Měřítko',
      'refraction': 'Lom',
      'roughness': 'Drsnost',
      'tension': 'Napětí',
      'max_scatter': 'Maximální rozptyl',
      'min_scatter': 'Minimální rozptyl',
      'samples': 'Vzorky',
      'edge_behavior': 'Chování na okrajích',
      'tile_size': 'Velikost dlaždice',
      'curvature': 'Zakřivení',
      'size': 'Velikost',
      'strength': 'Síla',
      'tolerance': 'Tolerance',
      'softness': 'Měkkost',
      'lighting': 'Osvětlení',
      'warmth': 'Teplota',
      'power': 'Mocnina',
      'blend_mode': 'Režim prolnutí',
      'factor': 'Faktor',
      'zoom': 'Přiblížení',
      'invert_colors': 'Invertovat barvy',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normální',
      'multiply': 'Násobit',
      'additive': 'Sečíst',
      'colorBurn': 'Ztmavit barvy',
      'colorDodge': 'Zesvětlit barvy',
      'reflect': 'Odraz',
      'glow': 'Záře',
      'overlay': 'Překrýt',
      'difference': 'Rozdíl',
      'negation': 'Negace',
      'lighten': 'Zesvětlit',
      'darken': 'Ztmavit',
      'screen': 'Závoj',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Pro obrázek není dost paměti.',
      'invalid_size': 'Velikost obrázku je neplatná.',
      'layer_index': 'Taková vrstva neexistuje.',
      'last_layer': 'Poslední vrstvu nelze odstranit.',
      'no_layer_below': 'Pod touto vrstvou není žádná vrstva, se kterou by ji bylo možné sloučit.',
      'edit_in_progress': 'Nejprve dokončete rozpracovanou úpravu.',
      'no_edit': 'Žádná úprava není rozpracovaná.',
      'no_selection': 'Nic není vybráno.',
      'nothing_lifted': 'Žádné pixely nejsou zvednuté.',
      'invalid_parameter': 'Hodnota je mimo povolený rozsah.',
      'io': 'Soubor nelze přečíst ani zapsat.',
      'decode': 'Obrázek nelze přečíst.',
      'encode': 'Obrázek nelze zapsat.',
      'open_raster': 'Soubor OpenRaster je poškozený.',
      'palette': 'Soubor palety je poškozený.',
      'cancelled': 'Výpočet byl zrušen.',
      'other': 'Došlo k chybě.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Soubor nelze přečíst ani zapsat.';

  @override
  String get failureInvalidData => 'Data nelze přečíst.';

  @override
  String get failureUnknown => 'Došlo k neočekávané chybě.';

  @override
  String get panelTools => 'Nástroje';

  @override
  String get panelHistory => 'Historie';

  @override
  String get panelLayers => 'Vrstvy';

  @override
  String get panelColors => 'Barvy';

  @override
  String get panelHide => 'Skrýt';

  @override
  String get colorsPrimary => 'Primární';

  @override
  String get colorsSecondary => 'Sekundární';

  @override
  String get colorsPrimaryHint =>
      'Primární barva: maluje jí levé tlačítko myši';

  @override
  String get colorsSecondaryHint =>
      'Sekundární barva: maluje jí pravé tlačítko myši';

  @override
  String get colorsSwap => 'Prohodit barvy (X)';

  @override
  String get colorsReset => 'Obnovit černou a bílou';

  @override
  String get colorsMore => 'Více';

  @override
  String get colorsLess => 'Méně';

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
      'Kliknutí levým tlačítkem nastaví primární barvu, pravým sekundární';

  @override
  String get settingWidth => 'Šířka';

  @override
  String get settingHardness => 'Tvrdost';

  @override
  String get settingAntialias => 'Vyhlazování';

  @override
  String get settingAlphaBlending => 'Prolínání alfa';

  @override
  String get settingTolerance => 'Tolerance';

  @override
  String get settingFloodMode => 'Režim vyplňování';

  @override
  String get floodLocal => 'Souvislý';

  @override
  String get floodGlobal => 'Globální';

  @override
  String get settingSelectionMode => 'Režim výběru';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Nahradit',
      'union': 'Přidat',
      'exclude': 'Odečíst',
      'xor': 'XOR',
      'intersect': 'Protnout',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Velikost výběru';

  @override
  String get drawNormal => 'Libovolná';

  @override
  String get drawFixedRatio => 'Pevný poměr stran';

  @override
  String get drawFixedSize => 'Pevná velikost';

  @override
  String get settingResampling => 'Převzorkování';

  @override
  String get resamplingNearest => 'Nejbližší soused';

  @override
  String get resamplingBilinear => 'Bilineární';

  @override
  String get settingGradient => 'Typ';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineární',
      'linearReflected': 'Lineární zrcadlený',
      'diamond': 'Kosočtverečný',
      'radial': 'Radiální',
      'conical': 'Kuželový',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Barva';

  @override
  String get gradientTransparency => 'Průhlednost';

  @override
  String get settingShape => 'Styl tvaru';

  @override
  String get shapeOutline => 'Obrys';

  @override
  String get shapeInterior => 'Výplň';

  @override
  String get shapeBoth => 'Obrys a výplň';

  @override
  String get settingAfterPick => 'Po nabrání barvy';

  @override
  String get pickStay => 'Ponechat tento nástroj';

  @override
  String get pickPrevious => 'Přepnout na předchozí nástroj';

  @override
  String get pickPencil => 'Přepnout na Tužku';

  @override
  String get settingNone => 'Tento nástroj nemá žádná nastavení.';

  @override
  String toolUnavailable(String name) {
    return 'Nástroj „$name“ zatím není k dispozici';
  }

  @override
  String get historyFirst => 'Přejít na první krok';

  @override
  String get historyUndo => 'Zpět';

  @override
  String get historyRedo => 'Znovu';

  @override
  String get historyLast => 'Přejít na poslední krok';

  @override
  String get historyNewImage => 'Nový obrázek';

  @override
  String get historyOpenImage => 'Otevření obrázku';

  @override
  String get layerVisible => 'Zobrazit nebo skrýt vrstvu';

  @override
  String get layerBackground => 'Pozadí';

  @override
  String get layerName => 'Název';

  @override
  String get layerOpacity => 'Krytí';

  @override
  String get layerBlendMode => 'Režim prolnutí';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Zrušit';

  @override
  String get save => 'Uložit';

  @override
  String get dontSave => 'Neukládat';

  @override
  String get keepCanvas => 'Zachovat plátno';

  @override
  String get expandCanvas => 'Zvětšit plátno';

  @override
  String get width => 'Šířka';

  @override
  String get height => 'Výška';

  @override
  String get pixels => 'pixelů';

  @override
  String get newImageTitle => 'Nový obrázek';

  @override
  String get resizeTitle => 'Změnit velikost obrázku';

  @override
  String get canvasSizeTitle => 'Velikost plátna';

  @override
  String get keepRatio => 'Zachovat poměr stran';

  @override
  String get anchor => 'Ukotvení';

  @override
  String sizeTooLarge(int max) {
    return 'Obrázek je příliš velký: limit je $max megapixelů.';
  }

  @override
  String get unsavedTitle => 'Uložit změny?';

  @override
  String unsavedMessage(String name) {
    return '„$name“ obsahuje neuložené změny.';
  }

  @override
  String get flattenTitle => 'Sloučit obrázek do jedné vrstvy?';

  @override
  String flattenMessage(String format) {
    return 'Formát $format nepodporuje vrstvy, proto bude obrázek sloučen do jedné vrstvy. Tuto akci lze vrátit zpět v okně Historie.';
  }

  @override
  String get flatten => 'Sloučit';

  @override
  String get jpegQualityTitle => 'Kvalita JPEG';

  @override
  String get quality => 'Kvalita';

  @override
  String get largerTitle => 'Obrázek je větší než plátno';

  @override
  String get largerMessage => 'Zvětšit plátno, aby se do něj obrázek vešel?';

  @override
  String get reseed => 'Nové semínko';

  @override
  String get rendering => 'Vykreslování…';

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
    return 'Otevírání $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Ukládání $name…';
  }

  @override
  String savedTo(String name) {
    return 'Uloženo: $name';
  }

  @override
  String get dropHere => 'Pusťte pro otevření';

  @override
  String get dropHint => 'Každý soubor se otevře jako nový obrázek';

  @override
  String get imagesList => 'Otevřené obrázky';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Editor rastrových obrázků s vrstvami. Nástroj zvolíte stisknutím písmene; opakované stisknutí S, M nebo O přepíná mezi příbuznými nástroji. [ a ] mění šířku štětce, X prohodí barvy, podržení mezerníku posouvá zobrazení, Ctrl+kolečko myši mění přiblížení a F5–F8 zobrazují nebo skrývají okna.';

  @override
  String get aboutLegal =>
      '© 2026 autoři Paintboxu. Paintbox je svobodný software: můžete jej šířit a upravovat za podmínek licence GNU General Public License verze 3 nebo novější. Program je poskytován bez jakékoli záruky.';

  @override
  String get licenses => 'Licence';

  @override
  String get settingLineStart => 'Začátek';

  @override
  String get settingLineEnd => 'Konec';

  @override
  String get settingDash => 'Přerušování';

  @override
  String get settingSwapSize => 'Prohodit šířku a výšku';

  @override
  String get settingLineStyle => 'Styl';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plochý',
      'arrow': 'Šipka',
      'arrowFilled': 'Plná šipka',
      'rounded': 'Zaoblený',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Plná',
      'dash': 'Čárkovaná',
      'dashDot': 'Čerchovaná',
      'dashDotDot': 'Dvojitě čerchovaná',
      'dot': 'Tečkovaná',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Písmo';

  @override
  String get settingFontSize => 'Velikost';

  @override
  String get textBold => 'Tučné';

  @override
  String get textItalic => 'Kurzíva';

  @override
  String get textUnderline => 'Podtržené';

  @override
  String get textStrikeout => 'Přeškrtnuté';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Vlevo',
      'center': 'Na střed',
      'right': 'Vpravo',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Obrázky';
}
