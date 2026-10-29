// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Belarusian (`be`).
class AppLocalizationsBe extends AppLocalizations {
  AppLocalizationsBe([String locale = 'be']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Без назвы $number';
  }

  @override
  String get menuFile => 'Файл';

  @override
  String get menuEdit => 'Праўка';

  @override
  String get menuView => 'Выгляд';

  @override
  String get menuImage => 'Відарыс';

  @override
  String get menuLayers => 'Пласты';

  @override
  String get menuAdjustments => 'Карэкцыя';

  @override
  String get menuEffects => 'Эфекты';

  @override
  String get menuOpenRecent => 'Нядаўнія файлы';

  @override
  String get menuRecentEmpty => 'Няма нядаўніх файлаў';

  @override
  String get menuTheme => 'Тэма';

  @override
  String get menuSettings => 'Налады';

  @override
  String get menuAccent => 'Акцэнтны колер';

  @override
  String get menuLanguage => 'Мова';

  @override
  String get languageSystem => 'Як у сістэме';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Сіні',
      'green': 'Зялёны',
      'amber': 'Бурштынавы',
      'purple': 'Фіялетавы',
      'red': 'Чырвоны',
      'gray': 'Шэры',
      'custom': 'Іншы…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Іншы акцэнтны колер';

  @override
  String get unitsPixels => 'пкс';

  @override
  String get themeSystem => 'Як у сістэме';

