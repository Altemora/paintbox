// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Be pavadinimo $number';
  }

  @override
  String get menuFile => 'Failas';

  @override
  String get menuEdit => 'Taisa';

  @override
  String get menuView => 'Rodinys';

  @override
  String get menuImage => 'Paveikslėlis';

  @override
  String get menuLayers => 'Sluoksniai';

  @override
  String get menuAdjustments => 'Korekcijos';

  @override
  String get menuEffects => 'Efektai';

  @override
  String get menuOpenRecent => 'Paskiausi failai';

  @override
  String get menuRecentEmpty => 'Paskiausių failų nėra';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Nuostatos';

  @override
  String get menuAccent => 'Akcento spalva';

  @override
  String get menuLanguage => 'Kalba';

  @override
  String get languageSystem => 'Sistemos numatytoji';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Mėlyna',
      'green': 'Žalia',
      'amber': 'Gintarinė',
      'purple': 'Violetinė',
      'red': 'Raudona',
      'gray': 'Pilka',
      'custom': 'Pasirinktinė…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Pasirinktinė akcento spalva';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Sistemos numatytoji';

  @override
  String get themeDark => 'Tamsi';

  @override
  String get themeLight => 'Šviesi';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Naujas…',
      'open': 'Atverti…',
      'close': 'Užverti',
      'save': 'Įrašyti',
      'save_as': 'Įrašyti kaip…',
      'exit': 'Išeiti',
      'undo': 'Atšaukti',
      'redo': 'Grąžinti',
      'cut': 'Iškirpti',
      'copy': 'Kopijuoti',
      'paste': 'Įdėti',
      'paste_into_new_layer': 'Įdėti į naują sluoksnį',
      'paste_into_new_image': 'Įdėti į naują paveikslėlį',
      'erase_selection': 'Ištrinti pažymėtą sritį',
      'fill_selection': 'Užpildyti pažymėtą sritį',
      'invert_selection': 'Invertuoti žymėjimą',
      'select_all': 'Pažymėti viską',
      'deselect': 'Atžymėti',
      'zoom_in': 'Didinti',
      'zoom_out': 'Mažinti',
      'zoom_to_window': 'Pritaikyti prie lango',
      'zoom_to_selection': 'Pritaikyti prie žymėjimo',
      'actual_size': 'Tikrasis dydis',
      'pixel_grid': 'Pikselių tinklelis',
      'rulers': 'Liniuotės',
      'crop_to_selection': 'Apkirpti pagal žymėjimą',
      'resize': 'Keisti dydį…',
      'canvas_size': 'Drobės dydis…',
      'flip_horizontal': 'Apversti horizontaliai',
      'flip_vertical': 'Apversti vertikaliai',
      'rotate90_cw': 'Pasukti 90° pagal laikrodžio rodyklę',
      'rotate90_ccw': 'Pasukti 90° prieš laikrodžio rodyklę',
      'rotate180': 'Pasukti 180°',
      'flatten': 'Suplokštinti',
      'add_layer': 'Pridėti naują sluoksnį',
      'delete_layer': 'Šalinti sluoksnį',
      'duplicate_layer': 'Dubliuoti sluoksnį',
      'merge_layer_down': 'Sulieti su apatiniu sluoksniu',
      'import_from_file': 'Importuoti iš failo…',
      'flip_layer_horizontal': 'Apversti sluoksnį horizontaliai',
      'flip_layer_vertical': 'Apversti sluoksnį vertikaliai',
      'move_layer_up': 'Perkelti sluoksnį aukštyn',
      'move_layer_down': 'Perkelti sluoksnį žemyn',
      'layer_properties': 'Sluoksnio savybės…',
      'adjust_auto_level': 'Automatiniai lygiai',
      'adjust_black_and_white': 'Nespalvotas',
      'adjust_brightness_contrast': 'Ryškumas / kontrastas…',
      'adjust_curves': 'Kreivės…',
      'adjust_hue_saturation': 'Atspalvis / sodrumas…',
      'adjust_invert_colors': 'Invertuoti spalvas',
      'adjust_levels': 'Lygiai…',
      'adjust_posterize': 'Posterizacija…',
      'adjust_sepia': 'Sepija',
      'repeat_effect': 'Pakartoti efektą',
      'effect_oil_painting': 'Aliejinė tapyba…',
      'effect_gaussian_blur': 'Gauso suliejimas…',
      'effect_motion_blur': 'Judesio suliejimas…',
      'effect_pixelate': 'Pikselizacija…',
      'effect_add_noise': 'Triukšmo pridėjimas…',
      'effect_median': 'Mediana…',
      'effect_sharpen': 'Ryškinimas…',
      'effect_edge_detect': 'Kraštų aptikimas…',
      'effect_emboss': 'Įspaudas…',
      'effect_outline': 'Kontūras…',
      'toggle_tools': 'Įrankiai',
      'toggle_history': 'Istorija',
      'toggle_layers': 'Sluoksniai',
      'toggle_colors': 'Spalvos',
      'next_image': 'Kitas paveikslėlis',
      'previous_image': 'Ankstesnis paveikslėlis',
      'help': 'Žinynas',
      'effect_ink_sketch': 'Rašalo eskizas…',
      'effect_pencil_sketch': 'Pieštuko eskizas…',
      'effect_fragment': 'Fragmentavimas…',
      'effect_radial_blur': 'Radialinis suliejimas…',
      'effect_surface_blur': 'Paviršiaus suliejimas…',
      'effect_unfocus': 'Išfokusavimas…',
      'effect_zoom_blur': 'Priartinimo suliejimas…',
      'effect_bulge': 'Išgaubimas…',
      'effect_dents': 'Įdubos…',
      'effect_frosted_glass': 'Matinis stiklas…',
      'effect_polar_inversion': 'Polinė inversija…',
      'effect_tile_reflection': 'Plytelių atspindys…',
      'effect_twist': 'Susukimas…',
      'effect_reduce_noise': 'Triukšmo mažinimas…',
      'effect_glow': 'Švytėjimas…',
      'effect_red_eye_removal': 'Raudonų akių šalinimas…',
      'effect_soften_portrait': 'Portreto švelninimas…',
      'effect_clouds': 'Debesys…',
      'effect_julia_fractal': 'Žiulijos fraktalas…',
      'effect_mandelbrot_fractal': 'Mandelbroto fraktalas…',
      'effect_relief': 'Reljefas…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Meniniai',
      'blurs': 'Suliejimai',
      'distort': 'Iškraipymai',
      'noise': 'Triukšmas',
      'photo': 'Nuotraukos',
      'stylize': 'Stilizavimas',
      'render': 'Generavimas',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Stačiakampis žymėjimas',
      'move_selected_pixels': 'Pažymėtų pikselių perkėlimas',
      'lasso_select': 'Laso žymėjimas',
      'move_selection': 'Žymėjimo perkėlimas',
      'ellipse_select': 'Elipsinis žymėjimas',
      'zoom': 'Mastelis',
      'magic_wand': 'Burtų lazdelė',
      'pan': 'Slinkimas',
      'paint_bucket': 'Dažų kibirėlis',
      'gradient': 'Gradientas',
      'paintbrush': 'Teptukas',
      'eraser': 'Trintukas',
      'pencil': 'Pieštukas',
      'color_picker': 'Pipetė',
      'clone_stamp': 'Klonavimo antspaudas',
      'recolor': 'Perdažymas',
      'text': 'Tekstas',
      'line_curve': 'Linija / kreivė',
      'rectangle': 'Stačiakampis',
      'rounded_rectangle': 'Suapvalintas stačiakampis',
      'ellipse': 'Elipsė',
      'freeform_shape': 'Laisva figūra',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Vilkite, kad pažymėtumėte stačiakampį. Laikydami nuspaudę Shift gausite kvadratą.',
      'move_selected_pixels': 'Vilkite pažymėtą sritį, kad ją perkeltumėte. Vilkdami dešiniuoju mygtuku ją pasuksite, o vilkdami rankenėles pakeisite jos mastelį. Su Ctrl paliekama kopija, rodyklių klavišai sritį pastumia po truputį.',
      'lasso_select': 'Vilkite, kad nubrėžtumėte žymėjimo kontūrą.',
      'move_selection': 'Vilkite žymėjimo kontūrą, kad jį perkeltumėte. Pikseliai lieka vietoje.',
      'ellipse_select': 'Vilkite, kad pažymėtumėte elipsę. Laikydami nuspaudę Shift gausite apskritimą.',
      'zoom': 'Spustelėjimas kairiuoju mygtuku didina, dešiniuoju – mažina, o nuvilkus rėmelį priartinama jo sritis.',
      'magic_wand': 'Spustelėkite spalvą, kad pažymėtumėte aplink ją esančią sritį. Laikydami nuspaudę Shift šią spalvą pažymėsite visame paveikslėlyje.',
      'pan': 'Vilkite, kad pastumtumėte rodinį.',
      'paint_bucket': 'Spustelėjimas kairiuoju mygtuku užlieja pagrindine spalva, dešiniuoju – antrine.',
      'gradient': 'Vilkite, kad nubrėžtumėte gradientą. Vilkdami rankenėles jį pakoreguosite, paspaudę Enter užbaigsite.',
      'paintbrush':
          'Kairysis mygtukas piešia pagrindine spalva, dešinysis – antrine.',
      'eraser': 'Vilkite, kad ištrintumėte iki visiško permatomumo.',
      'pencil': 'Piešia vieno pikselio storio linijas be glodinimo.',
      'color_picker': 'Spustelėjimas kairiuoju mygtuku paima pagrindinę spalvą, dešiniuoju – antrinę.',
      'clone_stamp': 'Ctrl+spustelėjimu nustatykite šaltinį, tada vilkite, kad pieštumėte iš jo.',
      'recolor': 'Ten, kur piešiate, antrinę spalvą pakeičia pagrindine. Ctrl+spustelėjimas paima spalvą.',
      'text': 'Spustelėkite, kad padėtumėte žymeklį, ir rašykite. Tekstą perkelsite vilkdami rankenėlę arba vilkdami dešiniuoju mygtuku, paspaudę Esc užbaigsite.',
      'line_curve': 'Vilkite, kad nubrėžtumėte liniją. Vilkdami rankenėles ją išlenksite, paspaudę Enter užbaigsite.',
      'rectangle': 'Vilkite, kad nubrėžtumėte stačiakampį. Laikydami nuspaudę Shift gausite kvadratą.',
      'rounded_rectangle': 'Vilkite, kad nubrėžtumėte suapvalintą stačiakampį. Laikydami nuspaudę Shift gausite kvadratą.',
      'ellipse': 'Vilkite, kad nubrėžtumėte elipsę. Laikydami nuspaudę Shift gausite apskritimą.',
      'freeform_shape': 'Vilkite, kad nubrėžtumėte uždarą laisvą figūrą.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Spindulys',
      'angle': 'Kampas',
      'distance': 'Atstumas',
      'centered': 'Centruota',
      'amount': 'Kiekis',
      'intensity': 'Intensyvumas',
      'saturation': 'Sodrumas',
      'coverage': 'Padengimas',
      'seed': 'Sėkla',
      'percentile': 'Procentilis',
      'cell_size': 'Langelio dydis',
      'brush_size': 'Teptuko dydis',
      'coarseness': 'Grubumas',
      'thickness': 'Storis',
      'brightness': 'Ryškumas',
      'contrast': 'Kontrastas',
      'hue': 'Atspalvis',
      'lightness': 'Šviesumas',
      'red': 'Raudona',
      'green': 'Žalia',
      'blue': 'Mėlyna',
      'input_low': 'Įvesties minimumas',
      'input_high': 'Įvesties maksimumas',
      'output_low': 'Išvesties minimumas',
      'output_high': 'Išvesties maksimumas',
      'gamma': 'Gama',
      'ink_outline': 'Rašalo kontūras',
      'coloring': 'Spalvinimas',
      'tip_size': 'Pieštuko smaigalio dydis',
      'color_range': 'Spalvų diapazonas',
      'fragments': 'Fragmentai',
      'rotation': 'Pasukimas',
      'offset_x': 'X poslinkis',
      'offset_y': 'Y poslinkis',
      'quality': 'Kokybė',
      'threshold': 'Slenkstis',
      'scale': 'Mastelis',
      'refraction': 'Lūžis',
      'roughness': 'Šiurkštumas',
      'tension': 'Įtempimas',
      'max_scatter': 'Didžiausia sklaida',
      'min_scatter': 'Mažiausia sklaida',
      'samples': 'Ėminiai',
      'edge_behavior': 'Kraštų elgsena',
      'tile_size': 'Plytelės dydis',
      'curvature': 'Kreivumas',
      'size': 'Dydis',
      'strength': 'Stiprumas',
      'tolerance': 'Tolerancija',
      'softness': 'Švelnumas',
      'lighting': 'Apšvietimas',
      'warmth': 'Šiluma',
      'power': 'Laipsnis',
      'blend_mode': 'Maišymo režimas',
      'factor': 'Koeficientas',
      'zoom': 'Priartinimas',
      'invert_colors': 'Invertuoti spalvas',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normalus',
      'multiply': 'Daugyba',
      'additive': 'Sudėtis',
      'colorBurn': 'Spalvų degimas',
      'colorDodge': 'Spalvų skaistinimas',
      'reflect': 'Atspindys',
      'glow': 'Švytėjimas',
      'overlay': 'Perdanga',
      'difference': 'Skirtumas',
      'negation': 'Neigimas',
      'lighten': 'Šviesinimas',
      'darken': 'Tamsinimas',
      'screen': 'Ekranas',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Paveikslėliui nepakanka atminties.',
      'invalid_size': 'Netinkamas paveikslėlio dydis.',
      'layer_index': 'Tokio sluoksnio nėra.',
      'last_layer': 'Paskutinio sluoksnio pašalinti negalima.',
      'no_layer_below': 'Žemiau nėra sluoksnio, su kuriuo būtų galima sulieti.',
      'edit_in_progress': 'Pirmiausia užbaikite vykdomą veiksmą.',
      'no_edit': 'Nėra vykdomo veiksmo, kurį reikėtų užbaigti.',
      'no_selection': 'Niekas nepažymėta.',
      'nothing_lifted': 'Nėra pakeltų pikselių.',
      'invalid_parameter': 'Reikšmė nepatenka į leistinas ribas.',
      'io': 'Failo nepavyko perskaityti arba įrašyti.',
      'decode': 'Paveikslėlio nepavyko perskaityti.',
      'encode': 'Paveikslėlio nepavyko įrašyti.',
      'open_raster': 'OpenRaster failas sugadintas.',
      'palette': 'Paletės failas sugadintas.',
      'cancelled': 'Skaičiavimas atšauktas.',
      'other': 'Įvyko klaida.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Failo nepavyko perskaityti arba įrašyti.';

  @override
  String get failureInvalidData => 'Duomenų nepavyko perskaityti.';

  @override
  String get failureUnknown => 'Įvyko netikėta klaida.';

  @override
  String get panelTools => 'Įrankiai';

  @override
  String get panelHistory => 'Istorija';

  @override
  String get panelLayers => 'Sluoksniai';

  @override
  String get panelColors => 'Spalvos';

  @override
  String get panelHide => 'Slėpti';

  @override
  String get colorsPrimary => 'Pagrindinė';

  @override
  String get colorsSecondary => 'Antrinė';

  @override
  String get colorsPrimaryHint =>
      'Pagrindinė spalva: ja piešia kairysis pelės mygtukas';

  @override
  String get colorsSecondaryHint =>
      'Antrinė spalva: ja piešia dešinysis pelės mygtukas';

  @override
  String get colorsSwap => 'Sukeisti spalvas (X)';

  @override
  String get colorsReset => 'Atkurti juodą ir baltą';

  @override
  String get colorsMore => 'Daugiau';

  @override
  String get colorsLess => 'Mažiau';

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
      'Spustelėjimas kairiuoju mygtuku nustato pagrindinę spalvą, dešiniuoju – antrinę';

  @override
  String get settingWidth => 'Plotis';

  @override
  String get settingHardness => 'Kietumas';

  @override
  String get settingAntialias => 'Glodinimas';

  @override
  String get settingAlphaBlending => 'Alfa maišymas';

  @override
  String get settingTolerance => 'Tolerancija';

  @override
  String get settingFloodMode => 'Užliejimo režimas';

  @override
  String get floodLocal => 'Ištisinis';

  @override
  String get floodGlobal => 'Visuotinis';

  @override
  String get settingSelectionMode => 'Žymėjimo režimas';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Pakeitimas',
      'union': 'Sąjunga',
      'exclude': 'Atimtis',
      'xor': 'XOR',
      'intersect': 'Sankirta',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Žymėjimo dydis';

  @override
  String get drawNormal => 'Įprastas';

  @override
  String get drawFixedRatio => 'Fiksuotos proporcijos';

  @override
  String get drawFixedSize => 'Fiksuotas dydis';

  @override
  String get settingResampling => 'Interpoliacija';

  @override
  String get resamplingNearest => 'Artimiausias kaimynas';

  @override
  String get resamplingBilinear => 'Dvitiesinė';

  @override
  String get settingGradient => 'Tipas';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Tiesinis',
      'linearReflected': 'Tiesinis atspindėtas',
      'diamond': 'Rombas',
      'radial': 'Radialinis',
      'conical': 'Kūginis',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Spalva';

  @override
  String get gradientTransparency => 'Permatomumas';

  @override
  String get settingShape => 'Figūros stilius';

  @override
  String get shapeOutline => 'Kontūras';

  @override
  String get shapeInterior => 'Užpildas';

  @override
  String get shapeBoth => 'Kontūras ir užpildas';

  @override
  String get settingAfterPick => 'Paėmus spalvą';

  @override
  String get pickStay => 'Palikti šį įrankį';

  @override
  String get pickPrevious => 'Grįžti prie ankstesnio įrankio';

  @override
  String get pickPencil => 'Pereiti prie pieštuko';

  @override
  String get settingNone => 'Šis įrankis neturi nuostatų.';

  @override
  String toolUnavailable(String name) {
    return 'Įrankis „$name“ kol kas nepasiekiamas';
  }

  @override
  String get historyFirst => 'Eiti į pirmą žingsnį';

  @override
  String get historyUndo => 'Atšaukti';

  @override
  String get historyRedo => 'Grąžinti';

  @override
  String get historyLast => 'Eiti į paskutinį žingsnį';

  @override
  String get historyNewImage => 'Naujas paveikslėlis';

  @override
  String get historyOpenImage => 'Paveikslėlio atvėrimas';

  @override
  String get layerVisible => 'Rodyti arba slėpti sluoksnį';

  @override
  String get layerBackground => 'Fonas';

  @override
  String get layerName => 'Pavadinimas';

  @override
  String get layerOpacity => 'Nepermatomumas';

  @override
  String get layerBlendMode => 'Maišymo režimas';

  @override
  String get ok => 'Gerai';

  @override
  String get cancel => 'Atsisakyti';

  @override
  String get save => 'Įrašyti';

  @override
  String get dontSave => 'Neįrašyti';

  @override
  String get keepCanvas => 'Palikti drobę';

  @override
  String get expandCanvas => 'Padidinti drobę';

  @override
  String get width => 'Plotis';

  @override
  String get height => 'Aukštis';

  @override
  String get pixels => 'pikseliai';

  @override
  String get newImageTitle => 'Naujas paveikslėlis';

  @override
  String get resizeTitle => 'Paveikslėlio dydžio keitimas';

  @override
  String get canvasSizeTitle => 'Drobės dydis';

  @override
  String get keepRatio => 'Išlaikyti proporcijas';

  @override
  String get anchor => 'Inkaras';

  @override
  String sizeTooLarge(int max) {
    return 'Paveikslėlis per didelis: riba yra $max megapikselių.';
  }

  @override
  String get unsavedTitle => 'Įrašyti pakeitimus?';

  @override
  String unsavedMessage(String name) {
    return '„$name“ turi neįrašytų pakeitimų.';
  }

  @override
  String get flattenTitle => 'Suplokštinti paveikslėlį?';

  @override
  String flattenMessage(String format) {
    return '$format formatas nepalaiko sluoksnių, todėl paveikslėlis bus suplokštintas į vieną sluoksnį. Šį veiksmą galite atšaukti lange „Istorija“.';
  }

  @override
  String get flatten => 'Suplokštinti';

  @override
  String get jpegQualityTitle => 'JPEG kokybė';

  @override
  String get quality => 'Kokybė';

  @override
  String get largerTitle => 'Paveikslėlis didesnis už drobę';

  @override
  String get largerMessage => 'Padidinti drobę, kad jis tilptų?';

  @override
  String get reseed => 'Nauja sėkla';

  @override
  String get rendering => 'Generuojama…';

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
    return 'Atveriamas $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Įrašomas $name…';
  }

  @override
  String savedTo(String name) {
    return 'Įrašyta: $name';
  }

  @override
  String get dropHere => 'Paleiskite, kad atvertumėte';

  @override
  String get dropHint =>
      'Kiekvienas failas atveriamas kaip naujas paveikslėlis';

  @override
  String get imagesList => 'Atverti paveikslėliai';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Rastrinių paveikslėlių rengyklė su sluoksniais. Įrankį pasirinksite paspaudę jo raidę; pakartotinai spaudžiant S, M arba O perjungiami susiję įrankiai. [ ir ] keičia teptuko plotį, X sukeičia spalvas, laikant nuspaustą tarpo klavišą stumiamas rodinys, Ctrl+pelės ratukas keičia mastelį, o F5–F8 rodo arba slepia langus.';

  @override
  String get settingLineStart => 'Pradžia';

  @override
  String get settingLineEnd => 'Pabaiga';

  @override
  String get settingDash => 'Brūkšniai';

  @override
  String get settingSwapSize => 'Sukeisti plotį ir aukštį';

  @override
  String get settingLineStyle => 'Stilius';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plokščias',
      'arrow': 'Rodyklė',
      'arrowFilled': 'Užpildyta rodyklė',
      'rounded': 'Suapvalintas',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Ištisinė',
      'dash': 'Brūkšninė',
      'dashDot': 'Brūkšnys ir taškas',
      'dashDotDot': 'Brūkšnys ir du taškai',
      'dot': 'Taškinė',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Šriftas';

  @override
  String get settingFontSize => 'Dydis';

  @override
  String get textBold => 'Pusjuodis';

  @override
  String get textItalic => 'Kursyvas';

  @override
  String get textUnderline => 'Pabrauktas';

  @override
  String get textStrikeout => 'Perbrauktas';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Kairėje',
      'center': 'Centre',
      'right': 'Dešinėje',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Paveikslėliai';
}
