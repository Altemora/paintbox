// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Fără titlu $number';
  }

  @override
  String get menuFile => 'Fișier';

  @override
  String get menuEdit => 'Editare';

  @override
  String get menuView => 'Vizualizare';

  @override
  String get menuImage => 'Imagine';

  @override
  String get menuLayers => 'Straturi';

  @override
  String get menuAdjustments => 'Ajustări';

  @override
  String get menuEffects => 'Efecte';

  @override
  String get menuOpenRecent => 'Deschide recente';

  @override
  String get menuRecentEmpty => 'Niciun fișier recent';

  @override
  String get menuTheme => 'Temă';

  @override
  String get menuSettings => 'Setări';

  @override
  String get menuAccent => 'Culoare de accent';

  @override
  String get menuLanguage => 'Limbă';

  @override
  String get languageSystem => 'Implicit din sistem';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Albastru',
      'green': 'Verde',
      'amber': 'Chihlimbar',
      'purple': 'Violet',
      'red': 'Roșu',
      'gray': 'Gri',
      'custom': 'Personalizată…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Culoare de accent personalizată';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Implicit din sistem';

  @override
  String get themeDark => 'Întunecată';

  @override
  String get themeLight => 'Luminoasă';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nou…',
      'open': 'Deschide…',
      'close': 'Închide',
      'save': 'Salvează',
      'save_as': 'Salvează ca…',
      'exit': 'Ieșire',
      'undo': 'Anulează',
      'redo': 'Refă',
      'cut': 'Taie',
      'copy': 'Copiază',
      'paste': 'Lipește',
      'paste_into_new_layer': 'Lipește într-un strat nou',
      'paste_into_new_image': 'Lipește într-o imagine nouă',
      'erase_selection': 'Șterge selecția',
      'fill_selection': 'Umple selecția',
      'invert_selection': 'Inversează selecția',
      'select_all': 'Selectează tot',
      'deselect': 'Deselectează',
      'zoom_in': 'Mărește',
      'zoom_out': 'Micșorează',
      'zoom_to_window': 'Potrivește în fereastră',
      'zoom_to_selection': 'Potrivește la selecție',
      'actual_size': 'Dimensiune reală',
      'pixel_grid': 'Grilă de pixeli',
      'rulers': 'Rigle',
      'crop_to_selection': 'Decupează la selecție',
      'resize': 'Redimensionează imaginea…',
      'canvas_size': 'Dimensiunea pânzei…',
      'flip_horizontal': 'Oglindește orizontal',
      'flip_vertical': 'Oglindește vertical',
      'rotate90_cw': 'Rotește cu 90° în sens orar',
      'rotate90_ccw': 'Rotește cu 90° în sens antiorar',
      'rotate180': 'Rotește cu 180°',
      'flatten': 'Aplatizează',
      'add_layer': 'Adaugă un strat nou',
      'delete_layer': 'Șterge stratul',
      'duplicate_layer': 'Duplică stratul',
      'merge_layer_down': 'Îmbină cu stratul inferior',
      'import_from_file': 'Importă din fișier…',
      'flip_layer_horizontal': 'Oglindește stratul orizontal',
      'flip_layer_vertical': 'Oglindește stratul vertical',
      'move_layer_up': 'Mută stratul mai sus',
      'move_layer_down': 'Mută stratul mai jos',
      'layer_properties': 'Proprietățile stratului…',
      'adjust_auto_level': 'Niveluri automate',
      'adjust_black_and_white': 'Alb-negru',
      'adjust_brightness_contrast': 'Luminozitate / Contrast…',
      'adjust_curves': 'Curbe…',
      'adjust_hue_saturation': 'Nuanță / Saturație…',
      'adjust_invert_colors': 'Inversează culorile',
      'adjust_levels': 'Niveluri…',
      'adjust_posterize': 'Posterizare…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Repetă efectul',
      'effect_oil_painting': 'Pictură în ulei…',
      'effect_gaussian_blur': 'Estompare gaussiană…',
      'effect_motion_blur': 'Estompare de mișcare…',
      'effect_pixelate': 'Pixelare…',
      'effect_add_noise': 'Adăugare zgomot…',
      'effect_median': 'Mediană…',
      'effect_sharpen': 'Accentuare claritate…',
      'effect_edge_detect': 'Detectare margini…',
      'effect_emboss': 'Gravare în relief…',
      'effect_outline': 'Contur…',
      'toggle_tools': 'Instrumente',
      'toggle_history': 'Istoric',
      'toggle_layers': 'Straturi',
      'toggle_colors': 'Culori',
      'next_image': 'Imaginea următoare',
      'previous_image': 'Imaginea anterioară',
      'help': 'Ajutor',
      'effect_ink_sketch': 'Schiță în cerneală…',
      'effect_pencil_sketch': 'Schiță în creion…',
      'effect_fragment': 'Fragmentare…',
      'effect_radial_blur': 'Estompare radială…',
      'effect_surface_blur': 'Estompare de suprafață…',
      'effect_unfocus': 'Defocalizare…',
      'effect_zoom_blur': 'Estompare prin zoom…',
      'effect_bulge': 'Bombare…',
      'effect_dents': 'Adâncituri…',
      'effect_frosted_glass': 'Sticlă mată…',
      'effect_polar_inversion': 'Inversiune polară…',
      'effect_tile_reflection': 'Reflexie în mozaic…',
      'effect_twist': 'Răsucire…',
      'effect_reduce_noise': 'Reducere zgomot…',
      'effect_glow': 'Strălucire…',
      'effect_red_eye_removal': 'Eliminare ochi roșii…',
      'effect_soften_portrait': 'Estompare portret…',
      'effect_clouds': 'Nori…',
      'effect_julia_fractal': 'Fractal Julia…',
      'effect_mandelbrot_fractal': 'Fractal Mandelbrot…',
      'effect_relief': 'Relief…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artistice',
      'blurs': 'Estompări',
      'distort': 'Distorsionare',
      'noise': 'Zgomot',
      'photo': 'Foto',
      'stylize': 'Stilizare',
      'render': 'Randare',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Selecție dreptunghiulară',
      'move_selected_pixels': 'Mutare pixeli selectați',
      'lasso_select': 'Selecție lasou',
      'move_selection': 'Mutare selecție',
      'ellipse_select': 'Selecție eliptică',
      'zoom': 'Zoom',
      'magic_wand': 'Baghetă magică',
      'pan': 'Mână',
      'paint_bucket': 'Găleată de vopsea',
      'gradient': 'Gradient',
      'paintbrush': 'Pensulă',
      'eraser': 'Radieră',
      'pencil': 'Creion',
      'color_picker': 'Pipetă',
      'clone_stamp': 'Ștampilă de clonare',
      'recolor': 'Recolorare',
      'text': 'Text',
      'line_curve': 'Linie / curbă',
      'rectangle': 'Dreptunghi',
      'rounded_rectangle': 'Dreptunghi rotunjit',
      'ellipse': 'Elipsă',
      'freeform_shape': 'Formă liberă',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Trageți pentru a selecta un dreptunghi. Țineți apăsat Shift pentru a obține un pătrat.',
      'move_selected_pixels': 'Trageți selecția pentru a o muta. Trageți cu butonul drept pentru a o roti sau trageți de mânere pentru a o scala. Ctrl lasă o copie; tastele săgeți o deplasează puțin.',
      'lasso_select': 'Trageți pentru a desena conturul unei selecții.',
      'move_selection':
          'Trageți conturul selecției pentru a-l muta. Pixelii rămân pe loc.',
      'ellipse_select': 'Trageți pentru a selecta o elipsă. Țineți apăsat Shift pentru a obține un cerc.',
      'zoom': 'Faceți clic stânga pentru a mări, clic dreapta pentru a micșora sau trageți un chenar pentru a mări zona respectivă.',
      'magic_wand': 'Faceți clic pe o culoare pentru a selecta zona din jurul ei. Țineți apăsat Shift pentru a o selecta în toată imaginea.',
      'pan': 'Trageți pentru a muta vizualizarea.',
      'paint_bucket': 'Clicul stânga umple cu culoarea primară, clicul dreapta cu cea secundară.',
      'gradient': 'Trageți pentru a desena un gradient. Trageți de mânere pentru a-l ajusta; apăsați Enter pentru a termina.',
      'paintbrush': 'Butonul stâng pictează cu culoarea primară, butonul drept cu cea secundară.',
      'eraser': 'Trageți pentru a șterge până la transparență.',
      'pencil': 'Desenează linii de un pixel fără antialiasing.',
      'color_picker': 'Clicul stânga preia culoarea primară, clicul dreapta pe cea secundară.',
      'clone_stamp': 'Faceți Ctrl+clic pentru a seta sursa, apoi trageți pentru a picta din ea.',
      'recolor': 'Înlocuiește culoarea secundară cu cea primară acolo unde pictați. Ctrl+clic preia o culoare.',
      'text': 'Faceți clic pentru a plasa cursorul, apoi tastați. Trageți de mâner sau trageți cu butonul drept pentru a muta textul; apăsați Esc pentru a termina.',
      'line_curve': 'Trageți pentru a desena o linie. Trageți de mânere pentru a o curba; apăsați Enter pentru a termina.',
      'rectangle': 'Trageți pentru a desena un dreptunghi. Țineți apăsat Shift pentru a obține un pătrat.',
      'rounded_rectangle': 'Trageți pentru a desena un dreptunghi rotunjit. Țineți apăsat Shift pentru a obține un pătrat.',
      'ellipse': 'Trageți pentru a desena o elipsă. Țineți apăsat Shift pentru a obține un cerc.',
      'freeform_shape': 'Trageți pentru a desena o formă liberă închisă.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Rază',
      'angle': 'Unghi',
      'distance': 'Distanță',
      'centered': 'Centrat',
      'amount': 'Cantitate',
      'intensity': 'Intensitate',
      'saturation': 'Saturație',
      'coverage': 'Acoperire',
      'seed': 'Sămânță',
      'percentile': 'Percentilă',
      'cell_size': 'Dimensiunea celulei',
      'brush_size': 'Dimensiunea pensulei',
      'coarseness': 'Asprime',
      'thickness': 'Grosime',
      'brightness': 'Luminozitate',
      'contrast': 'Contrast',
      'hue': 'Nuanță',
      'lightness': 'Claritate',
      'red': 'Roșu',
      'green': 'Verde',
      'blue': 'Albastru',
      'input_low': 'Intrare minimă',
      'input_high': 'Intrare maximă',
      'output_low': 'Ieșire minimă',
      'output_high': 'Ieșire maximă',
      'gamma': 'Gama',
      'ink_outline': 'Contur în cerneală',
      'coloring': 'Colorare',
      'tip_size': 'Dimensiunea vârfului creionului',
      'color_range': 'Interval de culori',
      'fragments': 'Fragmente',
      'rotation': 'Rotație',
      'offset_x': 'Decalaj X',
      'offset_y': 'Decalaj Y',
      'quality': 'Calitate',
      'threshold': 'Prag',
      'scale': 'Scară',
      'refraction': 'Refracție',
      'roughness': 'Rugozitate',
      'tension': 'Tensiune',
      'max_scatter': 'Dispersie maximă',
      'min_scatter': 'Dispersie minimă',
      'samples': 'Eșantioane',
      'edge_behavior': 'Comportament la margini',
      'tile_size': 'Dimensiunea plăcii',
      'curvature': 'Curbură',
      'size': 'Dimensiune',
      'strength': 'Forță',
      'tolerance': 'Toleranță',
      'softness': 'Moliciune',
      'lighting': 'Iluminare',
      'warmth': 'Căldură',
      'power': 'Putere',
      'blend_mode': 'Mod de amestecare',
      'factor': 'Factor',
      'zoom': 'Zoom',
      'invert_colors': 'Inversează culorile',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Multiplicare',
      'additive': 'Aditiv',
      'colorBurn': 'Ardere culoare',
      'colorDodge': 'Eschivare culoare',
      'reflect': 'Reflexie',
      'glow': 'Strălucire',
      'overlay': 'Suprapunere',
      'difference': 'Diferență',
      'negation': 'Negație',
      'lighten': 'Luminare',
      'darken': 'Întunecare',
      'screen': 'Ecran',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Nu există suficientă memorie pentru imagine.',
      'invalid_size': 'Dimensiunea imaginii nu este validă.',
      'layer_index': 'Acest strat nu există.',
      'last_layer': 'Ultimul strat nu poate fi șters.',
      'no_layer_below':
          'Nu există niciun strat dedesubt cu care să fie îmbinat.',
      'edit_in_progress': 'Finalizați mai întâi operația în curs.',
      'no_edit': 'Nu există nicio operație în curs de finalizat.',
      'no_selection': 'Nu este nimic selectat.',
      'nothing_lifted': 'Nu există pixeli ridicați.',
      'invalid_parameter': 'Valoarea este în afara intervalului permis.',
      'io': 'Fișierul nu a putut fi citit sau scris.',
      'decode': 'Imaginea nu a putut fi citită.',
      'encode': 'Imaginea nu a putut fi scrisă.',
      'open_raster': 'Fișierul OpenRaster este deteriorat.',
      'palette': 'Fișierul paletei este deteriorat.',
      'cancelled': 'Calculul a fost anulat.',
      'other': 'A apărut o eroare.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Fișierul nu a putut fi citit sau scris.';

  @override
  String get failureInvalidData => 'Datele nu au putut fi citite.';

  @override
  String get failureUnknown => 'A apărut o eroare neașteptată.';

  @override
  String get panelTools => 'Instrumente';

  @override
  String get panelHistory => 'Istoric';

  @override
  String get panelLayers => 'Straturi';

  @override
  String get panelColors => 'Culori';

  @override
  String get panelHide => 'Ascunde';

  @override
  String get colorsPrimary => 'Primară';

  @override
  String get colorsSecondary => 'Secundară';

  @override
  String get colorsPrimaryHint =>
      'Culoarea primară: butonul stâng al mouse-ului pictează cu ea';

  @override
  String get colorsSecondaryHint =>
      'Culoarea secundară: butonul drept al mouse-ului pictează cu ea';

  @override
  String get colorsSwap => 'Schimbă culorile între ele (X)';

  @override
  String get colorsReset => 'Resetează la negru și alb';

  @override
  String get colorsMore => 'Mai mult';

  @override
  String get colorsLess => 'Mai puțin';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Alfa';

  @override
  String get colorsHue => 'N';

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
      'Clicul stânga setează culoarea primară, clicul dreapta pe cea secundară';

  @override
  String get settingWidth => 'Lățime';

  @override
  String get settingHardness => 'Duritate';

  @override
  String get settingAntialias => 'Antialiasing';

  @override
  String get settingAlphaBlending => 'Amestecare alfa';

  @override
  String get settingTolerance => 'Toleranță';

  @override
  String get settingFloodMode => 'Mod de umplere';

  @override
  String get floodLocal => 'Contiguu';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Mod de selecție';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Înlocuiește',
      'union': 'Unește',
      'exclude': 'Exclude',
      'xor': 'Xor',
      'intersect': 'Intersectează',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Dimensiunea selecției';

  @override
  String get drawNormal => 'Liberă';

  @override
  String get drawFixedRatio => 'Proporții fixe';

  @override
  String get drawFixedSize => 'Dimensiune fixă';

  @override
  String get settingResampling => 'Reeșantionare';

  @override
  String get resamplingNearest => 'Cel mai apropiat vecin';

  @override
  String get resamplingBilinear => 'Biliniară';

  @override
  String get settingGradient => 'Tip';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Liniar',
      'linearReflected': 'Liniar reflectat',
      'diamond': 'Romb',
      'radial': 'Radial',
      'conical': 'Conic',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Culoare';

  @override
  String get gradientTransparency => 'Transparență';

  @override
  String get settingShape => 'Stilul formei';

  @override
  String get shapeOutline => 'Contur';

  @override
  String get shapeInterior => 'Umplere';

  @override
  String get shapeBoth => 'Contur și umplere';

  @override
  String get settingAfterPick => 'După preluarea culorii';

  @override
  String get pickStay => 'Păstrează acest instrument';

  @override
  String get pickPrevious => 'Revino la instrumentul anterior';

  @override
  String get pickPencil => 'Treci la Creion';

  @override
  String get settingNone => 'Acest instrument nu are setări.';

  @override
  String toolUnavailable(String name) {
    return 'Instrumentul „$name” nu este încă disponibil';
  }

  @override
  String get historyFirst => 'Salt la primul pas';

  @override
  String get historyUndo => 'Anulează';

  @override
  String get historyRedo => 'Refă';

  @override
  String get historyLast => 'Salt la ultimul pas';

  @override
  String get historyNewImage => 'Imagine nouă';

  @override
  String get historyOpenImage => 'Deschidere imagine';

  @override
  String get layerVisible => 'Afișează sau ascunde stratul';

  @override
  String get layerBackground => 'Fundal';

  @override
  String get layerName => 'Nume';

  @override
  String get layerOpacity => 'Opacitate';

  @override
  String get layerBlendMode => 'Mod de amestecare';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anulează';

  @override
  String get save => 'Salvează';

  @override
  String get dontSave => 'Nu salva';

  @override
  String get keepCanvas => 'Păstrează pânza';

  @override
  String get expandCanvas => 'Extinde pânza';

  @override
  String get width => 'Lățime';

  @override
  String get height => 'Înălțime';

  @override
  String get pixels => 'pixeli';

  @override
  String get newImageTitle => 'Imagine nouă';

  @override
  String get resizeTitle => 'Redimensionare imagine';

  @override
  String get canvasSizeTitle => 'Dimensiunea pânzei';

  @override
  String get keepRatio => 'Păstrează raportul de aspect';

  @override
  String get anchor => 'Ancoră';

  @override
  String sizeTooLarge(int max) {
    return 'Imaginea este prea mare: limita este de $max megapixeli.';
  }

  @override
  String get unsavedTitle => 'Salvați modificările?';

  @override
  String unsavedMessage(String name) {
    return '„$name” are modificări nesalvate.';
  }

  @override
  String get flattenTitle => 'Aplatizați imaginea?';

  @override
  String flattenMessage(String format) {
    return 'Formatul $format nu păstrează straturile, așa că imaginea va fi aplatizată într-un singur strat. Puteți anula această operație în fereastra Istoric.';
  }

  @override
  String get flatten => 'Aplatizează';

  @override
  String get jpegQualityTitle => 'Calitate JPEG';

  @override
  String get quality => 'Calitate';

  @override
  String get largerTitle => 'Imaginea este mai mare decât pânza';

  @override
  String get largerMessage => 'Extindeți pânza pentru a o cuprinde?';

  @override
  String get reseed => 'Sămânță nouă';

  @override
  String get rendering => 'Randare…';

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
    return 'Se deschide $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Se salvează $name…';
  }

  @override
  String savedTo(String name) {
    return 'Salvat: $name';
  }

  @override
  String get dropHere => 'Plasați aici pentru a deschide';

  @override
  String get dropHint => 'Fiecare fișier se deschide ca imagine nouă';

  @override
  String get imagesList => 'Imagini deschise';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Un editor de imagini raster cu straturi. Apăsați o literă pentru a alege un instrument; apăsând din nou S, M sau O treceți prin instrumentele înrudite. [ și ] schimbă lățimea pensulei, X schimbă culorile între ele, ținând apăsată tasta Spațiu deplasați vizualizarea, Ctrl+rotița mouse-ului modifică zoomul, iar F5–F8 afișează sau ascund ferestrele.';

  @override
  String get aboutLegal =>
      '© 2026 autorii Paintbox. Paintbox este software liber: îl puteți redistribui și modifica în condițiile GNU General Public License, versiunea 3 sau ulterioară. Este oferit fără nicio garanție.';

  @override
  String get licenses => 'Licențe';

  @override
  String get settingLineStart => 'Început';

  @override
  String get settingLineEnd => 'Sfârșit';

  @override
  String get settingDash => 'Linie întreruptă';

  @override
  String get settingSwapSize => 'Schimbă lățimea cu înălțimea';

  @override
  String get settingLineStyle => 'Stil';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plat',
      'arrow': 'Săgeată',
      'arrowFilled': 'Săgeată plină',
      'rounded': 'Rotunjit',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Continuă',
      'dash': 'Liniuță',
      'dashDot': 'Liniuță-punct',
      'dashDotDot': 'Liniuță-punct-punct',
      'dot': 'Punctată',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Font';

  @override
  String get settingFontSize => 'Dimensiune';

  @override
  String get textBold => 'Aldin';

  @override
  String get textItalic => 'Cursiv';

  @override
  String get textUnderline => 'Subliniat';

  @override
  String get textStrikeout => 'Tăiat';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Stânga',
      'center': 'Centru',
      'right': 'Dreapta',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Imagini';
}