  @override
  String get themeDark => 'Цёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Стварыць…',
      'open': 'Адкрыць…',
      'close': 'Закрыць',
      'save': 'Захаваць',
      'save_as': 'Захаваць як…',
      'exit': 'Выйсці',
      'undo': 'Скасаваць',
      'redo': 'Паўтарыць',
      'cut': 'Выразаць',
      'copy': 'Капіяваць',
      'paste': 'Уставіць',
      'paste_into_new_layer': 'Уставіць у новы пласт',
      'paste_into_new_image': 'Уставіць у новы відарыс',
      'erase_selection': 'Сцерці вылучанае',
      'fill_selection': 'Заліць вылучанае',
      'invert_selection': 'Інвертаваць вылучэнне',
      'select_all': 'Вылучыць усё',
      'deselect': 'Зняць вылучэнне',
      'zoom_in': 'Наблізіць',
      'zoom_out': 'Аддаліць',
      'zoom_to_window': 'Па памеры акна',
      'zoom_to_selection': 'Па памеры вылучэння',
      'actual_size': 'Сапраўдны памер',
      'pixel_grid': 'Піксельная сетка',
      'rulers': 'Лінейкі',
      'crop_to_selection': 'Абрэзаць па вылучэнні',
      'resize': 'Змяніць памер відарыса…',
      'canvas_size': 'Змяніць памер палатна…',
      'flip_horizontal': 'Адлюстраваць па гарызанталі',
      'flip_vertical': 'Адлюстраваць па вертыкалі',
      'rotate90_cw': 'Павярнуць на 90° па гадзіннікавай стрэлцы',
      'rotate90_ccw': 'Павярнуць на 90° супраць гадзіннікавай стрэлкі',
      'rotate180': 'Павярнуць на 180°',
      'flatten': 'Звесці пласты',
      'add_layer': 'Дадаць новы пласт',
      'delete_layer': 'Выдаліць пласт',
      'duplicate_layer': 'Дубліраваць пласт',
      'merge_layer_down': 'Аб\'яднаць з ніжнім пластом',
      'import_from_file': 'Імпартаваць з файла…',
      'flip_layer_horizontal': 'Адлюстраваць пласт па гарызанталі',
      'flip_layer_vertical': 'Адлюстраваць пласт па вертыкалі',
      'move_layer_up': 'Падняць пласт',
      'move_layer_down': 'Апусціць пласт',
      'layer_properties': 'Уласцівасці пласта…',
      'adjust_auto_level': 'Аўтаматычныя ўзроўні',
      'adjust_black_and_white': 'Чорна-белае',
      'adjust_brightness_contrast': 'Яркасць / кантраст…',
      'adjust_curves': 'Крывыя…',
      'adjust_hue_saturation': 'Адценне / насычанасць…',
      'adjust_invert_colors': 'Інвертаваць колеры',
      'adjust_levels': 'Узроўні…',
      'adjust_posterize': 'Пастэрызацыя…',
      'adjust_sepia': 'Сэпія',
      'repeat_effect': 'Паўтарыць эфект',
      'effect_oil_painting': 'Алейны жывапіс…',
      'effect_gaussian_blur': 'Размыццё па Гаўсе…',
      'effect_motion_blur': 'Размыццё ў руху…',
      'effect_pixelate': 'Пікселізацыя…',
      'effect_add_noise': 'Дадаць шум…',
      'effect_median': 'Медыяна…',
      'effect_sharpen': 'Рэзкасць…',
      'effect_edge_detect': 'Выяўленне краёў…',
      'effect_emboss': 'Цісненне…',
      'effect_outline': 'Контур…',
      'toggle_tools': 'Інструменты',
      'toggle_history': 'Гісторыя',
      'toggle_layers': 'Пласты',
      'toggle_colors': 'Колеры',
      'next_image': 'Наступны відарыс',
      'previous_image': 'Папярэдні відарыс',
      'help': 'Даведка',
      'effect_ink_sketch': 'Накід тушшу…',
      'effect_pencil_sketch': 'Накід алоўкам…',
      'effect_fragment': 'Фрагментацыя…',
      'effect_radial_blur': 'Радыяльнае размыццё…',
      'effect_surface_blur': 'Размыццё паверхні…',
      'effect_unfocus': 'Расфакусоўка…',
      'effect_zoom_blur': 'Размыццё набліжэннем…',
      'effect_bulge': 'Выпукласць…',
      'effect_dents': 'Увагнутасці…',
      'effect_frosted_glass': 'Матавае шкло…',
      'effect_polar_inversion': 'Палярная інверсія…',
      'effect_tile_reflection': 'Адбіццё плітак…',
      'effect_twist': 'Скручванне…',
      'effect_reduce_noise': 'Памяншэнне шуму…',
      'effect_glow': 'Ззянне…',
      'effect_red_eye_removal': 'Выдаленне чырвоных вачэй…',
      'effect_soften_portrait': 'Мяккі партрэт…',
      'effect_clouds': 'Аблокі…',
      'effect_julia_fractal': 'Фрактал Жуліа…',
      'effect_mandelbrot_fractal': 'Фрактал Мандэльброта…',
      'effect_relief': 'Рэльеф…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Мастацкія',
      'blurs': 'Размыццё',
      'distort': 'Скажэнне',
      'noise': 'Шум',
      'photo': 'Фота',
      'stylize': 'Стылізацыя',
      'render': 'Візуалізацыя',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Прамавугольнае вылучэнне',
      'move_selected_pixels': 'Перамяшчэнне вылучаных пікселяў',
      'lasso_select': 'Ласо',
      'move_selection': 'Перамяшчэнне вылучэння',
      'ellipse_select': 'Эліптычнае вылучэнне',
      'zoom': 'Маштаб',
      'magic_wand': 'Чароўная палачка',
      'pan': 'Рука',
      'paint_bucket': 'Заліўка',
      'gradient': 'Градыент',
      'paintbrush': 'Пэндзаль',
      'eraser': 'Сцірка',
      'pencil': 'Аловак',
      'color_picker': 'Піпетка',
      'clone_stamp': 'Штамп',
      'recolor': 'Перафарбоўванне',
      'text': 'Тэкст',
      'line_curve': 'Лінія / крывая',
      'rectangle': 'Прамавугольнік',
      'rounded_rectangle': 'Скруглены прамавугольнік',
      'ellipse': 'Эліпс',
      'freeform_shape': 'Адвольная фігура',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Пацягніце, каб вылучыць прамавугольнік. Утрымлівайце Shift, каб атрымаць квадрат.',
      'move_selected_pixels': 'Перацягніце вылучанае, каб перамясціць яго. Цягніце правай кнопкай, каб павярнуць яго, або цягніце маркеры, каб змяніць яго памер. Ctrl пакідае копію, а клавішы са стрэлкамі злёгку зрушваюць вылучанае.',
      'lasso_select': 'Пацягніце, каб абвесці контур вылучэння.',
      'move_selection': 'Перацягніце контур вылучэння, каб перамясціць яго. Пікселі застаюцца на месцы.',
      'ellipse_select': 'Пацягніце, каб вылучыць эліпс. Утрымлівайце Shift, каб атрымаць круг.',
      'zoom': 'Пстрыкніце левай кнопкай, каб наблізіць, або правай, каб аддаліць. Абвядзіце рамку, каб наблізіць вобласць у ёй.',
      'magic_wand': 'Пстрыкніце па колеры, каб вылучыць вобласць вакол яго. Утрымлівайце Shift, каб вылучыць гэты колер па ўсім відарысе.',
      'pan': 'Пацягніце, каб зрушыць выгляд.',
      'paint_bucket': 'Пстрычка левай кнопкай залівае асноўным колерам, правай — дадатковым.',
      'gradient': 'Пацягніце, каб намаляваць градыент. Цягніце маркеры, каб змяніць яго, і націсніце Enter, каб завяршыць.',
      'paintbrush': 'Левая кнопка малюе асноўным колерам, правая — дадатковым.',
      'eraser': 'Пацягніце, каб сцерці да празрыстасці.',
      'pencil': 'Малюе лініі таўшчынёй у адзін піксель без згладжвання.',
      'color_picker':
          'Пстрычка левай кнопкай бярэ асноўны колер, правай — дадатковы.',
      'clone_stamp': 'Пстрыкніце з націснутай клавішай Ctrl, каб задаць крыніцу, а потым цягніце, каб маляваць з яе.',
      'recolor': 'Замяняе дадатковы колер асноўным там, дзе вы малюеце. Пстрычка з націснутай клавішай Ctrl бярэ колер.',
      'text': 'Пстрыкніце, каб паставіць курсор, і ўводзьце тэкст. Перацягніце маркер або цягніце правай кнопкай, каб перамясціць тэкст; націсніце Esc, каб завяршыць.',
      'line_curve': 'Пацягніце, каб намаляваць лінію. Цягніце маркеры, каб выгнуць яе, і націсніце Enter, каб завяршыць.',
      'rectangle': 'Пацягніце, каб намаляваць прамавугольнік. Утрымлівайце Shift, каб атрымаць квадрат.',
      'rounded_rectangle': 'Пацягніце, каб намаляваць скруглены прамавугольнік. Утрымлівайце Shift, каб атрымаць квадрат.',
      'ellipse': 'Пацягніце, каб намаляваць эліпс. Утрымлівайце Shift, каб атрымаць круг.',
      'freeform_shape': 'Пацягніце, каб намаляваць замкнёную адвольную фігуру.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Радыус',
      'angle': 'Вугал',
      'distance': 'Адлегласць',
      'centered': 'Ад цэнтра',
      'amount': 'Велічыня',
      'intensity': 'Інтэнсіўнасць',
      'saturation': 'Насычанасць',
      'coverage': 'Пакрыццё',
      'seed': 'Зерне',
      'percentile': 'Працэнтыль',
      'cell_size': 'Памер клеткі',
      'brush_size': 'Памер пэндзля',
      'coarseness': 'Грубасць',
      'thickness': 'Таўшчыня',
      'brightness': 'Яркасць',
      'contrast': 'Кантраст',
      'hue': 'Адценне',
      'lightness': 'Светлата',
      'red': 'Чырвоны',
      'green': 'Зялёны',
      'blue': 'Сіні',
      'input_low': 'Уваход: мінімум',
      'input_high': 'Уваход: максімум',
      'output_low': 'Выхад: мінімум',
      'output_high': 'Выхад: максімум',
      'gamma': 'Гама',
      'ink_outline': 'Контур тушшу',
      'coloring': 'Афарбоўка',
      'tip_size': 'Памер грыфеля',
      'color_range': 'Дыяпазон колераў',
      'fragments': 'Фрагменты',
      'rotation': 'Паварот',
      'offset_x': 'Зрух X',
      'offset_y': 'Зрух Y',
      'quality': 'Якасць',
      'threshold': 'Парог',
      'scale': 'Маштаб',
      'refraction': 'Праламленне',
      'roughness': 'Шурпатасць',
      'tension': 'Нацяжэнне',
      'max_scatter': 'Максімальнае рассейванне',
      'min_scatter': 'Мінімальнае рассейванне',
      'samples': 'Колькасць выбарак',
      'edge_behavior': 'Паводзіны на краях',
      'tile_size': 'Памер пліткі',
      'curvature': 'Крывізна',
      'size': 'Памер',
      'strength': 'Сіла',
      'tolerance': 'Допуск',
      'softness': 'Мяккасць',
      'lighting': 'Асвятленне',
      'warmth': 'Цеплыня',
      'power': 'Магутнасць',
      'blend_mode': 'Рэжым змешвання',
      'factor': 'Множнік',
      'zoom': 'Набліжэнне',
      'invert_colors': 'Інвертаваць колеры',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Звычайны',
      'multiply': 'Множанне',
      'additive': 'Складанне',
      'colorBurn': 'Зацямненне асновы',
      'colorDodge': 'Асвятленне асновы',
      'reflect': 'Адбіццё',
      'glow': 'Ззянне',
      'overlay': 'Перакрыццё',
      'difference': 'Розніца',
      'negation': 'Адмаўленне',
      'lighten': 'Замена светлым',
      'darken': 'Замена цёмным',
      'screen': 'Экран',
      'xor': 'Выключнае АБО',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Не хапае памяці для відарыса.',
      'invalid_size': 'Недапушчальны памер відарыса.',
      'layer_index': 'Такога пласта няма.',
      'last_layer': 'Апошні пласт нельга выдаліць.',
      'no_layer_below': 'Пад гэтым пластом няма пласта для аб\'яднання.',
      'edit_in_progress': 'Спачатку завяршыце бягучае дзеянне.',
      'no_edit': 'Няма незавершанага дзеяння.',
      'no_selection': 'Нічога не вылучана.',
      'nothing_lifted': 'Няма паднятых пікселяў.',
      'invalid_parameter': 'Значэнне па-за дапушчальнымі межамі.',
      'io': 'Не ўдалося прачытаць або запісаць файл.',
      'decode': 'Не ўдалося прачытаць відарыс.',
      'encode': 'Не ўдалося запісаць відарыс.',
      'open_raster': 'Файл OpenRaster пашкоджаны.',
      'palette': 'Файл палітры пашкоджаны.',
      'cancelled': 'Вылічэнне скасавана.',
      'other': 'Адбылася памылка.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Не ўдалося прачытаць або запісаць файл.';

