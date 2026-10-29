// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Без назви $number';
  }

  @override
  String get menuFile => 'Файл';

  @override
  String get menuEdit => 'Правка';

  @override
  String get menuView => 'Вигляд';

  @override
  String get menuImage => 'Зображення';

  @override
  String get menuLayers => 'Шари';

  @override
  String get menuAdjustments => 'Коригування';

  @override
  String get menuEffects => 'Ефекти';

  @override
  String get menuOpenRecent => 'Нещодавні';

  @override
  String get menuRecentEmpty => 'Нещодавніх файлів немає';

  @override
  String get menuTheme => 'Тема';

  @override
  String get menuSettings => 'Налаштування';

  @override
  String get unitsPixels => 'пкс';

  @override
  String get themeSystem => 'Як у системі';

  @override
  String get themeDark => 'Темна';

  @override
  String get themeLight => 'Світла';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Створити…',
      'open': 'Відкрити…',
      'close': 'Закрити',
      'save': 'Зберегти',
      'save_as': 'Зберегти як…',
      'exit': 'Вийти',
      'undo': 'Скасувати',
      'redo': 'Повторити',
      'cut': 'Вирізати',
      'copy': 'Копіювати',
      'paste': 'Вставити',
      'paste_into_new_layer': 'Вставити в новий шар',
      'paste_into_new_image': 'Вставити в нове зображення',
      'erase_selection': 'Стерти виділене',
      'fill_selection': 'Залити виділене',
      'invert_selection': 'Обернути виділення',
      'select_all': 'Виділити все',
      'deselect': 'Зняти виділення',
      'zoom_in': 'Наблизити',
      'zoom_out': 'Віддалити',
      'zoom_to_window': 'За розміром вікна',
      'zoom_to_selection': 'За виділенням',
      'actual_size': 'Справжній розмір',
      'pixel_grid': 'Піксельна сітка',
      'rulers': 'Лінійки',
      'crop_to_selection': 'Обрізати за виділенням',
      'resize': 'Змінити розмір…',
      'canvas_size': 'Розмір полотна…',
      'flip_horizontal': 'Віддзеркалити по горизонталі',
      'flip_vertical': 'Віддзеркалити по вертикалі',
      'rotate90_cw': 'Повернути на 90° за годинниковою',
      'rotate90_ccw': 'Повернути на 90° проти годинникової',
      'rotate180': 'Повернути на 180°',
      'flatten': 'Звести шари',
      'add_layer': 'Додати шар',
      'delete_layer': 'Видалити шар',
      'duplicate_layer': 'Дублювати шар',
      'merge_layer_down': 'Злити з нижнім',
      'import_from_file': 'Імпортувати з файлу…',
      'flip_layer_horizontal': 'Віддзеркалити шар по горизонталі',
      'flip_layer_vertical': 'Віддзеркалити шар по вертикалі',
      'move_layer_up': 'Підняти шар',
      'move_layer_down': 'Опустити шар',
      'layer_properties': 'Властивості шару…',
      'adjust_auto_level': 'Авторівні',
      'adjust_black_and_white': 'Чорно-біле',
      'adjust_brightness_contrast': 'Яскравість / контраст…',
      'adjust_curves': 'Криві…',
      'adjust_hue_saturation': 'Відтінок / насиченість…',
      'adjust_invert_colors': 'Обернути кольори',
      'adjust_levels': 'Рівні…',
      'adjust_posterize': 'Постеризація…',
      'adjust_sepia': 'Сепія',
      'repeat_effect': 'Повторити ефект',
      'effect_oil_painting': 'Олійний живопис…',
      'effect_gaussian_blur': 'Розмиття Гаусса…',
      'effect_motion_blur': 'Розмиття в русі…',
      'effect_pixelate': 'Пікселізація…',
      'effect_add_noise': 'Шум…',
      'effect_median': 'Медіана…',
      'effect_sharpen': 'Різкість…',
      'effect_edge_detect': 'Виявлення країв…',
      'effect_emboss': 'Тиснення…',
      'effect_outline': 'Контур…',
      'toggle_tools': 'Інструменти',
      'toggle_history': 'Історія',
      'toggle_layers': 'Шари',
      'toggle_colors': 'Кольори',
      'next_image': 'Наступне зображення',
      'previous_image': 'Попереднє зображення',
      'help': 'Довідка',
      'effect_ink_sketch': 'Ескіз тушшю…',
      'effect_pencil_sketch': 'Олівцевий ескіз…',
      'effect_fragment': 'Фрагменти…',
      'effect_radial_blur': 'Радіальне розмиття…',
      'effect_surface_blur': 'Розмиття поверхні…',
      'effect_unfocus': 'Розфокус…',
      'effect_zoom_blur': 'Розмиття наближенням…',
      'effect_bulge': 'Опуклість…',
      'effect_dents': 'Вм\'ятини…',
      'effect_frosted_glass': 'Матове скло…',
      'effect_polar_inversion': 'Полярна інверсія…',
      'effect_tile_reflection': 'Відбиття плиток…',
      'effect_twist': 'Скручування…',
      'effect_reduce_noise': 'Зменшення шуму…',
      'effect_glow': 'Сяйво…',
      'effect_red_eye_removal': 'Усунення червоних очей…',
      'effect_soften_portrait': 'М\'який портрет…',
      'effect_clouds': 'Хмари…',
      'effect_julia_fractal': 'Фрактал Жюліа…',
      'effect_mandelbrot_fractal': 'Фрактал Мандельброта…',
      'effect_relief': 'Рельєф…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dialogTitle(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'adjust_brightness_contrast': 'Яскравість / контраст',
      'adjust_curves': 'Криві',
      'adjust_hue_saturation': 'Відтінок / насиченість',
      'adjust_levels': 'Рівні',
      'adjust_posterize': 'Постеризація',
      'effect_oil_painting': 'Олійний живопис',
      'effect_gaussian_blur': 'Розмиття Гаусса',
      'effect_motion_blur': 'Розмиття в русі',
      'effect_pixelate': 'Пікселізація',
      'effect_add_noise': 'Шум',
      'effect_median': 'Медіана',
      'effect_sharpen': 'Різкість',
      'effect_edge_detect': 'Виявлення країв',
      'effect_emboss': 'Тиснення',
      'effect_outline': 'Контур',
      'layer_properties': 'Властивості шару',
      'effect_ink_sketch': 'Ескіз тушшю',
      'effect_pencil_sketch': 'Олівцевий ескіз',
      'effect_fragment': 'Фрагменти',
      'effect_radial_blur': 'Радіальне розмиття',
      'effect_surface_blur': 'Розмиття поверхні',
      'effect_unfocus': 'Розфокус',
      'effect_zoom_blur': 'Розмиття наближенням',
      'effect_bulge': 'Опуклість',
      'effect_dents': 'Вм\'ятини',
      'effect_frosted_glass': 'Матове скло',
      'effect_polar_inversion': 'Полярна інверсія',
      'effect_tile_reflection': 'Відбиття плиток',
      'effect_twist': 'Скручування',
      'effect_reduce_noise': 'Зменшення шуму',
      'effect_glow': 'Сяйво',
      'effect_red_eye_removal': 'Усунення червоних очей',
      'effect_soften_portrait': 'М\'який портрет',
      'effect_clouds': 'Хмари',
      'effect_julia_fractal': 'Фрактал Жюліа',
      'effect_mandelbrot_fractal': 'Фрактал Мандельброта',
      'effect_relief': 'Рельєф',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Мистецькі',
      'blurs': 'Розмиття',
      'distort': 'Спотворення',
      'noise': 'Шум',
      'photo': 'Фото',
      'stylize': 'Стилізація',
      'render': 'Візуалізація',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Прямокутне виділення',
      'move_selected_pixels': 'Переміщення виділених пікселів',
      'lasso_select': 'Ласо',
      'move_selection': 'Переміщення виділення',
      'ellipse_select': 'Еліптичне виділення',
      'zoom': 'Масштаб',
      'magic_wand': 'Чарівна паличка',
      'pan': 'Рука',
      'paint_bucket': 'Заливка',
      'gradient': 'Градієнт',
      'paintbrush': 'Пензель',
      'eraser': 'Гумка',
      'pencil': 'Олівець',
      'color_picker': 'Піпетка',
      'clone_stamp': 'Штамп',
      'recolor': 'Перефарбування',
      'text': 'Текст',
      'line_curve': 'Лінія / крива',
      'rectangle': 'Прямокутник',
      'rounded_rectangle': 'Заокруглений прямокутник',
      'ellipse': 'Еліпс',
      'freeform_shape': 'Довільна фігура',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select':
          'Протягніть, щоб виділити прямокутник. Shift — квадрат.',
      'move_selected_pixels': 'Перетягніть виділене, щоб перемістити: права кнопка повертає, ручки масштабують. Ctrl лишає копію, стрілки зсувають.',
      'lasso_select': 'Протягніть, щоб обвести виділення.',
      'move_selection':
          'Перетягніть контур виділення. Пікселі лишаються на місці.',
      'ellipse_select': 'Протягніть, щоб виділити еліпс. Shift — коло.',
      'zoom': 'Ліве клацання наближає, праве віддаляє, рамка наближає до себе.',
      'magic_wand': 'Клацніть, щоб виділити ділянку схожого кольору. Shift — по всьому зображенню.',
      'pan': 'Перетягніть, щоб зсунути вигляд.',
      'paint_bucket':
          'Ліве клацання заливає основним кольором, праве — додатковим.',
      'gradient': 'Протягніть, щоб намалювати градієнт. Ручки його змінюють, Enter завершує.',
      'paintbrush': 'Ліва кнопка малює основним кольором, права — додатковим.',
      'eraser': 'Протягніть, щоб стерти до прозорого.',
      'pencil': 'Малює лінії в один піксель без згладжування.',
      'color_picker': 'Ліве клацання бере основний колір, праве — додатковий.',
      'clone_stamp':
          'Ctrl+клацання задає джерело, далі протягніть, щоб малювати з нього.',
      'recolor': 'Замінює додатковий колір основним там, де малюєте. Ctrl+клацання бере колір.',
      'text': 'Клацніть, щоб поставити курсор, і друкуйте. Права кнопка чи ручка рухають текст, Esc завершує.',
      'line_curve': 'Протягніть, щоб намалювати лінію. Ручки її вигинають, Enter завершує.',
      'rectangle': 'Протягніть, щоб намалювати прямокутник. Shift — квадрат.',
      'rounded_rectangle': 'Протягніть, щоб намалювати заокруглений прямокутник. Shift — квадрат.',
      'ellipse': 'Протягніть, щоб намалювати еліпс. Shift — коло.',
      'freeform_shape': 'Протягніть, щоб намалювати замкнену довільну фігуру.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Радіус',
      'angle': 'Кут',
      'distance': 'Відстань',
      'centered': 'По центру',
      'amount': 'Сила',
      'intensity': 'Інтенсивність',
      'saturation': 'Насиченість',
      'coverage': 'Покриття',
      'seed': 'Зерно',
      'percentile': 'Перцентиль',
      'cell_size': 'Розмір клітинки',
      'brush_size': 'Розмір пензля',
      'coarseness': 'Грубість',
      'thickness': 'Товщина',
      'brightness': 'Яскравість',
      'contrast': 'Контраст',
      'hue': 'Відтінок',
      'lightness': 'Світлота',
      'red': 'Червоний',
      'green': 'Зелений',
      'blue': 'Синій',
      'input_low': 'Вхід: темне',
      'input_high': 'Вхід: світле',
      'output_low': 'Вихід: темне',
      'output_high': 'Вихід: світле',
      'gamma': 'Гама',
      'ink_outline': 'Контур тушшю',
      'coloring': 'Забарвлення',
      'tip_size': 'Розмір вістря',
      'color_range': 'Діапазон кольору',
      'fragments': 'Фрагменти',
      'rotation': 'Поворот',
      'offset_x': 'Зсув X',
      'offset_y': 'Зсув Y',
      'quality': 'Якість',
      'threshold': 'Поріг',
      'scale': 'Масштаб',
      'refraction': 'Заломлення',
      'roughness': 'Шорсткість',
      'tension': 'Натяг',
      'max_scatter': 'Найбільший розкид',
      'min_scatter': 'Найменший розкид',
      'samples': 'Відліки',
      'edge_behavior': 'Поведінка на краю',
      'tile_size': 'Розмір плитки',
      'curvature': 'Кривизна',
      'size': 'Розмір',
      'strength': 'Сила',
      'tolerance': 'Допуск',
      'softness': 'М\'якість',
      'lighting': 'Освітлення',
      'warmth': 'Теплота',
      'power': 'Потужність',
      'blend_mode': 'Режим змішування',
      'factor': 'Множник',
      'zoom': 'Наближення',
      'invert_colors': 'Обернути кольори',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Звичайне',
      'multiply': 'Множення',
      'additive': 'Додавання',
      'colorBurn': 'Затемнення основи',
      'colorDodge': 'Освітлення основи',
      'reflect': 'Відбиття',
      'glow': 'Світіння',
      'overlay': 'Перекриття',
      'difference': 'Різниця',
      'negation': 'Заперечення',
      'lighten': 'Світліше',
      'darken': 'Темніше',
      'screen': 'Екран',
      'xor': 'Виключне АБО',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Для зображення забракло пам\'яті.',
      'invalid_size': 'Такого розміру зображення бути не може.',
      'layer_index': 'Такого шару немає.',
      'last_layer': 'Останній шар видалити не можна.',
      'no_layer_below': 'Під цим шаром немає шару, з яким злити.',
      'edit_in_progress': 'Спершу завершіть поточну дію.',
      'no_edit': 'Немає дії, яку завершити.',
      'no_selection': 'Нічого не виділено.',
      'nothing_lifted': 'Нічого не піднято.',
      'invalid_parameter': 'Значення поза межами.',
      'io': 'Файл не вдалося прочитати чи записати.',
      'decode': 'Зображення не вдалося прочитати.',
      'encode': 'Зображення не вдалося записати.',
      'open_raster': 'Файл OpenRaster пошкоджено.',
      'palette': 'Файл палітри пошкоджено.',
      'cancelled': 'Обчислення скасовано.',
      'other': 'Сталася помилка.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Файл не вдалося прочитати чи записати.';

  @override
  String get failureInvalidData => 'Дані не вдалося прочитати.';

  @override
  String get failureUnknown => 'Сталася неочікувана помилка.';

  @override
  String get panelTools => 'Інструменти';

  @override
  String get panelHistory => 'Історія';

  @override
  String get panelLayers => 'Шари';

  @override
  String get panelColors => 'Кольори';

  @override
  String get panelHide => 'Сховати';

  @override
  String get colorsPrimary => 'Основний';

  @override
  String get colorsSecondary => 'Додатковий';

  @override
  String get colorsPrimaryHint => 'Основний колір: ним малює ліва кнопка';

  @override
  String get colorsSecondaryHint => 'Додатковий колір: ним малює права кнопка';

  @override
  String get colorsSwap => 'Обміняти кольори (X)';

  @override
  String get colorsReset => 'Чорний і білий';

  @override
  String get colorsMore => 'Більше';

  @override
  String get colorsLess => 'Менше';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Альфа';

  @override
  String get colorsHue => 'Т';

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
      'Ліва кнопка — основний колір, права — додатковий';

  @override
  String get settingWidth => 'Ширина';

  @override
  String get settingHardness => 'Твердість';

  @override
  String get settingAntialias => 'Згладжування';

  @override
  String get settingAlphaBlending => 'Змішування альфи';

  @override
  String get settingTolerance => 'Допуск';

  @override
  String get settingFloodMode => 'Поширення';

  @override
  String get floodLocal => 'Суміжні';

  @override
  String get floodGlobal => 'Усе зображення';

  @override
  String get settingSelectionMode => 'Режим виділення';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Замінити',
      'union': 'Додати',
      'exclude': 'Відняти',
      'xor': 'Виключне АБО',
      'intersect': 'Перетнути',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Розмір';

  @override
  String get drawNormal => 'Довільний';

  @override
  String get drawFixedRatio => 'Сталі пропорції';

  @override
  String get drawFixedSize => 'Сталий розмір';

  @override
  String get settingResampling => 'Передискретизація';

  @override
  String get resamplingNearest => 'Найближчий сусід';

  @override
  String get resamplingBilinear => 'Білінійна';

  @override
  String get settingGradient => 'Тип';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Лінійний',
      'linearReflected': 'Лінійний дзеркальний',
      'diamond': 'Ромб',
      'radial': 'Радіальний',
      'conical': 'Конічний',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Колір';

  @override
  String get gradientTransparency => 'Прозорість';

  @override
  String get settingShape => 'Малює';

  @override
  String get shapeOutline => 'Контур';

  @override
  String get shapeInterior => 'Заливка';

  @override
  String get shapeBoth => 'Контур і заливка';

  @override
  String get settingAfterPick => 'Потім';

  @override
  String get pickStay => 'Лишитися';

  @override
  String get pickPrevious => 'Попередній інструмент';

  @override
  String get pickPencil => 'Олівець';

  @override
  String get settingNone => 'Цей інструмент не має параметрів.';

  @override
  String toolUnavailable(String name) {
    return '$name ще не зроблено';
  }

  @override
  String get historyFirst => 'На початок';

  @override
  String get historyUndo => 'Скасувати';

  @override
  String get historyRedo => 'Повторити';

  @override
  String get historyLast => 'У кінець';

  @override
  String get historyNewImage => 'Нове зображення';

  @override
  String get historyOpenImage => 'Відкрите зображення';

  @override
  String get layerVisible => 'Чи показано шар';

  @override
  String get layerBackground => 'Тло';

  @override
  String get layerName => 'Назва';

  @override
  String get layerOpacity => 'Непрозорість';

  @override
  String get layerBlendMode => 'Режим змішування';

  @override
  String get ok => 'Гаразд';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get dontSave => 'Не зберігати';

  @override
  String get keepCanvas => 'Не змінювати';

  @override
  String get expandCanvas => 'Збільшити полотно';

  @override
  String get width => 'Ширина';

  @override
  String get height => 'Висота';

  @override
  String get pixels => 'пікселів';

  @override
  String get newImageTitle => 'Нове зображення';

  @override
  String get resizeTitle => 'Розмір зображення';

  @override
  String get canvasSizeTitle => 'Розмір полотна';

  @override
  String get keepRatio => 'Зберегти пропорції';

  @override
  String get anchor => 'Прив\'язка';

  @override
  String sizeTooLarge(int max) {
    return 'Завелике зображення: не більше $max мегапікселів.';
  }

  @override
  String get unsavedTitle => 'Зберегти зміни?';

  @override
  String unsavedMessage(String name) {
    return '«$name» має незбережені зміни.';
  }

  @override
  String get flattenTitle => 'Звести шари?';

  @override
  String flattenMessage(String format) {
    return 'Формат $format не зберігає шарів: зображення буде зведено в один шар. Скасувати це можна в Історії.';
  }

  @override
  String get flatten => 'Звести';

  @override
  String get jpegQualityTitle => 'Якість JPEG';

  @override
  String get quality => 'Якість';

  @override
  String get largerTitle => 'Зображення більше за полотно';

  @override
  String get largerMessage => 'Збільшити полотно, щоб вмістити його?';

  @override
  String get reseed => 'Інше зерно';

  @override
  String get rendering => 'Обчислення…';

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
    return 'Відкриття $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Збереження $name…';
  }

  @override
  String savedTo(String name) {
    return 'Збережено: $name';
  }

  @override
  String get dropHere => 'Відкрити';

  @override
  String get dropHint => 'Кожен файл відкриється новим зображенням';

  @override
  String get imagesList => 'Відкриті зображення';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Редактор зображень із шарами. Інструменти — літерами (S, M, O перебирають сусідні), [ і ] — ширина пензля, X — обміняти кольори, пробіл — рука, Ctrl+коліщатко — масштаб, F5–F8 — вікна.';

  @override
  String get settingLineStart => 'Початок';

  @override
  String get settingLineEnd => 'Кінець';

  @override
  String get settingDash => 'Штрих';

  @override
  String get settingSwapSize => 'Поміняти ширину й висоту';

  @override
  String get settingLineStyle => 'Стиль';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Плаский',
      'arrow': 'Стрілка',
      'arrowFilled': 'Заповнена стрілка',
      'rounded': 'Заокруглений',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Суцільний',
      'dash': 'Риска',
      'dashDot': 'Риска-крапка',
      'dashDotDot': 'Риска-дві крапки',
      'dot': 'Крапки',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Шрифт';

  @override
  String get settingFontSize => 'Розмір';

  @override
  String get textBold => 'Жирний';

  @override
  String get textItalic => 'Курсив';

  @override
  String get textUnderline => 'Підкреслений';

  @override
  String get textStrikeout => 'Закреслений';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Ліворуч',
      'center': 'По центру',
      'right': 'Праворуч',
      'other': '',
    });
    return '$_temp0';
  }
}
