// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Bez nosaukuma $number';
  }

  @override
  String get menuFile => 'Fails';

  @override
  String get menuEdit => 'Rediģēt';

  @override
  String get menuView => 'Skats';

  @override
  String get menuImage => 'Attēls';

  @override
  String get menuLayers => 'Slāņi';

  @override
  String get menuAdjustments => 'Korekcijas';

  @override
  String get menuEffects => 'Efekti';

  @override
  String get menuOpenRecent => 'Nesenie faili';

  @override
  String get menuRecentEmpty => 'Nav neseno failu';

  @override
  String get menuTheme => 'Motīvs';

  @override
  String get menuSettings => 'Iestatījumi';

  @override
  String get menuAccent => 'Akcenta krāsa';

  @override
  String get menuLanguage => 'Valoda';

  @override
  String get languageSystem => 'Sistēmas noklusējums';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Zila',
      'green': 'Zaļa',
      'amber': 'Dzintara',
      'purple': 'Violeta',
      'red': 'Sarkana',
      'gray': 'Pelēka',
      'custom': 'Pielāgota…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Pielāgota akcenta krāsa';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Sistēmas noklusējums';

  @override
  String get themeDark => 'Tumšs';

  @override
  String get themeLight => 'Gaišs';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Jauns…',
      'open': 'Atvērt…',
      'close': 'Aizvērt',
      'save': 'Saglabāt',
      'save_as': 'Saglabāt kā…',
      'exit': 'Iziet',
      'undo': 'Atsaukt',
      'redo': 'Atcelt atsaukšanu',
      'cut': 'Izgriezt',
      'copy': 'Kopēt',
      'paste': 'Ielīmēt',
      'paste_into_new_layer': 'Ielīmēt jaunā slānī',
      'paste_into_new_image': 'Ielīmēt jaunā attēlā',
      'erase_selection': 'Dzēst atlasīto',
      'fill_selection': 'Aizpildīt atlasīto',
      'invert_selection': 'Invertēt atlasi',
      'select_all': 'Atlasīt visu',
      'deselect': 'Noņemt atlasi',
      'zoom_in': 'Tuvināt',
      'zoom_out': 'Tālināt',
      'zoom_to_window': 'Ietilpināt logā',
      'zoom_to_selection': 'Tuvināt atlasi',
      'actual_size': 'Faktiskais izmērs',
      'pixel_grid': 'Pikseļu režģis',
      'rulers': 'Lineāli',
      'crop_to_selection': 'Apgriezt pēc atlases',
      'resize': 'Mainīt izmēru…',
      'canvas_size': 'Audekla izmērs…',
      'flip_horizontal': 'Apmest horizontāli',
      'flip_vertical': 'Apmest vertikāli',
      'rotate90_cw': 'Pagriezt par 90° pulksteņrādītāja virzienā',
      'rotate90_ccw': 'Pagriezt par 90° pretēji pulksteņrādītāja virzienam',
      'rotate180': 'Pagriezt par 180°',
      'flatten': 'Saplacināt',
      'add_layer': 'Pievienot jaunu slāni',
      'delete_layer': 'Dzēst slāni',
      'duplicate_layer': 'Dublēt slāni',
      'merge_layer_down': 'Sapludināt ar apakšējo slāni',
      'import_from_file': 'Importēt no faila…',
      'flip_layer_horizontal': 'Apmest slāni horizontāli',
      'flip_layer_vertical': 'Apmest slāni vertikāli',
      'move_layer_up': 'Pārvietot slāni uz augšu',
      'move_layer_down': 'Pārvietot slāni uz leju',
      'layer_properties': 'Slāņa rekvizīti…',
      'adjust_auto_level': 'Automātiskie līmeņi',
      'adjust_black_and_white': 'Melnbalts',
      'adjust_brightness_contrast': 'Spilgtums / kontrasts…',
      'adjust_curves': 'Līknes…',
      'adjust_hue_saturation': 'Nokrāsa / piesātinājums…',
      'adjust_invert_colors': 'Invertēt krāsas',
      'adjust_levels': 'Līmeņi…',
      'adjust_posterize': 'Posterizācija…',
      'adjust_sepia': 'Sēpija',
      'repeat_effect': 'Atkārtot efektu',
      'effect_oil_painting': 'Eļļas glezna…',
      'effect_gaussian_blur': 'Gausa izpludināšana…',
      'effect_motion_blur': 'Kustības izpludināšana…',
      'effect_pixelate': 'Pikselizācija…',
      'effect_add_noise': 'Trokšņa pievienošana…',
      'effect_median': 'Mediāna…',
      'effect_sharpen': 'Asināšana…',
      'effect_edge_detect': 'Malu noteikšana…',
      'effect_emboss': 'Reljefspiedums…',
      'effect_outline': 'Kontūra…',
      'toggle_tools': 'Rīki',
      'toggle_history': 'Vēsture',
      'toggle_layers': 'Slāņi',
      'toggle_colors': 'Krāsas',
      'next_image': 'Nākamais attēls',
      'previous_image': 'Iepriekšējais attēls',
      'help': 'Palīdzība',
      'effect_ink_sketch': 'Tušas skice…',
      'effect_pencil_sketch': 'Zīmuļa skice…',
      'effect_fragment': 'Fragmentēšana…',
      'effect_radial_blur': 'Radiālā izpludināšana…',
      'effect_surface_blur': 'Virsmas izpludināšana…',
      'effect_unfocus': 'Atfokusēšana…',
      'effect_zoom_blur': 'Tālummaiņas izpludināšana…',
      'effect_bulge': 'Izliekums…',
      'effect_dents': 'Iespiedumi…',
      'effect_frosted_glass': 'Matēts stikls…',
      'effect_polar_inversion': 'Polārā inversija…',
      'effect_tile_reflection': 'Flīžu atspulgs…',
      'effect_twist': 'Savērpšana…',
      'effect_reduce_noise': 'Trokšņa samazināšana…',
      'effect_glow': 'Mirdzums…',
      'effect_red_eye_removal': 'Sarkano acu noņemšana…',
      'effect_soften_portrait': 'Portreta mīkstināšana…',
      'effect_clouds': 'Mākoņi…',
      'effect_julia_fractal': 'Žiljā fraktālis…',
      'effect_mandelbrot_fractal': 'Mandelbrota fraktālis…',
      'effect_relief': 'Reljefs…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Mākslinieciskie',
      'blurs': 'Izpludināšana',
      'distort': 'Kropļojumi',
      'noise': 'Troksnis',
      'photo': 'Foto',
      'stylize': 'Stilizācija',
      'render': 'Renderēšana',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Taisnstūra atlase',
      'move_selected_pixels': 'Atlasīto pikseļu pārvietošana',
      'lasso_select': 'Lasso atlase',
      'move_selection': 'Atlases pārvietošana',
      'ellipse_select': 'Elipses atlase',
      'zoom': 'Tālummaiņa',
      'magic_wand': 'Burvju nūjiņa',
      'pan': 'Panoramēšana',
      'paint_bucket': 'Krāsas spainis',
      'gradient': 'Krāsu pāreja',
      'paintbrush': 'Ota',
      'eraser': 'Dzēšgumija',
      'pencil': 'Zīmulis',
      'color_picker': 'Krāsu pipete',
      'clone_stamp': 'Klonēšanas zīmogs',
      'recolor': 'Pārkrāsošana',
      'text': 'Teksts',
      'line_curve': 'Līnija / līkne',
      'rectangle': 'Taisnstūris',
      'rounded_rectangle': 'Noapaļots taisnstūris',
      'ellipse': 'Elipse',
      'freeform_shape': 'Brīvas formas figūra',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Velciet, lai atlasītu taisnstūri. Turiet nospiestu Shift, lai iegūtu kvadrātu.',
      'move_selected_pixels': 'Velciet atlasi, lai to pārvietotu. Velciet ar labo pogu, lai to pagrieztu, vai velciet turus, lai to mērogotu. Ar Ctrl tiek atstāta kopija, bet bulttaustiņi atlasi pabīda pa nedaudz.',
      'lasso_select': 'Velciet, lai uzzīmētu atlases kontūru.',
      'move_selection': 'Velciet atlases kontūru, lai to pārvietotu. Pikseļi paliek savā vietā.',
      'ellipse_select': 'Velciet, lai atlasītu elipsi. Turiet nospiestu Shift, lai iegūtu apli.',
      'zoom': 'Klikšķis ar kreiso pogu tuvina, ar labo pogu – tālina, bet, ievelkot rāmi, tiek tuvināts tā apgabals.',
      'magic_wand': 'Noklikšķiniet uz krāsas, lai atlasītu apgabalu ap to. Turiet nospiestu Shift, lai atlasītu šo krāsu visā attēlā.',
      'pan': 'Velciet, lai pārvietotu skatu.',
      'paint_bucket': 'Klikšķis ar kreiso pogu aizpilda ar primāro krāsu, ar labo pogu – ar sekundāro.',
      'gradient': 'Velciet, lai uzzīmētu krāsu pāreju. Velciet turus, lai to pielāgotu; nospiediet Enter, lai pabeigtu.',
      'paintbrush':
          'Kreisā poga zīmē ar primāro krāsu, labā poga – ar sekundāro.',
      'eraser': 'Velciet, lai izdzēstu līdz pilnīgam caurspīdīgumam.',
      'pencil': 'Zīmē viena pikseļa platas līnijas bez nogludināšanas.',
      'color_picker': 'Klikšķis ar kreiso pogu paņem primāro krāsu, ar labo pogu – sekundāro.',
      'clone_stamp':
          'Ar Ctrl+klikšķi iestatiet avotu, pēc tam velciet, lai zīmētu no tā.',
      'recolor': 'Vietās, kur zīmējat, aizstāj sekundāro krāsu ar primāro. Ctrl+klikšķis paņem krāsu.',
      'text': 'Noklikšķiniet, lai novietotu kursoru, un rakstiet. Velciet turi vai velciet ar labo pogu, lai pārvietotu tekstu; nospiediet Esc, lai pabeigtu.',
      'line_curve': 'Velciet, lai uzzīmētu līniju. Velciet turus, lai to izliektu; nospiediet Enter, lai pabeigtu.',
      'rectangle': 'Velciet, lai uzzīmētu taisnstūri. Turiet nospiestu Shift, lai iegūtu kvadrātu.',
      'rounded_rectangle': 'Velciet, lai uzzīmētu noapaļotu taisnstūri. Turiet nospiestu Shift, lai iegūtu kvadrātu.',
      'ellipse': 'Velciet, lai uzzīmētu elipsi. Turiet nospiestu Shift, lai iegūtu apli.',
      'freeform_shape': 'Velciet, lai uzzīmētu slēgtu brīvas formas figūru.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Rādiuss',
      'angle': 'Leņķis',
      'distance': 'Attālums',
      'centered': 'Centrēts',
      'amount': 'Daudzums',
      'intensity': 'Intensitāte',
      'saturation': 'Piesātinājums',
      'coverage': 'Pārklājums',
      'seed': 'Sēkla',
      'percentile': 'Procentile',
      'cell_size': 'Šūnas izmērs',
      'brush_size': 'Otas izmērs',
      'coarseness': 'Raupjums',
      'thickness': 'Biezums',
      'brightness': 'Spilgtums',
      'contrast': 'Kontrasts',
      'hue': 'Nokrāsa',
      'lightness': 'Gaišums',
      'red': 'Sarkans',
      'green': 'Zaļš',
      'blue': 'Zils',
      'input_low': 'Ievades minimums',
      'input_high': 'Ievades maksimums',
      'output_low': 'Izvades minimums',
      'output_high': 'Izvades maksimums',
      'gamma': 'Gamma',
      'ink_outline': 'Tušas kontūra',
      'coloring': 'Krāsojums',
      'tip_size': 'Zīmuļa smailes izmērs',
      'color_range': 'Krāsu diapazons',
      'fragments': 'Fragmenti',
      'rotation': 'Pagriešana',
      'offset_x': 'X nobīde',
      'offset_y': 'Y nobīde',
      'quality': 'Kvalitāte',
      'threshold': 'Slieksnis',
      'scale': 'Mērogs',
      'refraction': 'Refrakcija',
      'roughness': 'Nelīdzenums',
      'tension': 'Spriegums',
      'max_scatter': 'Maksimālā izkliede',
      'min_scatter': 'Minimālā izkliede',
      'samples': 'Paraugi',
      'edge_behavior': 'Malu apstrāde',
      'tile_size': 'Flīzes izmērs',
      'curvature': 'Izliekums',
      'size': 'Izmērs',
      'strength': 'Stiprums',
      'tolerance': 'Pielaide',
      'softness': 'Mīkstums',
      'lighting': 'Apgaismojums',
      'warmth': 'Siltums',
      'power': 'Pakāpe',
      'blend_mode': 'Sajaukšanas režīms',
      'factor': 'Koeficients',
      'zoom': 'Tālummaiņa',
      'invert_colors': 'Invertēt krāsas',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Parasts',
      'multiply': 'Reizināšana',
      'additive': 'Saskaitīšana',
      'colorBurn': 'Krāsas dedzināšana',
      'colorDodge': 'Krāsas izgaismošana',
      'reflect': 'Atspoguļošana',
      'glow': 'Mirdzums',
      'overlay': 'Pārklāšana',
      'difference': 'Starpība',
      'negation': 'Noliegums',
      'lighten': 'Gaišāks',
      'darken': 'Tumšāks',
      'screen': 'Ekrāns',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Attēlam nepietiek atmiņas.',
      'invalid_size': 'Attēla izmērs nav derīgs.',
      'layer_index': 'Šāda slāņa nav.',
      'last_layer': 'Pēdējo slāni nevar izdzēst.',
      'no_layer_below': 'Zemāk nav slāņa, ar ko sapludināt.',
      'edit_in_progress': 'Vispirms pabeidziet iesākto darbību.',
      'no_edit': 'Nav iesāktas darbības, ko pabeigt.',
      'no_selection': 'Nekas nav atlasīts.',
      'nothing_lifted': 'Nav pacelts neviens pikselis.',
      'invalid_parameter': 'Vērtība ir ārpus pieļaujamā diapazona.',
      'io': 'Failu nevarēja nolasīt vai ierakstīt.',
      'decode': 'Attēlu nevarēja nolasīt.',
      'encode': 'Attēlu nevarēja ierakstīt.',
      'open_raster': 'OpenRaster fails ir bojāts.',
      'palette': 'Paletes fails ir bojāts.',
      'cancelled': 'Aprēķins tika atcelts.',
      'other': 'Radās kļūda.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Failu nevarēja nolasīt vai ierakstīt.';

  @override
  String get failureInvalidData => 'Datus nevarēja nolasīt.';

  @override
  String get failureUnknown => 'Radās neparedzēta kļūda.';

  @override
  String get panelTools => 'Rīki';

  @override
  String get panelHistory => 'Vēsture';

  @override
  String get panelLayers => 'Slāņi';

  @override
  String get panelColors => 'Krāsas';

  @override
  String get panelHide => 'Paslēpt';

  @override
  String get colorsPrimary => 'Primārā';

  @override
  String get colorsSecondary => 'Sekundārā';

  @override
  String get colorsPrimaryHint => 'Primārā krāsa: ar to zīmē peles kreisā poga';

  @override
  String get colorsSecondaryHint =>
      'Sekundārā krāsa: ar to zīmē peles labā poga';

  @override
  String get colorsSwap => 'Samainīt krāsas (X)';

  @override
  String get colorsReset => 'Atiestatīt uz melnu un baltu';

  @override
  String get colorsMore => 'Vairāk';

  @override
  String get colorsLess => 'Mazāk';

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
      'Klikšķis ar kreiso pogu iestata primāro krāsu, ar labo pogu – sekundāro';

  @override
  String get settingWidth => 'Platums';

  @override
  String get settingHardness => 'Cietums';

  @override
  String get settingAntialias => 'Nogludināšana';

  @override
  String get settingAlphaBlending => 'Alfa sajaukšana';

  @override
  String get settingTolerance => 'Pielaide';

  @override
  String get settingFloodMode => 'Aizpildes režīms';

  @override
  String get floodLocal => 'Blakusesošs';

  @override
  String get floodGlobal => 'Globāls';

  @override
  String get settingSelectionMode => 'Atlases režīms';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Aizstāšana',
      'union': 'Apvienojums',
      'exclude': 'Izslēgšana',
      'xor': 'XOR',
      'intersect': 'Šķēlums',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Atlases izmērs';

  @override
  String get drawNormal => 'Parasts';

  @override
  String get drawFixedRatio => 'Fiksēta attiecība';

  @override
  String get drawFixedSize => 'Fiksēts izmērs';

  @override
  String get settingResampling => 'Interpolācija';

  @override
  String get resamplingNearest => 'Tuvākais kaimiņš';

  @override
  String get resamplingBilinear => 'Bilineārā';

  @override
  String get settingGradient => 'Veids';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineāra',
      'linearReflected': 'Lineāra atspoguļota',
      'diamond': 'Rombveida',
      'radial': 'Radiāla',
      'conical': 'Koniska',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Krāsa';

  @override
  String get gradientTransparency => 'Caurspīdīgums';

  @override
  String get settingShape => 'Figūras stils';

  @override
  String get shapeOutline => 'Kontūra';

  @override
  String get shapeInterior => 'Aizpildījums';

  @override
  String get shapeBoth => 'Kontūra un aizpildījums';

  @override
  String get settingAfterPick => 'Pēc krāsas paņemšanas';

  @override
  String get pickStay => 'Palikt pie šī rīka';

  @override
  String get pickPrevious => 'Pārslēgties uz iepriekšējo rīku';

  @override
  String get pickPencil => 'Pārslēgties uz zīmuli';

  @override
  String get settingNone => 'Šim rīkam nav iestatījumu.';

  @override
  String toolUnavailable(String name) {
    return 'Rīks “$name” vēl nav pieejams';
  }

  @override
  String get historyFirst => 'Uz pirmo soli';

  @override
  String get historyUndo => 'Atsaukt';

  @override
  String get historyRedo => 'Atcelt atsaukšanu';

  @override
  String get historyLast => 'Uz pēdējo soli';

  @override
  String get historyNewImage => 'Jauns attēls';

  @override
  String get historyOpenImage => 'Attēla atvēršana';

  @override
  String get layerVisible => 'Rādīt vai paslēpt slāni';

  @override
  String get layerBackground => 'Fons';

  @override
  String get layerName => 'Nosaukums';

  @override
  String get layerOpacity => 'Necaurspīdīgums';

  @override
  String get layerBlendMode => 'Sajaukšanas režīms';

  @override
  String get ok => 'Labi';

  @override
  String get cancel => 'Atcelt';

  @override
  String get save => 'Saglabāt';

  @override
  String get dontSave => 'Nesaglabāt';

  @override
  String get keepCanvas => 'Saglabāt audeklu';

  @override
  String get expandCanvas => 'Paplašināt audeklu';

  @override
  String get width => 'Platums';

  @override
  String get height => 'Augstums';

  @override
  String get pixels => 'pikseļi';

  @override
  String get newImageTitle => 'Jauns attēls';

  @override
  String get resizeTitle => 'Attēla izmēra maiņa';

  @override
  String get canvasSizeTitle => 'Audekla izmērs';

  @override
  String get keepRatio => 'Saglabāt malu attiecību';

  @override
  String get anchor => 'Enkurs';

  @override
  String sizeTooLarge(int max) {
    return 'Attēls ir pārāk liels: ierobežojums ir $max megapikseļi.';
  }

  @override
  String get unsavedTitle => 'Saglabāt izmaiņas?';

  @override
  String unsavedMessage(String name) {
    return 'Attēlā “$name” ir nesaglabātas izmaiņas.';
  }

  @override
  String get flattenTitle => 'Saplacināt attēlu?';

  @override
  String flattenMessage(String format) {
    return 'Formāts $format nesaglabā slāņus, tāpēc attēls tiks saplacināts vienā slānī. Šo darbību var atsaukt logā “Vēsture”.';
  }

  @override
  String get flatten => 'Saplacināt';

  @override
  String get jpegQualityTitle => 'JPEG kvalitāte';

  @override
  String get quality => 'Kvalitāte';

  @override
  String get largerTitle => 'Attēls ir lielāks par audeklu';

  @override
  String get largerMessage => 'Paplašināt audeklu, lai attēls tajā ietilptu?';

  @override
  String get reseed => 'Jauna sēkla';

  @override
  String get rendering => 'Renderē…';

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
    return '$percent%';
  }

  @override
  String statusOpening(String name) {
    return 'Atver $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Saglabā $name…';
  }

  @override
  String savedTo(String name) {
    return 'Saglabāts: $name';
  }

  @override
  String get dropHere => 'Atlaidiet, lai atvērtu';

  @override
  String get dropHint => 'Katrs fails tiek atvērts kā jauns attēls';

  @override
  String get imagesList => 'Atvērtie attēli';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Rastra attēlu redaktors ar slāņiem. Rīku izvēlas, nospiežot tā burtu; atkārtoti nospiežot S, M vai O, tiek pārslēgti radniecīgie rīki. [ un ] maina otas platumu, X samaina krāsas, turot nospiestu atstarpes taustiņu, var pārvietot skatu, Ctrl+peles ritenītis maina tālummaiņu, bet F5–F8 parāda vai paslēpj logus.';

  @override
  String get aboutLegal =>
      '© 2026 Paintbox autori. Paintbox ir brīvā programmatūra: to drīkst izplatīt un mainīt saskaņā ar GNU General Public License 3. vai jaunākas versijas noteikumiem. Programma tiek nodrošināta bez jebkādas garantijas.';

  @override
  String get licenses => 'Licences';

  @override
  String get settingLineStart => 'Sākums';

  @override
  String get settingLineEnd => 'Beigas';

  @override
  String get settingDash => 'Svītrojums';

  @override
  String get settingSwapSize => 'Samainīt platumu un augstumu';

  @override
  String get settingLineStyle => 'Stils';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plakans',
      'arrow': 'Bulta',
      'arrowFilled': 'Aizpildīta bulta',
      'rounded': 'Noapaļots',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Nepārtraukta',
      'dash': 'Svītra',
      'dashDot': 'Svītra punkts',
      'dashDotDot': 'Svītra divi punkti',
      'dot': 'Punkti',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Fonts';

  @override
  String get settingFontSize => 'Izmērs';

  @override
  String get textBold => 'Treknraksts';

  @override
  String get textItalic => 'Slīpraksts';

  @override
  String get textUnderline => 'Pasvītrojums';

  @override
  String get textStrikeout => 'Pārsvītrojums';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Pa kreisi',
      'center': 'Centrā',
      'right': 'Pa labi',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Attēli';
}