  @override
  String get failureInvalidData => 'Не ўдалося прачытаць даныя.';

  @override
  String get failureUnknown => 'Адбылася нечаканая памылка.';

  @override
  String get panelTools => 'Інструменты';

  @override
  String get panelHistory => 'Гісторыя';

  @override
  String get panelLayers => 'Пласты';

  @override
  String get panelColors => 'Колеры';

  @override
  String get panelHide => 'Схаваць';

  @override
  String get colorsPrimary => 'Асноўны';

  @override
  String get colorsSecondary => 'Дадатковы';

  @override
  String get colorsPrimaryHint => 'Асноўны колер: ім малюе левая кнопка мышы';

  @override
  String get colorsSecondaryHint =>
      'Дадатковы колер: ім малюе правая кнопка мышы';

  @override
  String get colorsSwap => 'Памяняць колеры месцамі (X)';

  @override
  String get colorsReset => 'Скінуць да чорнага і белага';

  @override
  String get colorsMore => 'Больш';

  @override
  String get colorsLess => 'Менш';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Альфа';

  @override
  String get colorsHue => 'А';

  @override
  String get colorsSat => 'Н';

  @override
  String get colorsValue => 'Я';

  @override
  String get colorsRed => 'R';

  @override
  String get colorsGreen => 'G';

