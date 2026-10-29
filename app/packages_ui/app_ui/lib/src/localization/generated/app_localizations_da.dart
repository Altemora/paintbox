// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Unavngivet $number';
  }

  @override
  String get menuFile => 'Filer';

  @override
  String get menuEdit => 'Rediger';

  @override
  String get menuView => 'Vis';

  @override
  String get menuImage => 'Billede';

  @override
  String get menuLayers => 'Lag';

  @override
  String get menuAdjustments => 'Justeringer';

  @override
  String get menuEffects => 'Effekter';

  @override
  String get menuOpenRecent => 'Åbn seneste';

  @override
  String get menuRecentEmpty => 'Ingen seneste filer';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Indstillinger';

  @override
  String get menuAccent => 'Accentfarve';

  @override
  String get menuLanguage => 'Sprog';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Blå',
      'green': 'Grøn',
      'amber': 'Rav',
      'purple': 'Lilla',
      'red': 'Rød',
      'gray': 'Grå',
      'custom': 'Brugerdefineret…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Brugerdefineret accentfarve';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get themeDark => 'Mørkt';

  @override
  String get themeLight => 'Lyst';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Ny…',
      'open': 'Åbn…',
      'close': 'Luk',
      'save': 'Gem',
      'save_as': 'Gem som…',
      'exit': 'Afslut',
      'undo': 'Fortryd',
      'redo': 'Gentag',
      'cut': 'Klip',
      'copy': 'Kopiér',
      'paste': 'Sæt ind',
      'paste_into_new_layer': 'Sæt ind i nyt lag',
      'paste_into_new_image': 'Sæt ind i nyt billede',
      'erase_selection': 'Slet markeret område',
      'fill_selection': 'Udfyld markering',
      'invert_selection': 'Invertér markering',
      'select_all': 'Markér alt',
      'deselect': 'Fjern markering',
      'zoom_in': 'Zoom ind',
      'zoom_out': 'Zoom ud',
      'zoom_to_window': 'Tilpas til vindue',
      'zoom_to_selection': 'Zoom til markering',
      'actual_size': 'Faktisk størrelse',
      'pixel_grid': 'Pixelgitter',
      'rulers': 'Linealer',
      'crop_to_selection': 'Beskær til markering',
      'resize': 'Tilpas størrelse…',
      'canvas_size': 'Lærredsstørrelse…',
      'flip_horizontal': 'Vend vandret',
      'flip_vertical': 'Vend lodret',
      'rotate90_cw': 'Rotér 90° med uret',
      'rotate90_ccw': 'Rotér 90° mod uret',
      'rotate180': 'Rotér 180°',
      'flatten': 'Flad ud',
      'add_layer': 'Tilføj nyt lag',
      'delete_layer': 'Slet lag',
      'duplicate_layer': 'Duplikér lag',
      'merge_layer_down': 'Flet lag nedad',
      'import_from_file': 'Importér fra fil…',
      'flip_layer_horizontal': 'Vend lag vandret',
      'flip_layer_vertical': 'Vend lag lodret',
      'move_layer_up': 'Flyt lag op',
      'move_layer_down': 'Flyt lag ned',
      'layer_properties': 'Lagegenskaber…',
      'adjust_auto_level': 'Autoniveau',
      'adjust_black_and_white': 'Sort-hvid',
      'adjust_brightness_contrast': 'Lysstyrke / kontrast…',
      'adjust_curves': 'Kurver…',
      'adjust_hue_saturation': 'Nuance / mætning…',
      'adjust_invert_colors': 'Invertér farver',
      'adjust_levels': 'Niveauer…',
      'adjust_posterize': 'Posterisér…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Gentag effekt',
      'effect_oil_painting': 'Oliemaleri…',
      'effect_gaussian_blur': 'Gaussisk sløring…',
      'effect_motion_blur': 'Bevægelsessløring…',
      'effect_pixelate': 'Pixelér…',
      'effect_add_noise': 'Tilføj støj…',
      'effect_median': 'Median…',
      'effect_sharpen': 'Gør skarpere…',
      'effect_edge_detect': 'Kantdetektion…',
      'effect_emboss': 'Prægning…',
      'effect_outline': 'Omrids…',
      'toggle_tools': 'Værktøjer',
      'toggle_history': 'Historik',
      'toggle_layers': 'Lag',
      'toggle_colors': 'Farver',
      'next_image': 'Næste billede',
      'previous_image': 'Forrige billede',
      'help': 'Hjælp',
      'effect_ink_sketch': 'Blækskitse…',
      'effect_pencil_sketch': 'Blyantsskitse…',
      'effect_fragment': 'Fragmentér…',
      'effect_radial_blur': 'Radial sløring…',
      'effect_surface_blur': 'Overfladesløring…',
      'effect_unfocus': 'Ufokusér…',
      'effect_zoom_blur': 'Zoomsløring…',
      'effect_bulge': 'Udbuling…',
      'effect_dents': 'Buler…',
      'effect_frosted_glass': 'Frostet glas…',
      'effect_polar_inversion': 'Polær inversion…',
      'effect_tile_reflection': 'Fliserefleksion…',
      'effect_twist': 'Snoning…',
      'effect_reduce_noise': 'Reducér støj…',
      'effect_glow': 'Glød…',
      'effect_red_eye_removal': 'Fjern røde øjne…',
      'effect_soften_portrait': 'Blødgør portræt…',
      'effect_clouds': 'Skyer…',
      'effect_julia_fractal': 'Julia-fraktal…',
      'effect_mandelbrot_fractal': 'Mandelbrot-fraktal…',
      'effect_relief': 'Relief…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Kunstnerisk',
      'blurs': 'Sløring',
      'distort': 'Forvrængning',
      'noise': 'Støj',
      'photo': 'Foto',
      'stylize': 'Stilisering',
      'render': 'Rendering',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Rektangelmarkering',
      'move_selected_pixels': 'Flyt markerede pixels',
      'lasso_select': 'Lassomarkering',
      'move_selection': 'Flyt markering',
      'ellipse_select': 'Ellipsemarkering',
      'zoom': 'Zoom',
      'magic_wand': 'Tryllestav',
      'pan': 'Hånd',
      'paint_bucket': 'Malerspand',
      'gradient': 'Farveovergang',
      'paintbrush': 'Pensel',
      'eraser': 'Viskelæder',
      'pencil': 'Blyant',
      'color_picker': 'Pipette',
      'clone_stamp': 'Kloningsstempel',
      'recolor': 'Omfarvning',
      'text': 'Tekst',
      'line_curve': 'Linje / kurve',
      'rectangle': 'Rektangel',
      'rounded_rectangle': 'Afrundet rektangel',
      'ellipse': 'Ellipse',
      'freeform_shape': 'Frihåndsfigur',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Træk for at markere et rektangel. Hold Shift nede for at få et kvadrat.',
      'move_selected_pixels': 'Træk markeringen for at flytte den. Træk med højre knap for at rotere den, og træk i håndtagene for at skalere den. Ctrl efterlader en kopi; piletasterne flytter den trinvis.',
      'lasso_select': 'Træk for at tegne omridset af en markering.',
      'move_selection': 'Træk markeringens omrids for at flytte det. Selve pixelene bliver, hvor de er.',
      'ellipse_select': 'Træk for at markere en ellipse. Hold Shift nede for at få en cirkel.',
      'zoom': 'Venstreklik for at zoome ind, højreklik for at zoome ud, eller træk en ramme for at zoome til den.',
      'magic_wand': 'Klik på en farve for at markere området omkring den. Hold Shift nede for at markere farven i hele billedet.',
      'pan': 'Træk for at flytte visningen.',
      'paint_bucket': 'Venstreklik udfylder med den primære farve, højreklik med den sekundære.',
      'gradient': 'Træk for at tegne en farveovergang. Træk i håndtagene for at justere den; tryk på Enter for at afslutte.',
      'paintbrush': 'Venstre knap maler med den primære farve, højre knap med den sekundære.',
      'eraser': 'Træk for at viske ud til gennemsigtighed.',
      'pencil': 'Tegner linjer på én pixel uden kantudjævning.',
      'color_picker':
          'Venstreklik henter den primære farve, højreklik den sekundære.',
      'clone_stamp': 'Ctrl+klik for at angive kilden, og træk derefter for at male fra den.',
      'recolor': 'Erstatter den sekundære farve med den primære, hvor du maler. Ctrl+klik henter en farve.',
      'text': 'Klik for at placere markøren, og skriv derefter. Træk i håndtaget eller træk med højre knap for at flytte teksten; tryk på Esc for at afslutte.',
      'line_curve': 'Træk for at tegne en linje. Træk i håndtagene for at bøje den; tryk på Enter for at afslutte.',
      'rectangle': 'Træk for at tegne et rektangel. Hold Shift nede for at få et kvadrat.',
      'rounded_rectangle': 'Træk for at tegne et afrundet rektangel. Hold Shift nede for at få et kvadrat.',
      'ellipse':
          'Træk for at tegne en ellipse. Hold Shift nede for at få en cirkel.',
      'freeform_shape': 'Træk for at tegne en lukket frihåndsfigur.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Radius',
      'angle': 'Vinkel',
      'distance': 'Afstand',
      'centered': 'Centreret',
      'amount': 'Mængde',
      'intensity': 'Intensitet',
      'saturation': 'Mætning',
      'coverage': 'Dækning',
      'seed': 'Startværdi',
      'percentile': 'Percentil',
      'cell_size': 'Cellestørrelse',
      'brush_size': 'Penselstørrelse',
      'coarseness': 'Grovhed',
      'thickness': 'Tykkelse',
      'brightness': 'Lysstyrke',
      'contrast': 'Kontrast',
      'hue': 'Nuance',
      'lightness': 'Lyshed',
      'red': 'Rød',
      'green': 'Grøn',
      'blue': 'Blå',
      'input_low': 'Input lav',
      'input_high': 'Input høj',
      'output_low': 'Output lav',
      'output_high': 'Output høj',
      'gamma': 'Gamma',
      'ink_outline': 'Blækomrids',
      'coloring': 'Farvelægning',
      'tip_size': 'Blyantspidsens størrelse',
      'color_range': 'Farveområde',
      'fragments': 'Fragmenter',
      'rotation': 'Rotation',
      'offset_x': 'Forskydning X',
      'offset_y': 'Forskydning Y',
      'quality': 'Kvalitet',
      'threshold': 'Tærskel',
      'scale': 'Skala',
      'refraction': 'Lysbrydning',
      'roughness': 'Ruhed',
      'tension': 'Spænding',
      'max_scatter': 'Største spredning',
      'min_scatter': 'Mindste spredning',
      'samples': 'Antal samples',
      'edge_behavior': 'Kantadfærd',
      'tile_size': 'Flisestørrelse',
      'curvature': 'Krumning',
      'size': 'Størrelse',
      'strength': 'Styrke',
      'tolerance': 'Tolerance',
      'softness': 'Blødhed',
      'lighting': 'Belysning',
      'warmth': 'Varme',
      'power': 'Kraft',
      'blend_mode': 'Blandingstilstand',
      'factor': 'Faktor',
      'zoom': 'Zoom',
      'invert_colors': 'Invertér farver',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Multiplikation',
      'additive': 'Addition',
      'colorBurn': 'Farvebrænding',
      'colorDodge': 'Farveundvigelse',
      'reflect': 'Refleksion',
      'glow': 'Glød',
      'overlay': 'Overlejring',
      'difference': 'Forskel',
      'negation': 'Negation',
      'lighten': 'Lysere',
      'darken': 'Mørkere',
      'screen': 'Skærm',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Der er ikke nok hukommelse til billedet.',
      'invalid_size': 'Billedstørrelsen er ugyldig.',
      'layer_index': 'Laget findes ikke.',
      'last_layer': 'Det sidste lag kan ikke slettes.',
      'no_layer_below': 'Der er intet lag nedenunder at flette med.',
      'edit_in_progress': 'Afslut den igangværende handling først.',
      'no_edit': 'Der er ingen igangværende handling at afslutte.',
      'no_selection': 'Intet er markeret.',
      'nothing_lifted': 'Der er ingen løftede pixels.',
      'invalid_parameter': 'Værdien er uden for det tilladte interval.',
      'io': 'Filen kunne ikke læses eller skrives.',
      'decode': 'Billedet kunne ikke læses.',
      'encode': 'Billedet kunne ikke skrives.',
      'open_raster': 'OpenRaster-filen er beskadiget.',
      'palette': 'Paletfilen er beskadiget.',
      'cancelled': 'Beregningen blev annulleret.',
      'other': 'Noget gik galt.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Filen kunne ikke læses eller skrives.';

  @override
  String get failureInvalidData => 'Dataene kunne ikke læses.';

  @override
  String get failureUnknown => 'Der opstod en uventet fejl.';

  @override
  String get panelTools => 'Værktøjer';

  @override
  String get panelHistory => 'Historik';

  @override
  String get panelLayers => 'Lag';

  @override
  String get panelColors => 'Farver';

  @override
  String get panelHide => 'Skjul';

  @override
  String get colorsPrimary => 'Primær';

  @override
  String get colorsSecondary => 'Sekundær';

  @override
  String get colorsPrimaryHint =>
      'Primær farve: venstre museknap maler med den';

  @override
  String get colorsSecondaryHint =>
      'Sekundær farve: højre museknap maler med den';

  @override
  String get colorsSwap => 'Byt farver (X)';

  @override
  String get colorsReset => 'Nulstil til sort og hvid';

  @override
  String get colorsMore => 'Mere';

  @override
  String get colorsLess => 'Mindre';

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
      'Venstreklik angiver den primære farve, højreklik den sekundære';

  @override
  String get settingWidth => 'Bredde';

  @override
  String get settingHardness => 'Hårdhed';

  @override
  String get settingAntialias => 'Kantudjævning';

  @override
  String get settingAlphaBlending => 'Alfablanding';

  @override
  String get settingTolerance => 'Tolerance';

  @override
  String get settingFloodMode => 'Udfyldningstilstand';

  @override
  String get floodLocal => 'Sammenhængende';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Markeringstilstand';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Erstat',
      'union': 'Tilføj',
      'exclude': 'Fratræk',
      'xor': 'Xor',
      'intersect': 'Fællesmængde',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Markeringsstørrelse';

  @override
  String get drawNormal => 'Normal';

  @override
  String get drawFixedRatio => 'Fast forhold';

  @override
  String get drawFixedSize => 'Fast størrelse';

  @override
  String get settingResampling => 'Omsampling';

  @override
  String get resamplingNearest => 'Nærmeste nabo';

  @override
  String get resamplingBilinear => 'Bilineær';

  @override
  String get settingGradient => 'Type';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineær',
      'linearReflected': 'Lineær spejlet',
      'diamond': 'Diamant',
      'radial': 'Radial',
      'conical': 'Konisk',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Farve';

  @override
  String get gradientTransparency => 'Gennemsigtighed';

  @override
  String get settingShape => 'Figurstil';

  @override
  String get shapeOutline => 'Omrids';

  @override
  String get shapeInterior => 'Udfyldning';

  @override
  String get shapeBoth => 'Omrids og udfyldning';

  @override
  String get settingAfterPick => 'Efter farvevalg';

  @override
  String get pickStay => 'Behold dette værktøj';

  @override
  String get pickPrevious => 'Skift til det forrige værktøj';

  @override
  String get pickPencil => 'Skift til Blyant';

  @override
  String get settingNone => 'Dette værktøj har ingen indstillinger.';

  @override
  String toolUnavailable(String name) {
    return 'Værktøjet »$name« er ikke tilgængeligt endnu';
  }

  @override
  String get historyFirst => 'Gå til første trin';

  @override
  String get historyUndo => 'Fortryd';

  @override
  String get historyRedo => 'Gentag';

  @override
  String get historyLast => 'Gå til sidste trin';

  @override
  String get historyNewImage => 'Nyt billede';

  @override
  String get historyOpenImage => 'Åbn billede';

  @override
  String get layerVisible => 'Vis eller skjul laget';

  @override
  String get layerBackground => 'Baggrund';

  @override
  String get layerName => 'Navn';

  @override
  String get layerOpacity => 'Uigennemsigtighed';

  @override
  String get layerBlendMode => 'Blandingstilstand';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get dontSave => 'Gem ikke';

  @override
  String get keepCanvas => 'Behold lærredet';

  @override
  String get expandCanvas => 'Udvid lærredet';

  @override
  String get width => 'Bredde';

  @override
  String get height => 'Højde';

  @override
  String get pixels => 'pixels';

  @override
  String get newImageTitle => 'Nyt billede';

  @override
  String get resizeTitle => 'Tilpas billedstørrelse';

  @override
  String get canvasSizeTitle => 'Lærredsstørrelse';

  @override
  String get keepRatio => 'Bevar højde-bredde-forhold';

  @override
  String get anchor => 'Forankring';

  @override
  String sizeTooLarge(int max) {
    return 'Billedet er for stort: grænsen er $max megapixel.';
  }

  @override
  String get unsavedTitle => 'Gem ændringer?';

  @override
  String unsavedMessage(String name) {
    return '»$name« har ændringer, der ikke er gemt.';
  }

  @override
  String get flattenTitle => 'Flad billedet ud?';

  @override
  String flattenMessage(String format) {
    return 'Formatet $format kan ikke bevare lag, så billedet bliver fladet ud til ét lag. Du kan fortryde dette i vinduet Historik.';
  }

  @override
  String get flatten => 'Flad ud';

  @override
  String get jpegQualityTitle => 'JPEG-kvalitet';

  @override
  String get quality => 'Kvalitet';

  @override
  String get largerTitle => 'Billedet er større end lærredet';

  @override
  String get largerMessage => 'Udvid lærredet, så billedet kan være der?';

  @override
  String get reseed => 'Ny startværdi';

  @override
  String get rendering => 'Beregner…';

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
    return 'Åbner $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Gemmer $name…';
  }

  @override
  String savedTo(String name) {
    return 'Gemt: $name';
  }

  @override
  String get dropHere => 'Slip for at åbne';

  @override
  String get dropHint => 'Hver fil åbnes som et nyt billede';

  @override
  String get imagesList => 'Åbne billeder';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Et program til redigering af rasterbilleder med lag. Tryk på et bogstav for at vælge et værktøj; trykker du på S, M eller O igen, skifter du mellem de beslægtede værktøjer. [ og ] ændrer penselbredden, X bytter farverne, når du holder mellemrumstasten nede, panorerer du visningen, Ctrl+musehjulet zoomer, og F5–F8 viser eller skjuler vinduerne.';

  @override
  String get aboutLegal =>
      '© 2026 Paintbox\' forfattere. Paintbox er fri software: du må videregive og ændre det under betingelserne i GNU General Public License, version 3 eller nyere. Programmet leveres uden nogen form for garanti.';

  @override
  String get licenses => 'Licenser';

  @override
  String get settingLineStart => 'Start';

  @override
  String get settingLineEnd => 'Slut';

  @override
  String get settingDash => 'Stregmønster';

  @override
  String get settingSwapSize => 'Byt bredde og højde';

  @override
  String get settingLineStyle => 'Stil';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Flad',
      'arrow': 'Pil',
      'arrowFilled': 'Udfyldt pil',
      'rounded': 'Afrundet',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Optrukket',
      'dash': 'Streg',
      'dashDot': 'Streg-prik',
      'dashDotDot': 'Streg-prik-prik',
      'dot': 'Prik',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Skrifttype';

  @override
  String get settingFontSize => 'Størrelse';

  @override
  String get textBold => 'Fed';

  @override
  String get textItalic => 'Kursiv';

  @override
  String get textUnderline => 'Understreget';

  @override
  String get textStrikeout => 'Gennemstreget';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Venstre',
      'center': 'Centreret',
      'right': 'Højre',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Billeder';
}
