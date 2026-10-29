// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Nimetu $number';
  }

  @override
  String get menuFile => 'Fail';

  @override
  String get menuEdit => 'Redigeeri';

  @override
  String get menuView => 'Vaade';

  @override
  String get menuImage => 'Pilt';

  @override
  String get menuLayers => 'Kihid';

  @override
  String get menuAdjustments => 'Kohandused';

  @override
  String get menuEffects => 'Efektid';

  @override
  String get menuOpenRecent => 'Viimati avatud';

  @override
  String get menuRecentEmpty => 'Viimati avatud faile pole';

  @override
  String get menuTheme => 'Teema';

  @override
  String get menuSettings => 'Sätted';

  @override
  String get menuAccent => 'Rõhuvärv';

  @override
  String get menuLanguage => 'Keel';

  @override
  String get languageSystem => 'Süsteemi vaikesäte';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Sinine',
      'green': 'Roheline',
      'amber': 'Merevaigukollane',
      'purple': 'Lilla',
      'red': 'Punane',
      'gray': 'Hall',
      'custom': 'Kohandatud…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Kohandatud rõhuvärv';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Süsteemi vaikesäte';

  @override
  String get themeDark => 'Tume';

  @override
  String get themeLight => 'Hele';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Uus…',
      'open': 'Ava…',
      'close': 'Sulge',
      'save': 'Salvesta',
      'save_as': 'Salvesta nimega…',
      'exit': 'Välju',
      'undo': 'Võta tagasi',
      'redo': 'Tee uuesti',
      'cut': 'Lõika',
      'copy': 'Kopeeri',
      'paste': 'Kleebi',
      'paste_into_new_layer': 'Kleebi uude kihti',
      'paste_into_new_image': 'Kleebi uude pilti',
      'erase_selection': 'Kustuta valitud ala',
      'fill_selection': 'Täida valik',
      'invert_selection': 'Pööra valik ümber',
      'select_all': 'Vali kõik',
      'deselect': 'Tühista valik',
      'zoom_in': 'Suurenda',
      'zoom_out': 'Vähenda',
      'zoom_to_window': 'Sobita aknaga',
      'zoom_to_selection': 'Sobita valikuga',
      'actual_size': 'Tegelik suurus',
      'pixel_grid': 'Pikslivõrk',
      'rulers': 'Joonlauad',
      'crop_to_selection': 'Kärbi valikuni',
      'resize': 'Muuda suurust…',
      'canvas_size': 'Lõuendi suurus…',
      'flip_horizontal': 'Peegelda horisontaalselt',
      'flip_vertical': 'Peegelda vertikaalselt',
      'rotate90_cw': 'Pööra 90° päripäeva',
      'rotate90_ccw': 'Pööra 90° vastupäeva',
      'rotate180': 'Pööra 180°',
      'flatten': 'Lamenda',
      'add_layer': 'Lisa uus kiht',
      'delete_layer': 'Kustuta kiht',
      'duplicate_layer': 'Dubleeri kiht',
      'merge_layer_down': 'Ühenda alumise kihiga',
      'import_from_file': 'Impordi failist…',
      'flip_layer_horizontal': 'Peegelda kiht horisontaalselt',
      'flip_layer_vertical': 'Peegelda kiht vertikaalselt',
      'move_layer_up': 'Tõsta kiht üles',
      'move_layer_down': 'Langeta kiht alla',
      'layer_properties': 'Kihi omadused…',
      'adjust_auto_level': 'Automaatsed tasemed',
      'adjust_black_and_white': 'Mustvalge',
      'adjust_brightness_contrast': 'Eredus / kontrast…',
      'adjust_curves': 'Kõverad…',
      'adjust_hue_saturation': 'Toon / küllastus…',
      'adjust_invert_colors': 'Pööra värvid ümber',
      'adjust_levels': 'Tasemed…',
      'adjust_posterize': 'Posterdamine…',
      'adjust_sepia': 'Seepia',
      'repeat_effect': 'Korda efekti',
      'effect_oil_painting': 'Õlimaal…',
      'effect_gaussian_blur': 'Gaussi hägu…',
      'effect_motion_blur': 'Liikumishägu…',
      'effect_pixelate': 'Pikseldamine…',
      'effect_add_noise': 'Müra lisamine…',
      'effect_median': 'Mediaan…',
      'effect_sharpen': 'Teravustamine…',
      'effect_edge_detect': 'Servade tuvastamine…',
      'effect_emboss': 'Kohrutamine…',
      'effect_outline': 'Kontuur…',
      'toggle_tools': 'Tööriistad',
      'toggle_history': 'Ajalugu',
      'toggle_layers': 'Kihid',
      'toggle_colors': 'Värvid',
      'next_image': 'Järgmine pilt',
      'previous_image': 'Eelmine pilt',
      'help': 'Abi',
      'effect_ink_sketch': 'Tušijoonistus…',
      'effect_pencil_sketch': 'Pliiatsivisand…',
      'effect_fragment': 'Killustamine…',
      'effect_radial_blur': 'Radiaalne hägu…',
      'effect_surface_blur': 'Pinnahägu…',
      'effect_unfocus': 'Fookuse hajutamine…',
      'effect_zoom_blur': 'Suurendushägu…',
      'effect_bulge': 'Kumerdus…',
      'effect_dents': 'Mõlgid…',
      'effect_frosted_glass': 'Härmatanud klaas…',
      'effect_polar_inversion': 'Polaarne inversioon…',
      'effect_tile_reflection': 'Plaatide peegeldus…',
      'effect_twist': 'Keerdumine…',
      'effect_reduce_noise': 'Müra vähendamine…',
      'effect_glow': 'Kuma…',
      'effect_red_eye_removal': 'Punasilmsuse eemaldamine…',
      'effect_soften_portrait': 'Portree pehmendamine…',
      'effect_clouds': 'Pilved…',
      'effect_julia_fractal': 'Julia fraktal…',
      'effect_mandelbrot_fractal': 'Mandelbroti fraktal…',
      'effect_relief': 'Reljeef…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Kunstilised',
      'blurs': 'Hägustamine',
      'distort': 'Moonutamine',
      'noise': 'Müra',
      'photo': 'Foto',
      'stylize': 'Stiliseerimine',
      'render': 'Renderdamine',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Ristkülikvalik',
      'move_selected_pixels': 'Valitud pikslite liigutamine',
      'lasso_select': 'Lassovalik',
      'move_selection': 'Valiku liigutamine',
      'ellipse_select': 'Ellipsvalik',
      'zoom': 'Suurendus',
      'magic_wand': 'Võlukepp',
      'pan': 'Käsi',
      'paint_bucket': 'Värvikopp',
      'gradient': 'Värviüleminek',
      'paintbrush': 'Pintsel',
      'eraser': 'Kustutuskumm',
      'pencil': 'Pliiats',
      'color_picker': 'Pipett',
      'clone_stamp': 'Kloonitempel',
      'recolor': 'Ümbervärvimine',
      'text': 'Tekst',
      'line_curve': 'Joon / kõver',
      'rectangle': 'Ristkülik',
      'rounded_rectangle': 'Ümarnurkne ristkülik',
      'ellipse': 'Ellips',
      'freeform_shape': 'Vabakujund',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Lohistage, et valida ristkülik. Ruudu saamiseks hoidke all klahvi Shift.',
      'move_selected_pixels': 'Lohistage valikut, et seda liigutada. Parema nupuga lohistades saate seda pöörata ja pidemetest lohistades skaleerida. Ctrl jätab alles koopia; nooleklahvid nihutavad valikut samm-sammult.',
      'lasso_select': 'Lohistage, et joonistada valiku piirjoon.',
      'move_selection': 'Lohistage valiku piirjoont, et seda liigutada. Pikslid jäävad paigale.',
      'ellipse_select': 'Lohistage, et valida ellips. Ringi saamiseks hoidke all klahvi Shift.',
      'zoom': 'Klõpsake vasaku nupuga, et suurendada, parema nupuga, et vähendada, või lohistage raam, et seda ala suurendada.',
      'magic_wand': 'Klõpsake värvil, et valida selle ümber olev ala. Selle värvi valimiseks kogu pildil hoidke all klahvi Shift.',
      'pan': 'Lohistage, et vaadet liigutada.',
      'paint_bucket': 'Vasakklõps täidab põhivärviga, paremklõps lisavärviga.',
      'gradient': 'Lohistage, et joonistada värviüleminek. Selle kohandamiseks lohistage pidemeid; lõpetamiseks vajutage Enter.',
      'paintbrush': 'Vasak nupp maalib põhivärviga, parem nupp lisavärviga.',
      'eraser': 'Lohistage, et kustutada läbipaistvaks.',
      'pencil': 'Joonistab ühe piksli laiuseid jooni ilma servade silumiseta.',
      'color_picker': 'Vasakklõps võtab põhivärvi, paremklõps lisavärvi.',
      'clone_stamp': 'Määrake allikas Ctrl+klõpsuga ja lohistage seejärel, et sellest maalida.',
      'recolor': 'Asendab maalimiskohas lisavärvi põhivärviga. Ctrl+klõps võtab värvi.',
      'text': 'Klõpsake kursori paigutamiseks ja seejärel tippige. Teksti liigutamiseks lohistage pidet või lohistage parema nupuga; lõpetamiseks vajutage Esc.',
      'line_curve': 'Lohistage, et joonistada joon. Selle painutamiseks lohistage pidemeid; lõpetamiseks vajutage Enter.',
      'rectangle': 'Lohistage, et joonistada ristkülik. Ruudu saamiseks hoidke all klahvi Shift.',
      'rounded_rectangle': 'Lohistage, et joonistada ümarnurkne ristkülik. Ruudu saamiseks hoidke all klahvi Shift.',
      'ellipse': 'Lohistage, et joonistada ellips. Ringi saamiseks hoidke all klahvi Shift.',
      'freeform_shape': 'Lohistage, et joonistada suletud vabakujund.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Raadius',
      'angle': 'Nurk',
      'distance': 'Kaugus',
      'centered': 'Keskel',
      'amount': 'Hulk',
      'intensity': 'Intensiivsus',
      'saturation': 'Küllastus',
      'coverage': 'Katvus',
      'seed': 'Seeme',
      'percentile': 'Protsentiil',
      'cell_size': 'Lahtri suurus',
      'brush_size': 'Pintsli suurus',
      'coarseness': 'Jämedus',
      'thickness': 'Paksus',
      'brightness': 'Eredus',
      'contrast': 'Kontrast',
      'hue': 'Toon',
      'lightness': 'Heledus',
      'red': 'Punane',
      'green': 'Roheline',
      'blue': 'Sinine',
      'input_low': 'Sisend: tume',
      'input_high': 'Sisend: hele',
      'output_low': 'Väljund: tume',
      'output_high': 'Väljund: hele',
      'gamma': 'Gamma',
      'ink_outline': 'Tušikontuur',
      'coloring': 'Värvimine',
      'tip_size': 'Pliiatsi otsa suurus',
      'color_range': 'Värvivahemik',
      'fragments': 'Killud',
      'rotation': 'Pööre',
      'offset_x': 'Nihe X',
      'offset_y': 'Nihe Y',
      'quality': 'Kvaliteet',
      'threshold': 'Lävi',
      'scale': 'Skaala',
      'refraction': 'Murdumine',
      'roughness': 'Karedus',
      'tension': 'Pinge',
      'max_scatter': 'Suurim hajuvus',
      'min_scatter': 'Vähim hajuvus',
      'samples': 'Valimite arv',
      'edge_behavior': 'Servade käsitlus',
      'tile_size': 'Plaadi suurus',
      'curvature': 'Kumerus',
      'size': 'Suurus',
      'strength': 'Tugevus',
      'tolerance': 'Tolerants',
      'softness': 'Pehmus',
      'lighting': 'Valgustus',
      'warmth': 'Soojus',
      'power': 'Võimsus',
      'blend_mode': 'Segamisrežiim',
      'factor': 'Tegur',
      'zoom': 'Suurendus',
      'invert_colors': 'Pööra värvid ümber',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Tavaline',
      'multiply': 'Korrutamine',
      'additive': 'Liitmine',
      'colorBurn': 'Värvi põletamine',
      'colorDodge': 'Värvi helestamine',
      'reflect': 'Peegeldus',
      'glow': 'Kuma',
      'overlay': 'Ülekate',
      'difference': 'Erinevus',
      'negation': 'Eitus',
      'lighten': 'Heledam',
      'darken': 'Tumedam',
      'screen': 'Ekraan',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Pildi jaoks pole piisavalt mälu.',
      'invalid_size': 'Pildi suurus on vigane.',
      'layer_index': 'Sellist kihti pole.',
      'last_layer': 'Viimast kihti ei saa kustutada.',
      'no_layer_below': 'Allpool pole kihti, millega ühendada.',
      'edit_in_progress': 'Lõpetage kõigepealt pooleliolev toiming.',
      'no_edit': 'Pooleliolevat toimingut pole.',
      'no_selection': 'Midagi pole valitud.',
      'nothing_lifted': 'Ühtegi pikslit pole üles tõstetud.',
      'invalid_parameter': 'Väärtus on lubatud vahemikust väljas.',
      'io': 'Faili ei saanud lugeda ega kirjutada.',
      'decode': 'Pilti ei saanud lugeda.',
      'encode': 'Pilti ei saanud kirjutada.',
      'open_raster': 'OpenRasteri fail on rikutud.',
      'palette': 'Paletifail on rikutud.',
      'cancelled': 'Arvutus katkestati.',
      'other': 'Midagi läks valesti.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Faili ei saanud lugeda ega kirjutada.';

  @override
  String get failureInvalidData => 'Andmeid ei saanud lugeda.';

  @override
  String get failureUnknown => 'Ilmnes ootamatu tõrge.';

  @override
  String get panelTools => 'Tööriistad';

  @override
  String get panelHistory => 'Ajalugu';

  @override
  String get panelLayers => 'Kihid';

  @override
  String get panelColors => 'Värvid';

  @override
  String get panelHide => 'Peida';

  @override
  String get colorsPrimary => 'Põhivärv';

  @override
  String get colorsSecondary => 'Lisavärv';

  @override
  String get colorsPrimaryHint => 'Põhivärv: sellega maalib hiire vasak nupp';

  @override
  String get colorsSecondaryHint => 'Lisavärv: sellega maalib hiire parem nupp';

  @override
  String get colorsSwap => 'Vaheta värvid (X)';

  @override
  String get colorsReset => 'Lähtesta mustaks ja valgeks';

  @override
  String get colorsMore => 'Rohkem';

  @override
  String get colorsLess => 'Vähem';

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
      'Vasakklõps määrab põhivärvi, paremklõps lisavärvi';

  @override
  String get settingWidth => 'Laius';

  @override
  String get settingHardness => 'Kõvadus';

  @override
  String get settingAntialias => 'Servade silumine';

  @override
  String get settingAlphaBlending => 'Alfasegamine';

  @override
  String get settingTolerance => 'Tolerants';

  @override
  String get settingFloodMode => 'Täitmisrežiim';

  @override
  String get floodLocal => 'Külgnev ala';

  @override
  String get floodGlobal => 'Kogu pilt';

  @override
  String get settingSelectionMode => 'Valikurežiim';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Asenda',
      'union': 'Liida',
      'exclude': 'Lahuta',
      'xor': 'Xor',
      'intersect': 'Ühisosa',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Valiku suurus';

  @override
  String get drawNormal => 'Tavaline';

  @override
  String get drawFixedRatio => 'Fikseeritud proportsioon';

  @override
  String get drawFixedSize => 'Fikseeritud suurus';

  @override
  String get settingResampling => 'Ümberdiskreetimine';

  @override
  String get resamplingNearest => 'Lähim naaber';

  @override
  String get resamplingBilinear => 'Bilineaarne';

  @override
  String get settingGradient => 'Tüüp';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineaarne',
      'linearReflected': 'Lineaarne peegeldatud',
      'diamond': 'Romb',
      'radial': 'Radiaalne',
      'conical': 'Kooniline',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Värv';

  @override
  String get gradientTransparency => 'Läbipaistvus';

  @override
  String get settingShape => 'Kujundi stiil';

  @override
  String get shapeOutline => 'Kontuur';

  @override
  String get shapeInterior => 'Täide';

  @override
  String get shapeBoth => 'Kontuur ja täide';

  @override
  String get settingAfterPick => 'Pärast värvi võtmist';

  @override
  String get pickStay => 'Jää selle tööriista juurde';

  @override
  String get pickPrevious => 'Lülitu eelmisele tööriistale';

  @override
  String get pickPencil => 'Lülitu pliiatsile';

  @override
  String get settingNone => 'Sellel tööriistal pole sätteid.';

  @override
  String toolUnavailable(String name) {
    return 'Tööriist „$name“ pole veel saadaval';
  }

  @override
  String get historyFirst => 'Mine esimese sammu juurde';

  @override
  String get historyUndo => 'Võta tagasi';

  @override
  String get historyRedo => 'Tee uuesti';

  @override
  String get historyLast => 'Mine viimase sammu juurde';

  @override
  String get historyNewImage => 'Uus pilt';

  @override
  String get historyOpenImage => 'Pildi avamine';

  @override
  String get layerVisible => 'Näita või peida kiht';

  @override
  String get layerBackground => 'Taust';

  @override
  String get layerName => 'Nimi';

  @override
  String get layerOpacity => 'Läbipaistmatus';

  @override
  String get layerBlendMode => 'Segamisrežiim';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Loobu';

  @override
  String get save => 'Salvesta';

  @override
  String get dontSave => 'Ära salvesta';

  @override
  String get keepCanvas => 'Jäta lõuend samaks';

  @override
  String get expandCanvas => 'Laienda lõuendit';

  @override
  String get width => 'Laius';

  @override
  String get height => 'Kõrgus';

  @override
  String get pixels => 'pikslit';

  @override
  String get newImageTitle => 'Uus pilt';

  @override
  String get resizeTitle => 'Pildi suuruse muutmine';

  @override
  String get canvasSizeTitle => 'Lõuendi suurus';

  @override
  String get keepRatio => 'Säilita proportsioonid';

  @override
  String get anchor => 'Ankur';

  @override
  String sizeTooLarge(int max) {
    return 'Pilt on liiga suur: piirang on $max megapikslit.';
  }

  @override
  String get unsavedTitle => 'Kas salvestada muudatused?';

  @override
  String unsavedMessage(String name) {
    return 'Pildil „$name“ on salvestamata muudatusi.';
  }

  @override
  String get flattenTitle => 'Kas lamendada pilt?';

  @override
  String flattenMessage(String format) {
    return 'Vorming $format ei säilita kihte, seega lamendatakse pilt üheks kihiks. Saate selle tagasi võtta aknas Ajalugu.';
  }

  @override
  String get flatten => 'Lamenda';

  @override
  String get jpegQualityTitle => 'JPEG-kvaliteet';

  @override
  String get quality => 'Kvaliteet';

  @override
  String get largerTitle => 'Pilt on lõuendist suurem';

  @override
  String get largerMessage => 'Kas laiendada lõuendit, et pilt mahuks?';

  @override
  String get reseed => 'Uus seeme';

  @override
  String get rendering => 'Arvutamine…';

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
    return 'Avamine: $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Salvestamine: $name…';
  }

  @override
  String savedTo(String name) {
    return 'Salvestatud: $name';
  }

  @override
  String get dropHere => 'Avamiseks laske lahti';

  @override
  String get dropHint => 'Iga fail avatakse uue pildina';

  @override
  String get imagesList => 'Avatud pildid';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Kihtidega rastergraafikaredaktor. Tööriista valimiseks vajutage tähte; S, M või O uuesti vajutamine vahetab seotud tööriistu. [ ja ] muudavad pintsli laiust, X vahetab värvid, tühikuklahvi all hoides saate vaadet liigutada, Ctrl+hiireratas muudab suurendust ning F5–F8 näitavad või peidavad aknaid.';

  @override
  String get aboutLegal =>
      '© 2026 Paintboxi autorid. Paintbox on vaba tarkvara: seda võib levitada ja muuta GNU General Public License’i versiooni 3 või uuema tingimustel. Programmil puudub igasugune garantii.';

  @override
  String get licenses => 'Litsentsid';

  @override
  String get settingLineStart => 'Algus';

  @override
  String get settingLineEnd => 'Lõpp';

  @override
  String get settingDash => 'Kriipsutus';

  @override
  String get settingSwapSize => 'Vaheta laius ja kõrgus';

  @override
  String get settingLineStyle => 'Stiil';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Lame',
      'arrow': 'Nool',
      'arrowFilled': 'Täidetud nool',
      'rounded': 'Ümar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Pidev',
      'dash': 'Kriips',
      'dashDot': 'Kriips-punkt',
      'dashDotDot': 'Kriips-punkt-punkt',
      'dot': 'Punkt',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Kirjatüüp';

  @override
  String get settingFontSize => 'Suurus';

  @override
  String get textBold => 'Paks';

  @override
  String get textItalic => 'Kaldkiri';

  @override
  String get textUnderline => 'Allajoonitud';

  @override
  String get textStrikeout => 'Läbikriipsutatud';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Vasakule',
      'center': 'Keskele',
      'right': 'Paremale',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Pildid';
}