  @override
  String get colorsBlue => 'B';

  @override
  String get colorsPaletteHint =>
      'Пстрычка левай кнопкай задае асноўны колер, правай — дадатковы';

  @override
  String get settingWidth => 'Шырыня';

  @override
  String get settingHardness => 'Цвёрдасць';

  @override
  String get settingAntialias => 'Згладжванне';

  @override
  String get settingAlphaBlending => 'Альфа-змешванне';

  @override
  String get settingTolerance => 'Допуск';

  @override
  String get settingFloodMode => 'Распаўсюджванне';

  @override
  String get floodLocal => 'Сумежныя';

  @override
  String get floodGlobal => 'Увесь відарыс';

  @override
  String get settingSelectionMode => 'Рэжым вылучэння';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Замяніць',
      'union': 'Дадаць',
      'exclude': 'Адняць',
      'xor': 'Выключнае АБО',
      'intersect': 'Перасячы',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Памер вылучэння';

  @override
  String get drawNormal => 'Адвольны';

  @override
  String get drawFixedRatio => 'Сталыя прапорцыі';

  @override
  String get drawFixedSize => 'Сталы памер';

  @override
  String get settingResampling => 'Перадыскрэтызацыя';

  @override
  String get resamplingNearest => 'Найбліжэйшы сусед';

  @override
  String get resamplingBilinear => 'Білінейная';

  @override
  String get settingGradient => 'Тып';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Лінейны',
      'linearReflected': 'Лінейны люстраны',
      'diamond': 'Ромб',
      'radial': 'Радыяльны',
      'conical': 'Канічны',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Колер';

  @override
  String get gradientTransparency => 'Празрыстасць';

  @override
  String get settingShape => 'Стыль фігуры';

  @override
  String get shapeOutline => 'Контур';

  @override
  String get shapeInterior => 'Заліўка';

  @override
  String get shapeBoth => 'Контур і заліўка';

  @override
  String get settingAfterPick => 'Пасля выбару колеру';

  @override
  String get pickStay => 'Пакінуць гэты інструмент';

  @override
  String get pickPrevious => 'Перайсці да папярэдняга інструмента';

  @override
  String get pickPencil => 'Перайсці да Алоўка';

