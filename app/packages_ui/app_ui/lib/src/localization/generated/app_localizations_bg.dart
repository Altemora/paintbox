// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Без име $number';
  }

  @override
  String get menuFile => 'Файл';

  @override
  String get menuEdit => 'Редактиране';

  @override
  String get menuView => 'Изглед';

  @override
  String get menuImage => 'Изображение';

  @override
  String get menuLayers => 'Слоеве';

  @override
  String get menuAdjustments => 'Корекции';

  @override
  String get menuEffects => 'Ефекти';

  @override
  String get menuOpenRecent => 'Последни файлове';

  @override
  String get menuRecentEmpty => 'Няма последни файлове';

  @override
  String get menuTheme => 'Тема';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get menuAccent => 'Акцентен цвят';

  @override
  String get menuLanguage => 'Език';

  @override
  String get languageSystem => 'Според системата';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Син',
      'green': 'Зелен',
      'amber': 'Кехлибарен',
      'purple': 'Лилав',
      'red': 'Червен',
      'gray': 'Сив',
      'custom': 'Друг…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Друг акцентен цвят';

  @override
  String get unitsPixels => 'пкс';

  @override
  String get themeSystem => 'Според системата';

  @override
  String get themeDark => 'Тъмна';

  @override
  String get themeLight => 'Светла';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Създаване…',
      'open': 'Отваряне…',
      'close': 'Затваряне',
      'save': 'Запазване',
      'save_as': 'Запазване като…',
      'exit': 'Изход',
      'undo': 'Отмяна',
      'redo': 'Повторение',
      'cut': 'Изрязване',
      'copy': 'Копиране',
      'paste': 'Поставяне',
      'paste_into_new_layer': 'Поставяне в нов слой',
      'paste_into_new_image': 'Поставяне в ново изображение',
      'erase_selection': 'Изтриване на селекцията',
      'fill_selection': 'Запълване на селекцията',
      'invert_selection': 'Обръщане на селекцията',
      'select_all': 'Избиране на всичко',
      'deselect': 'Премахване на селекцията',
      'zoom_in': 'Увеличаване',
      'zoom_out': 'Намаляване',
      'zoom_to_window': 'Побиране в прозореца',
      'zoom_to_selection': 'Мащабиране до селекцията',
      'actual_size': 'Действителен размер',
      'pixel_grid': 'Пикселна мрежа',
      'rulers': 'Линийки',
      'crop_to_selection': 'Изрязване до селекцията',
      'resize': 'Преоразмеряване на изображението…',
      'canvas_size': 'Размер на платното…',
      'flip_horizontal': 'Хоризонтално обръщане',
      'flip_vertical': 'Вертикално обръщане',
      'rotate90_cw': 'Завъртане на 90° по часовниковата стрелка',
      'rotate90_ccw': 'Завъртане на 90° обратно на часовниковата стрелка',
      'rotate180': 'Завъртане на 180°',
      'flatten': 'Сплескване',
      'add_layer': 'Добавяне на нов слой',
      'delete_layer': 'Изтриване на слоя',
      'duplicate_layer': 'Дублиране на слоя',
      'merge_layer_down': 'Сливане с долния слой',
      'import_from_file': 'Внасяне от файл…',
      'flip_layer_horizontal': 'Хоризонтално обръщане на слоя',
      'flip_layer_vertical': 'Вертикално обръщане на слоя',
      'move_layer_up': 'Преместване на слоя нагоре',
      'move_layer_down': 'Преместване на слоя надолу',
      'layer_properties': 'Свойства на слоя…',
      'adjust_auto_level': 'Автоматични нива',
      'adjust_black_and_white': 'Черно-бяло',
      'adjust_brightness_contrast': 'Яркост / контраст…',
      'adjust_curves': 'Криви…',
      'adjust_hue_saturation': 'Тон / наситеност…',
      'adjust_invert_colors': 'Инвертиране на цветовете',
      'adjust_levels': 'Нива…',
      'adjust_posterize': 'Постеризация…',
      'adjust_sepia': 'Сепия',
      'repeat_effect': 'Повтаряне на ефекта',
      'effect_oil_painting': 'Маслена живопис…',
      'effect_gaussian_blur': 'Гаусово замъгляване…',
      'effect_motion_blur': 'Замъгляване при движение…',
      'effect_pixelate': 'Пикселизиране…',
      'effect_add_noise': 'Добавяне на шум…',
      'effect_median': 'Медиана…',
      'effect_sharpen': 'Изостряне…',
      'effect_edge_detect': 'Откриване на ръбове…',
      'effect_emboss': 'Щамповане…',
      'effect_outline': 'Контур…',
      'toggle_tools': 'Инструменти',
      'toggle_history': 'История',
      'toggle_layers': 'Слоеве',
      'toggle_colors': 'Цветове',
      'next_image': 'Следващо изображение',
      'previous_image': 'Предишно изображение',
      'help': 'Помощ',
      'effect_ink_sketch': 'Скица с мастило…',
      'effect_pencil_sketch': 'Скица с молив…',
      'effect_fragment': 'Фрагментиране…',
      'effect_radial_blur': 'Радиално замъгляване…',
      'effect_surface_blur': 'Повърхностно замъгляване…',
      'effect_unfocus': 'Разфокусиране…',
      'effect_zoom_blur': 'Замъгляване с мащабиране…',
      'effect_bulge': 'Издуване…',
      'effect_dents': 'Вдлъбнатини…',
      'effect_frosted_glass': 'Матово стъкло…',
      'effect_polar_inversion': 'Полярна инверсия…',
      'effect_tile_reflection': 'Отражение в плочки…',
      'effect_twist': 'Усукване…',
      'effect_reduce_noise': 'Намаляване на шума…',
      'effect_glow': 'Сияние…',
      'effect_red_eye_removal': 'Премахване на червени очи…',
      'effect_soften_portrait': 'Омекотяване на портрет…',
      'effect_clouds': 'Облаци…',
      'effect_julia_fractal': 'Фрактал на Жулиа…',
      'effect_mandelbrot_fractal': 'Фрактал на Манделброт…',
      'effect_relief': 'Релеф…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Художествени',
      'blurs': 'Замъгляване',
      'distort': 'Изкривяване',
      'noise': 'Шум',
      'photo': 'Фото',
      'stylize': 'Стилизиране',
      'render': 'Генериране',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Правоъгълна селекция',
      'move_selected_pixels': 'Преместване на избраните пиксели',
      'lasso_select': 'Ласо',
      'move_selection': 'Преместване на селекцията',
      'ellipse_select': 'Елипсовидна селекция',
      'zoom': 'Лупа',
      'magic_wand': 'Вълшебна пръчка',
      'pan': 'Ръка',
      'paint_bucket': 'Кофа с боя',
      'gradient': 'Градиент',
      'paintbrush': 'Четка',
      'eraser': 'Гума',
      'pencil': 'Молив',
      'color_picker': 'Пипета',
      'clone_stamp': 'Клониращ печат',
      'recolor': 'Пребоядисване',
      'text': 'Текст',
      'line_curve': 'Линия / крива',
      'rectangle': 'Правоъгълник',
      'rounded_rectangle': 'Заоблен правоъгълник',
      'ellipse': 'Елипса',
      'freeform_shape': 'Свободна фигура',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Плъзнете, за да изберете правоъгълник. Задръжте Shift, за да получите квадрат.',
      'move_selected_pixels': 'Плъзнете селекцията, за да я преместите. Плъзнете с десния бутон, за да я завъртите, или плъзнете манипулаторите, за да я мащабирате. Ctrl оставя копие, а клавишите със стрелки я придвижват леко.',
      'lasso_select': 'Плъзнете, за да очертаете контура на селекцията.',
      'move_selection': 'Плъзнете контура на селекцията, за да го преместите. Пикселите остават на място.',
      'ellipse_select': 'Плъзнете, за да изберете елипса. Задръжте Shift, за да получите кръг.',
      'zoom': 'Щракнете с левия бутон, за да увеличите, или с десния, за да намалите. Очертайте рамка, за да увеличите областта в нея.',
      'magic_wand': 'Щракнете върху цвят, за да изберете областта около него. Задръжте Shift, за да изберете този цвят в цялото изображение.',
      'pan': 'Плъзнете, за да преместите изгледа.',
      'paint_bucket': 'Щракването с левия бутон запълва с основния цвят, а с десния — с вторичния.',
      'gradient': 'Плъзнете, за да начертаете градиент. Плъзнете манипулаторите, за да го настроите, и натиснете Enter, за да завършите.',
      'paintbrush':
          'Левият бутон рисува с основния цвят, а десният — с вторичния.',
      'eraser': 'Плъзнете, за да изтриете до прозрачност.',
      'pencil': 'Чертае линии с дебелина един пиксел без изглаждане.',
      'color_picker': 'Щракването с левия бутон взема основния цвят, а с десния — вторичния.',
      'clone_stamp': 'Щракнете със задържан Ctrl, за да зададете източника, след което плъзнете, за да рисувате от него.',
      'recolor': 'Заменя вторичния цвят с основния там, където рисувате. Щракването със задържан Ctrl взема цвят.',
      'text': 'Щракнете, за да поставите курсора, и въведете текста. Плъзнете манипулатора или плъзнете с десния бутон, за да преместите текста; натиснете Esc, за да завършите.',
      'line_curve': 'Плъзнете, за да начертаете линия. Плъзнете манипулаторите, за да я огънете, и натиснете Enter, за да завършите.',
      'rectangle': 'Плъзнете, за да начертаете правоъгълник. Задръжте Shift, за да получите квадрат.',
      'rounded_rectangle': 'Плъзнете, за да начертаете заоблен правоъгълник. Задръжте Shift, за да получите квадрат.',
      'ellipse': 'Плъзнете, за да начертаете елипса. Задръжте Shift, за да получите кръг.',
      'freeform_shape': 'Плъзнете, за да начертаете затворена свободна фигура.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Радиус',
      'angle': 'Ъгъл',
      'distance': 'Разстояние',
      'centered': 'Центрирано',
      'amount': 'Количество',
      'intensity': 'Интензивност',
      'saturation': 'Наситеност',
      'coverage': 'Покритие',
      'seed': 'Зърно',
      'percentile': 'Перцентил',
      'cell_size': 'Размер на клетката',
      'brush_size': 'Размер на четката',
      'coarseness': 'Грубост',
      'thickness': 'Дебелина',
      'brightness': 'Яркост',
      'contrast': 'Контраст',
      'hue': 'Тон',
      'lightness': 'Светлота',
      'red': 'Червено',
      'green': 'Зелено',
      'blue': 'Синьо',
      'input_low': 'Вход: минимум',
      'input_high': 'Вход: максимум',
      'output_low': 'Изход: минимум',
      'output_high': 'Изход: максимум',
      'gamma': 'Гама',
      'ink_outline': 'Мастилен контур',
      'coloring': 'Оцветяване',
      'tip_size': 'Размер на върха на молива',
      'color_range': 'Цветови обхват',
      'fragments': 'Фрагменти',
      'rotation': 'Завъртане',
      'offset_x': 'Отместване по X',
      'offset_y': 'Отместване по Y',
      'quality': 'Качество',
      'threshold': 'Праг',
      'scale': 'Мащаб',
      'refraction': 'Пречупване',
      'roughness': 'Грапавост',
      'tension': 'Напрежение',
      'max_scatter': 'Максимално разсейване',
      'min_scatter': 'Минимално разсейване',
      'samples': 'Проби',
      'edge_behavior': 'Поведение по краищата',
      'tile_size': 'Размер на плочката',
      'curvature': 'Кривина',
      'size': 'Размер',
      'strength': 'Сила',
      'tolerance': 'Допуск',
      'softness': 'Мекота',
      'lighting': 'Осветление',
      'warmth': 'Топлота',
      'power': 'Степен',
      'blend_mode': 'Режим на смесване',
      'factor': 'Коефициент',
      'zoom': 'Увеличение',
      'invert_colors': 'Инвертиране на цветовете',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Нормален',
      'multiply': 'Умножение',
      'additive': 'Събиране',
      'colorBurn': 'Затъмняване на цвета',
      'colorDodge': 'Изсветляване на цвета',
      'reflect': 'Отражение',
      'glow': 'Сияние',
      'overlay': 'Наслагване',
      'difference': 'Разлика',
      'negation': 'Отрицание',
      'lighten': 'Изсветляване',
      'darken': 'Затъмняване',
      'screen': 'Екран',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Няма достатъчно памет за изображението.',
      'invalid_size': 'Размерът на изображението е невалиден.',
      'layer_index': 'Няма такъв слой.',
      'last_layer': 'Последният слой не може да бъде изтрит.',
      'no_layer_below': 'Под този слой няма слой, с който да бъде слят.',
      'edit_in_progress': 'Първо завършете текущото действие.',
      'no_edit': 'Няма текущо действие за завършване.',
      'no_selection': 'Нищо не е избрано.',
      'nothing_lifted': 'Няма повдигнати пиксели.',
      'invalid_parameter': 'Стойността е извън допустимия диапазон.',
      'io': 'Файлът не може да бъде прочетен или записан.',
      'decode': 'Изображението не може да бъде прочетено.',
      'encode': 'Изображението не може да бъде записано.',
      'open_raster': 'Файлът OpenRaster е повреден.',
      'palette': 'Файлът с палитрата е повреден.',
      'cancelled': 'Изчислението е отменено.',
      'other': 'Възникна грешка.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Файлът не може да бъде прочетен или записан.';

  @override
  String get failureInvalidData => 'Данните не могат да бъдат прочетени.';

  @override
  String get failureUnknown => 'Възникна неочаквана грешка.';

  @override
  String get panelTools => 'Инструменти';

  @override
  String get panelHistory => 'История';

  @override
  String get panelLayers => 'Слоеве';

  @override
  String get panelColors => 'Цветове';

  @override
  String get panelHide => 'Скриване';

  @override
  String get colorsPrimary => 'Основен';

  @override
  String get colorsSecondary => 'Вторичен';

  @override
  String get colorsPrimaryHint =>
      'Основен цвят: с него рисува левият бутон на мишката';

  @override
  String get colorsSecondaryHint =>
      'Вторичен цвят: с него рисува десният бутон на мишката';

  @override
  String get colorsSwap => 'Размяна на цветовете (X)';

  @override
  String get colorsReset => 'Връщане към черно и бяло';

  @override
  String get colorsMore => 'Повече';

  @override
  String get colorsLess => 'По-малко';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Алфа';

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
      'Щракването с левия бутон задава основния цвят, а с десния — вторичния';

  @override
  String get settingWidth => 'Ширина';

  @override
  String get settingHardness => 'Твърдост';

  @override
  String get settingAntialias => 'Изглаждане';

  @override
  String get settingAlphaBlending => 'Алфа смесване';

  @override
  String get settingTolerance => 'Допуск';

  @override
  String get settingFloodMode => 'Режим на запълване';

  @override
  String get floodLocal => 'Съседни';

  @override
  String get floodGlobal => 'Цялото изображение';

  @override
  String get settingSelectionMode => 'Режим на селекция';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Замяна',
      'union': 'Обединение',
      'exclude': 'Изваждане',
      'xor': 'XOR',
      'intersect': 'Сечение',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Размер на селекцията';

  @override
  String get drawNormal => 'Свободен';

  @override
  String get drawFixedRatio => 'Фиксирано съотношение';

  @override
  String get drawFixedSize => 'Фиксиран размер';

  @override
  String get settingResampling => 'Интерполация';

  @override
  String get resamplingNearest => 'Най-близък съсед';

  @override
  String get resamplingBilinear => 'Билинейна';

  @override
  String get settingGradient => 'Тип';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Линеен',
      'linearReflected': 'Линеен огледален',
      'diamond': 'Ромбоиден',
      'radial': 'Радиален',
      'conical': 'Коничен',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Цвят';

  @override
  String get gradientTransparency => 'Прозрачност';

  @override
  String get settingShape => 'Стил на фигурата';

  @override
  String get shapeOutline => 'Контур';

  @override
  String get shapeInterior => 'Запълване';

  @override
  String get shapeBoth => 'Контур и запълване';

  @override
  String get settingAfterPick => 'След вземане на цвят';

  @override
  String get pickStay => 'Оставане в този инструмент';

  @override
  String get pickPrevious => 'Превключване към предишния инструмент';

  @override
  String get pickPencil => 'Превключване към „Молив“';

  @override
  String get settingNone => 'Този инструмент няма настройки.';

  @override
  String toolUnavailable(String name) {
    return 'Инструментът „$name“ все още не е наличен';
  }

  @override
  String get historyFirst => 'Към първата стъпка';

  @override
  String get historyUndo => 'Отмяна';

  @override
  String get historyRedo => 'Повторение';

  @override
  String get historyLast => 'Към последната стъпка';

  @override
  String get historyNewImage => 'Ново изображение';

  @override
  String get historyOpenImage => 'Отваряне на изображение';

  @override
  String get layerVisible => 'Показване или скриване на слоя';

  @override
  String get layerBackground => 'Фон';

  @override
  String get layerName => 'Име';

  @override
  String get layerOpacity => 'Непрозрачност';

  @override
  String get layerBlendMode => 'Режим на смесване';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Отказ';

  @override
  String get save => 'Запазване';

  @override
  String get dontSave => 'Без запазване';

  @override
  String get keepCanvas => 'Запазване на платното';

  @override
  String get expandCanvas => 'Разширяване на платното';

  @override
  String get width => 'Ширина';

  @override
  String get height => 'Височина';

  @override
  String get pixels => 'пиксела';

  @override
  String get newImageTitle => 'Ново изображение';

  @override
  String get resizeTitle => 'Преоразмеряване на изображението';

  @override
  String get canvasSizeTitle => 'Размер на платното';

  @override
  String get keepRatio => 'Запазване на пропорциите';

  @override
  String get anchor => 'Котва';

  @override
  String sizeTooLarge(int max) {
    return 'Изображението е твърде голямо: ограничението е $max мегапиксела.';
  }

  @override
  String get unsavedTitle => 'Да се запазят ли промените?';

  @override
  String unsavedMessage(String name) {
    return '„$name“ има незапазени промени.';
  }

  @override
  String get flattenTitle => 'Да се сплеска ли изображението?';

  @override
  String flattenMessage(String format) {
    return 'Форматът $format не поддържа слоеве, затова изображението ще бъде сплескано в един слой. Можете да отмените това в прозореца „История“.';
  }

  @override
  String get flatten => 'Сплескване';

  @override
  String get jpegQualityTitle => 'Качество на JPEG';

  @override
  String get quality => 'Качество';

  @override
  String get largerTitle => 'Изображението е по-голямо от платното';

  @override
  String get largerMessage => 'Да се разшири ли платното, за да го побере?';

  @override
  String get reseed => 'Ново зърно';

  @override
  String get rendering => 'Изчисляване…';

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
    return 'Отваряне на $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Запазване на $name…';
  }

  @override
  String savedTo(String name) {
    return 'Запазено: $name';
  }

  @override
  String get dropHere => 'Пуснете, за да отворите';

  @override
  String get dropHint => 'Всеки файл се отваря като ново изображение';

  @override
  String get imagesList => 'Отворени изображения';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Редактор на растерни изображения със слоеве. Натиснете буква, за да изберете инструмент; повторното натискане на S, M или O превключва между сродните инструменти. [ и ] променят ширината на четката, X разменя цветовете, задържането на интервал премества изгледа, Ctrl+колелцето на мишката променя мащаба, а F5–F8 показват или скриват прозорците.';

  @override
  String get aboutLegal =>
      '© 2026 авторите на Paintbox. Paintbox е свободен софтуер: можете да го разпространявате и променяте според условията на GNU General Public License, версия 3 или по-нова. Програмата се предоставя без никаква гаранция.';

  @override
  String get licenses => 'Лицензи';

  @override
  String get settingLineStart => 'Начало';

  @override
  String get settingLineEnd => 'Край';

  @override
  String get settingDash => 'Щрих';

  @override
  String get settingSwapSize => 'Размяна на ширината и височината';

  @override
  String get settingLineStyle => 'Стил';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Плосък',
      'arrow': 'Стрелка',
      'arrowFilled': 'Плътна стрелка',
      'rounded': 'Заоблен',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Плътна',
      'dash': 'Прекъсната',
      'dashDot': 'Тире-точка',
      'dashDotDot': 'Тире-две точки',
      'dot': 'Точкова',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Шрифт';

  @override
  String get settingFontSize => 'Размер';

  @override
  String get textBold => 'Удебелен';

  @override
  String get textItalic => 'Курсив';

  @override
  String get textUnderline => 'Подчертан';

  @override
  String get textStrikeout => 'Зачертан';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Вляво',
      'center': 'Центрирано',
      'right': 'Вдясно',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Изображения';
}
