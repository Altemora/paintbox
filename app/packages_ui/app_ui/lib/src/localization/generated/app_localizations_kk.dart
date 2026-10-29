// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Атаусыз $number';
  }

  @override
  String get menuFile => 'Файл';

  @override
  String get menuEdit => 'Түзету';

  @override
  String get menuView => 'Көрініс';

  @override
  String get menuImage => 'Сурет';

  @override
  String get menuLayers => 'Қабаттар';

  @override
  String get menuAdjustments => 'Реттеулер';

  @override
  String get menuEffects => 'Эффектілер';

  @override
  String get menuOpenRecent => 'Соңғы файлдар';

  @override
  String get menuRecentEmpty => 'Соңғы файлдар жоқ';

  @override
  String get menuTheme => 'Тақырып';

  @override
  String get menuSettings => 'Баптаулар';

  @override
  String get menuAccent => 'Акцент түсі';

  @override
  String get menuLanguage => 'Тіл';

  @override
  String get languageSystem => 'Жүйедегідей';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Көк',
      'green': 'Жасыл',
      'amber': 'Кәріптас',
      'purple': 'Күлгін',
      'red': 'Қызыл',
      'gray': 'Сұр',
      'custom': 'Басқа…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Басқа акцент түсі';

  @override
  String get unitsPixels => 'пкс';

  @override
  String get themeSystem => 'Жүйедегідей';

  @override
  String get themeDark => 'Қараңғы';

  @override
  String get themeLight => 'Ашық';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Жасау…',
      'open': 'Ашу…',
      'close': 'Жабу',
      'save': 'Сақтау',
      'save_as': 'Басқаша сақтау…',
      'exit': 'Шығу',
      'undo': 'Болдырмау',
      'redo': 'Қайталау',
      'cut': 'Қиып алу',
      'copy': 'Көшіру',
      'paste': 'Кірістіру',
      'paste_into_new_layer': 'Жаңа қабатқа кірістіру',
      'paste_into_new_image': 'Жаңа суретке кірістіру',
      'erase_selection': 'Ерекшеленгенді өшіру',
      'fill_selection': 'Ерекшеленгенді толтыру',
      'invert_selection': 'Ерекшелеуді инверсиялау',
      'select_all': 'Барлығын ерекшелеу',
      'deselect': 'Ерекшелеуді алып тастау',
      'zoom_in': 'Үлкейту',
      'zoom_out': 'Кішірейту',
      'zoom_to_window': 'Терезеге сыйдыру',
      'zoom_to_selection': 'Ерекшеленген аймаққа сыйдыру',
      'actual_size': 'Нақты өлшем',
      'pixel_grid': 'Пиксел торы',
      'rulers': 'Сызғыштар',
      'crop_to_selection': 'Ерекшеленген аймақ бойынша қию',
      'resize': 'Сурет өлшемін өзгерту…',
      'canvas_size': 'Кенеп өлшемін өзгерту…',
      'flip_horizontal': 'Көлденеңінен шағылыстыру',
      'flip_vertical': 'Тігінен шағылыстыру',
      'rotate90_cw': 'Сағат тілімен 90° бұру',
      'rotate90_ccw': 'Сағат тіліне қарсы 90° бұру',
      'rotate180': '180° бұру',
      'flatten': 'Бір қабатқа біріктіру',
      'add_layer': 'Жаңа қабат қосу',
      'delete_layer': 'Қабатты жою',
      'duplicate_layer': 'Қабаттың көшірмесін жасау',
      'merge_layer_down': 'Төменгі қабатпен біріктіру',
      'import_from_file': 'Файлдан импорттау…',
      'flip_layer_horizontal': 'Қабатты көлденеңінен шағылыстыру',
      'flip_layer_vertical': 'Қабатты тігінен шағылыстыру',
      'move_layer_up': 'Қабатты жоғары жылжыту',
      'move_layer_down': 'Қабатты төмен жылжыту',
      'layer_properties': 'Қабат қасиеттері…',
      'adjust_auto_level': 'Автоматты деңгейлер',
      'adjust_black_and_white': 'Ақ-қара',
      'adjust_brightness_contrast': 'Жарықтық / контраст…',
      'adjust_curves': 'Қисықтар…',
      'adjust_hue_saturation': 'Түс реңі / қанықтылық…',
      'adjust_invert_colors': 'Түстерді инверсиялау',
      'adjust_levels': 'Деңгейлер…',
      'adjust_posterize': 'Постеризация…',
      'adjust_sepia': 'Сепия',
      'repeat_effect': 'Эффектіні қайталау',
      'effect_oil_painting': 'Майлы бояу…',
      'effect_gaussian_blur': 'Гаусс бойынша бұлыңғырлау…',
      'effect_motion_blur': 'Қозғалыс бұлыңғырлығы…',
      'effect_pixelate': 'Пикселизация…',
      'effect_add_noise': 'Шу қосу…',
      'effect_median': 'Медиана…',
      'effect_sharpen': 'Айқындық…',
      'effect_edge_detect': 'Жиектерді анықтау…',
      'effect_emboss': 'Бедерлеу…',
      'effect_outline': 'Контур…',
      'toggle_tools': 'Құралдар',
      'toggle_history': 'Тарих',
      'toggle_layers': 'Қабаттар',
      'toggle_colors': 'Түстер',
      'next_image': 'Келесі сурет',
      'previous_image': 'Алдыңғы сурет',
      'help': 'Анықтама',
      'effect_ink_sketch': 'Сия нобайы…',
      'effect_pencil_sketch': 'Қарындаш нобайы…',
      'effect_fragment': 'Фрагменттеу…',
      'effect_radial_blur': 'Радиалды бұлыңғырлау…',
      'effect_surface_blur': 'Беттік бұлыңғырлау…',
      'effect_unfocus': 'Фокусты жою…',
      'effect_zoom_blur': 'Масштабтық бұлыңғырлау…',
      'effect_bulge': 'Дөңестік…',
      'effect_dents': 'Ойықтар…',
      'effect_frosted_glass': 'Күңгірт шыны…',
      'effect_polar_inversion': 'Полярлық инверсия…',
      'effect_tile_reflection': 'Плиткалы шағылысу…',
      'effect_twist': 'Бұрау…',
      'effect_reduce_noise': 'Шуды азайту…',
      'effect_glow': 'Жарқырау…',
      'effect_red_eye_removal': 'Қызыл көзді жою…',
      'effect_soften_portrait': 'Жұмсақ портрет…',
      'effect_clouds': 'Бұлттар…',
      'effect_julia_fractal': 'Жюлиа фракталы…',
      'effect_mandelbrot_fractal': 'Мандельброт фракталы…',
      'effect_relief': 'Рельеф…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Көркем',
      'blurs': 'Бұлыңғырлау',
      'distort': 'Бұрмалау',
      'noise': 'Шу',
      'photo': 'Фото',
      'stylize': 'Стильдеу',
      'render': 'Рендеринг',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Тіктөртбұрышты ерекшелеу',
      'move_selected_pixels': 'Ерекшеленген пикселдерді жылжыту',
      'lasso_select': 'Лассо',
      'move_selection': 'Ерекшелеуді жылжыту',
      'ellipse_select': 'Эллипстік ерекшелеу',
      'zoom': 'Масштаб',
      'magic_wand': 'Сиқырлы таяқша',
      'pan': 'Қол',
      'paint_bucket': 'Құю',
      'gradient': 'Градиент',
      'paintbrush': 'Қылқалам',
      'eraser': 'Өшіргіш',
      'pencil': 'Қарындаш',
      'color_picker': 'Пипетка',
      'clone_stamp': 'Штамп',
      'recolor': 'Қайта бояу',
      'text': 'Мәтін',
      'line_curve': 'Сызық / қисық',
      'rectangle': 'Тіктөртбұрыш',
      'rounded_rectangle': 'Дөңгеленген тіктөртбұрыш',
      'ellipse': 'Эллипс',
      'freeform_shape': 'Еркін пішін',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Тіктөртбұрышты ерекшелеу үшін тартыңыз. Шаршы алу үшін Shift пернесін басып тұрыңыз.',
      'move_selected_pixels': 'Ерекшеленген аймақты жылжыту үшін оны тартыңыз. Бұру үшін оң жақ батырмамен тартыңыз, масштабтау үшін тұтқаларды тартыңыз. Ctrl көшірмесін қалдырады, ал бағыт пернелері оны сәл жылжытады.',
      'lasso_select': 'Ерекшелеудің контурын салу үшін тартыңыз.',
      'move_selection': 'Ерекшелеу контурын жылжыту үшін оны тартыңыз. Пикселдер орнында қалады.',
      'ellipse_select': 'Эллипсті ерекшелеу үшін тартыңыз. Шеңбер алу үшін Shift пернесін басып тұрыңыз.',
      'zoom': 'Үлкейту үшін сол жақ батырманы, кішірейту үшін оң жақ батырманы шертіңіз. Аймақты үлкейту үшін оны жақтаумен белгілеңіз.',
      'magic_wand': 'Түстің айналасындағы аймақты ерекшелеу үшін сол түсті шертіңіз. Бұл түсті бүкіл суреттен ерекшелеу үшін Shift пернесін басып тұрыңыз.',
      'pan': 'Көріністі жылжыту үшін тартыңыз.',
      'paint_bucket': 'Сол жақ батырманы шерту негізгі түспен, ал оң жақ батырманы шерту қосымша түспен құяды.',
      'gradient': 'Градиент салу үшін тартыңыз. Оны түзету үшін тұтқаларды тартыңыз, ал аяқтау үшін Enter пернесін басыңыз.',
      'paintbrush': 'Сол жақ батырма негізгі түспен, ал оң жақ батырма қосымша түспен салады.',
      'eraser': 'Мөлдір күйге дейін өшіру үшін тартыңыз.',
      'pencil': 'Тегістеусіз бір пиксел қалыңдықтағы сызықтар салады.',
      'color_picker': 'Сол жақ батырманы шерту негізгі түсті, ал оң жақ батырманы шерту қосымша түсті алады.',
      'clone_stamp': 'Көзді орнату үшін Ctrl пернесін басып тұрып шертіңіз, содан кейін одан бояу үшін тартыңыз.',
      'recolor': 'Сіз бояған жерде қосымша түсті негізгі түспен алмастырады. Ctrl пернесін басып тұрып шерту түсті алады.',
      'text': 'Курсорды қою үшін шертіп, мәтінді теріңіз. Мәтінді жылжыту үшін тұтқаны тартыңыз немесе оң жақ батырмамен тартыңыз; аяқтау үшін Esc пернесін басыңыз.',
      'line_curve': 'Сызық салу үшін тартыңыз. Оны иілту үшін тұтқаларды тартыңыз, ал аяқтау үшін Enter пернесін басыңыз.',
      'rectangle': 'Тіктөртбұрыш салу үшін тартыңыз. Шаршы алу үшін Shift пернесін басып тұрыңыз.',
      'rounded_rectangle': 'Дөңгеленген тіктөртбұрыш салу үшін тартыңыз. Шаршы алу үшін Shift пернесін басып тұрыңыз.',
      'ellipse': 'Эллипс салу үшін тартыңыз. Шеңбер алу үшін Shift пернесін басып тұрыңыз.',
      'freeform_shape': 'Тұйық еркін пішін салу үшін тартыңыз.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Радиус',
      'angle': 'Бұрыш',
      'distance': 'Қашықтық',
      'centered': 'Ортадан',
      'amount': 'Мөлшер',
      'intensity': 'Қарқындылық',
      'saturation': 'Қанықтылық',
      'coverage': 'Қамту',
      'seed': 'Бастапқы мән',
      'percentile': 'Процентиль',
      'cell_size': 'Ұяшық өлшемі',
      'brush_size': 'Қылқалам өлшемі',
      'coarseness': 'Ірілік',
      'thickness': 'Қалыңдық',
      'brightness': 'Жарықтық',
      'contrast': 'Контраст',
      'hue': 'Түс реңі',
      'lightness': 'Ашықтық',
      'red': 'Қызыл',
      'green': 'Жасыл',
      'blue': 'Көк',
      'input_low': 'Кіріс: минимум',
      'input_high': 'Кіріс: максимум',
      'output_low': 'Шығыс: минимум',
      'output_high': 'Шығыс: максимум',
      'gamma': 'Гамма',
      'ink_outline': 'Сия контуры',
      'coloring': 'Бояу',
      'tip_size': 'Қарындаш ұшының өлшемі',
      'color_range': 'Түстер ауқымы',
      'fragments': 'Фрагменттер',
      'rotation': 'Бұру',
      'offset_x': 'X ығысуы',
      'offset_y': 'Y ығысуы',
      'quality': 'Сапа',
      'threshold': 'Шек',
      'scale': 'Масштаб',
      'refraction': 'Сыну',
      'roughness': 'Кедір-бұдырлық',
      'tension': 'Керілу',
      'max_scatter': 'Ең үлкен шашырау',
      'min_scatter': 'Ең кіші шашырау',
      'samples': 'Үлгілер саны',
      'edge_behavior': 'Жиектегі әрекет',
      'tile_size': 'Плитка өлшемі',
      'curvature': 'Қисықтық',
      'size': 'Өлшем',
      'strength': 'Күш',
      'tolerance': 'Шыдамдылық',
      'softness': 'Жұмсақтық',
      'lighting': 'Жарықтандыру',
      'warmth': 'Жылылық',
      'power': 'Дәреже',
      'blend_mode': 'Араластыру режимі',
      'factor': 'Коэффициент',
      'zoom': 'Үлкейту',
      'invert_colors': 'Түстерді инверсиялау',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Қалыпты',
      'multiply': 'Көбейту',
      'additive': 'Қосу',
      'colorBurn': 'Түсті күйдіру',
      'colorDodge': 'Түсті ағарту',
      'reflect': 'Шағылысу',
      'glow': 'Жарқырау',
      'overlay': 'Қабаттастыру',
      'difference': 'Айырма',
      'negation': 'Терістеу',
      'lighten': 'Ашықтау',
      'darken': 'Қараңғылау',
      'screen': 'Экран',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Сурет үшін жад жеткіліксіз.',
      'invalid_size': 'Сурет өлшемі жарамсыз.',
      'layer_index': 'Мұндай қабат жоқ.',
      'last_layer': 'Соңғы қабатты жою мүмкін емес.',
      'no_layer_below': 'Бұл қабаттың астында біріктіретін қабат жоқ.',
      'edit_in_progress': 'Алдымен ағымдағы әрекетті аяқтаңыз.',
      'no_edit': 'Аяқталмаған әрекет жоқ.',
      'no_selection': 'Ештеңе ерекшеленбеген.',
      'nothing_lifted': 'Көтерілген пикселдер жоқ.',
      'invalid_parameter': 'Мән рұқсат етілген ауқымнан тыс.',
      'io': 'Файлды оқу немесе жазу мүмкін болмады.',
      'decode': 'Суретті оқу мүмкін болмады.',
      'encode': 'Суретті жазу мүмкін болмады.',
      'open_raster': 'OpenRaster файлы зақымдалған.',
      'palette': 'Палитра файлы зақымдалған.',
      'cancelled': 'Есептеу тоқтатылды.',
      'other': 'Қате орын алды.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Файлды оқу немесе жазу мүмкін болмады.';

  @override
  String get failureInvalidData => 'Деректерді оқу мүмкін болмады.';

  @override
  String get failureUnknown => 'Күтпеген қате орын алды.';

  @override
  String get panelTools => 'Құралдар';

  @override
  String get panelHistory => 'Тарих';

  @override
  String get panelLayers => 'Қабаттар';

  @override
  String get panelColors => 'Түстер';

  @override
  String get panelHide => 'Жасыру';

  @override
  String get colorsPrimary => 'Негізгі';

  @override
  String get colorsSecondary => 'Қосымша';

  @override
  String get colorsPrimaryHint =>
      'Негізгі түс: онымен тінтуірдің сол жақ батырмасы салады';

  @override
  String get colorsSecondaryHint =>
      'Қосымша түс: онымен тінтуірдің оң жақ батырмасы салады';

  @override
  String get colorsSwap => 'Түстерді алмастыру (X)';

  @override
  String get colorsReset => 'Қара мен аққа қайтару';

  @override
  String get colorsMore => 'Көбірек';

  @override
  String get colorsLess => 'Азырақ';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Альфа';

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
      'Сол жақ батырманы шерту негізгі түсті, ал оң жақ батырманы шерту қосымша түсті орнатады';

  @override
  String get settingWidth => 'Ені';

  @override
  String get settingHardness => 'Қаттылық';

  @override
  String get settingAntialias => 'Тегістеу';

  @override
  String get settingAlphaBlending => 'Альфа араластыру';

  @override
  String get settingTolerance => 'Шыдамдылық';

  @override
  String get settingFloodMode => 'Құю режимі';

  @override
  String get floodLocal => 'Іргелес';

  @override
  String get floodGlobal => 'Бүкіл сурет';

  @override
  String get settingSelectionMode => 'Ерекшелеу режимі';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Алмастыру',
      'union': 'Қосу',
      'exclude': 'Алып тастау',
      'xor': 'XOR',
      'intersect': 'Қиылыстыру',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Ерекшелеу өлшемі';

  @override
  String get drawNormal => 'Еркін';

  @override
  String get drawFixedRatio => 'Тұрақты арақатынас';

  @override
  String get drawFixedSize => 'Тұрақты өлшем';

  @override
  String get settingResampling => 'Қайта дискретизациялау';

  @override
  String get resamplingNearest => 'Ең жақын көрші';

  @override
  String get resamplingBilinear => 'Бисызықтық';

  @override
  String get settingGradient => 'Түрі';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Сызықтық',
      'linearReflected': 'Сызықтық айналы',
      'diamond': 'Ромб',
      'radial': 'Радиалды',
      'conical': 'Конустық',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Түс';

  @override
  String get gradientTransparency => 'Мөлдірлік';

  @override
  String get settingShape => 'Пішін стилі';

  @override
  String get shapeOutline => 'Контур';

  @override
  String get shapeInterior => 'Толтыру';

  @override
  String get shapeBoth => 'Контур және толтыру';

  @override
  String get settingAfterPick => 'Түсті алғаннан кейін';

  @override
  String get pickStay => 'Осы құралды қалдыру';

  @override
  String get pickPrevious => 'Алдыңғы құралға ауысу';

  @override
  String get pickPencil => 'Қарындашқа ауысу';

  @override
  String get settingNone => 'Бұл құралдың баптаулары жоқ.';

  @override
  String toolUnavailable(String name) {
    return '«$name» құралы әзірге қолжетімсіз';
  }

  @override
  String get historyFirst => 'Бірінші қадамға өту';

  @override
  String get historyUndo => 'Болдырмау';

  @override
  String get historyRedo => 'Қайталау';

  @override
  String get historyLast => 'Соңғы қадамға өту';

  @override
  String get historyNewImage => 'Жаңа сурет';

  @override
  String get historyOpenImage => 'Суретті ашу';

  @override
  String get layerVisible => 'Қабатты көрсету немесе жасыру';

  @override
  String get layerBackground => 'Фон';

  @override
  String get layerName => 'Атауы';

  @override
  String get layerOpacity => 'Мөлдірсіздік';

  @override
  String get layerBlendMode => 'Араластыру режимі';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get save => 'Сақтау';

  @override
  String get dontSave => 'Сақтамау';

  @override
  String get keepCanvas => 'Кенепті қалдыру';

  @override
  String get expandCanvas => 'Кенепті кеңейту';

  @override
  String get width => 'Ені';

  @override
  String get height => 'Биіктігі';

  @override
  String get pixels => 'пиксел';

  @override
  String get newImageTitle => 'Жаңа сурет';

  @override
  String get resizeTitle => 'Сурет өлшемін өзгерту';

  @override
  String get canvasSizeTitle => 'Кенеп өлшемі';

  @override
  String get keepRatio => 'Арақатынасты сақтау';

  @override
  String get anchor => 'Зәкір';

  @override
  String sizeTooLarge(int max) {
    return 'Сурет тым үлкен: шегі — $max мегапиксел.';
  }

  @override
  String get unsavedTitle => 'Өзгерістерді сақтау керек пе?';

  @override
  String unsavedMessage(String name) {
    return '«$name» ішінде сақталмаған өзгерістер бар.';
  }

  @override
  String get flattenTitle => 'Суретті бір қабатқа біріктіру керек пе?';

  @override
  String flattenMessage(String format) {
    return '$format пішімі қабаттарды сақтамайды, сондықтан сурет бір қабатқа біріктіріледі. Мұны «Тарих» терезесінде болдырмауға болады.';
  }

  @override
  String get flatten => 'Біріктіру';

  @override
  String get jpegQualityTitle => 'JPEG сапасы';

  @override
  String get quality => 'Сапа';

  @override
  String get largerTitle => 'Сурет кенептен үлкен';

  @override
  String get largerMessage => 'Суретті сыйдыру үшін кенепті кеңейту керек пе?';

  @override
  String get reseed => 'Жаңа бастапқы мән';

  @override
  String get rendering => 'Есептелуде…';

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
    return '$name ашылуда…';
  }

  @override
  String statusSaving(String name) {
    return '$name сақталуда…';
  }

  @override
  String savedTo(String name) {
    return 'Сақталды: $name';
  }

  @override
  String get dropHere => 'Ашу үшін босатыңыз';

  @override
  String get dropHint => 'Әр файл жаңа сурет ретінде ашылады';

  @override
  String get imagesList => 'Ашық суреттер';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Қабаттары бар растрлық сурет өңдегіші. Құралды таңдау үшін әріпті басыңыз; S, M немесе O пернесін қайта басу туыстас құралдарды кезекпен ауыстырады. [ және ] қылқалам енін өзгертеді, X түстерді алмастырады, бос орын пернесін басып тұру көріністі жылжытады, Ctrl+тінтуір дөңгелегі масштабты өзгертеді, ал F5–F8 терезелерді көрсетеді немесе жасырады.';

  @override
  String get aboutLegal =>
      '© 2026 Paintbox авторлары. Paintbox — еркін бағдарламалық жасақтама: оны GNU General Public License 3-нұсқасының немесе кейінгі нұсқасының шарттарымен таратуға және өзгертуге болады. Бағдарлама ешқандай кепілдіксіз беріледі.';

  @override
  String get licenses => 'Лицензиялар';

  @override
  String get settingLineStart => 'Басы';

  @override
  String get settingLineEnd => 'Соңы';

  @override
  String get settingDash => 'Штрих';

  @override
  String get settingSwapSize => 'Ені мен биіктігін алмастыру';

  @override
  String get settingLineStyle => 'Стиль';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Жалпақ',
      'arrow': 'Нұсқар',
      'arrowFilled': 'Толтырылған нұсқар',
      'rounded': 'Дөңгеленген',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Тұтас',
      'dash': 'Штрих',
      'dashDot': 'Штрих-нүкте',
      'dashDotDot': 'Штрих-нүкте-нүкте',
      'dot': 'Нүкте',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Қаріп';

  @override
  String get settingFontSize => 'Өлшемі';

  @override
  String get textBold => 'Жуан';

  @override
  String get textItalic => 'Көлбеу';

  @override
  String get textUnderline => 'Асты сызылған';

  @override
  String get textStrikeout => 'Сызылған';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Сол жаққа',
      'center': 'Ортаға',
      'right': 'Оң жаққа',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Суреттер';
}