  @override
  String get settingNone => 'Гэты інструмент не мае параметраў.';

  @override
  String toolUnavailable(String name) {
    return 'Інструмент «$name» пакуль недаступны';
  }

  @override
  String get historyFirst => 'Перайсці да першага кроку';

  @override
  String get historyUndo => 'Скасаваць';

  @override
  String get historyRedo => 'Паўтарыць';

  @override
  String get historyLast => 'Перайсці да апошняга кроку';

  @override
  String get historyNewImage => 'Новы відарыс';

  @override
  String get historyOpenImage => 'Адкрыццё відарыса';

  @override
  String get layerVisible => 'Паказаць або схаваць пласт';

  @override
  String get layerBackground => 'Фон';

  @override
  String get layerName => 'Назва';

  @override
  String get layerOpacity => 'Непразрыстасць';

  @override
  String get layerBlendMode => 'Рэжым змешвання';

  @override
  String get ok => 'Добра';

  @override
  String get cancel => 'Скасаваць';

  @override
  String get save => 'Захаваць';

  @override
  String get dontSave => 'Не захоўваць';

  @override
  String get keepCanvas => 'Пакінуць палатно';

  @override
  String get expandCanvas => 'Павялічыць палатно';

  @override
  String get width => 'Шырыня';

  @override
  String get height => 'Вышыня';

  @override
  String get pixels => 'пікселяў';

  @override
  String get newImageTitle => 'Новы відарыс';

  @override
  String get resizeTitle => 'Памер відарыса';

  @override
  String get canvasSizeTitle => 'Памер палатна';

  @override
  String get keepRatio => 'Захоўваць прапорцыі';

  @override
  String get anchor => 'Прывязка';

  @override
  String sizeTooLarge(int max) {
    return 'Відарыс завялікі: найбольшы памер — $max мегапікселяў.';
  }

  @override
  String get unsavedTitle => 'Захаваць змены?';

  @override
  String unsavedMessage(String name) {
    return '«$name» мае незахаваныя змены.';
  }

  @override
  String get flattenTitle => 'Звесці пласты?';

  @override
  String flattenMessage(String format) {
    return 'Фармат $format не падтрымлівае пласты, таму відарыс будзе зведзены ў адзін пласт. Гэта дзеянне можна скасаваць у акне «Гісторыя».';
  }

  @override
  String get flatten => 'Звесці';

  @override
  String get jpegQualityTitle => 'Якасць JPEG';

  @override
  String get quality => 'Якасць';

  @override
  String get largerTitle => 'Відарыс большы за палатно';

  @override
  String get largerMessage => 'Павялічыць палатно, каб змясціць відарыс?';

  @override
  String get reseed => 'Новае зерне';

  @override
  String get rendering => 'Вылічэнне…';

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
    return 'Адкрыццё $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Захаванне $name…';
  }

  @override
  String savedTo(String name) {
    return 'Захавана: $name';
  }

  @override
  String get dropHere => 'Адпусціце, каб адкрыць';

  @override
  String get dropHint => 'Кожны файл адкрыецца як новы відарыс';

  @override
  String get imagesList => 'Адкрытыя відарысы';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Рэдактар растравых відарысаў з пластамі. Каб выбраць інструмент, націсніце літару; паўторнае націсканне S, M або O пераключае роднасныя інструменты. [ і ] змяняюць шырыню пэндзля, X мяняе колеры месцамі, утрыманне прабелу зрушвае выгляд, Ctrl+кола мышы змяняе маштаб, а F5–F8 паказваюць і хаваюць вокны.';

  @override
  String get settingLineStart => 'Пачатак';

  @override
  String get settingLineEnd => 'Канец';

  @override
  String get settingDash => 'Штрых';

  @override
  String get settingSwapSize => 'Памяняць шырыню і вышыню';

  @override
  String get settingLineStyle => 'Стыль';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Плоскі',
      'arrow': 'Стрэлка',
      'arrowFilled': 'Запоўненая стрэлка',
      'rounded': 'Скруглены',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Суцэльная',
      'dash': 'Рыскі',
      'dashDot': 'Рыска-кропка',
      'dashDotDot': 'Рыска-дзве кропкі',
      'dot': 'Кропкі',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Шрыфт';

  @override
  String get settingFontSize => 'Памер';

  @override
  String get textBold => 'Тлусты';

  @override
  String get textItalic => 'Курсіў';

  @override
  String get textUnderline => 'Падкрэслены';

  @override
  String get textStrikeout => 'Закрэслены';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Па левым краі',
      'center': 'Па цэнтры',
      'right': 'Па правым краі',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Відарысы';
}
