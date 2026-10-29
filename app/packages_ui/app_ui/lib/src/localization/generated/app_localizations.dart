import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'Paintbox'**
  String get appTitle;

  /// No description provided for @untitledImage.
  ///
  /// In uk, this message translates to:
  /// **'Без назви {number}'**
  String untitledImage(int number);

  /// No description provided for @menuFile.
  ///
  /// In uk, this message translates to:
  /// **'Файл'**
  String get menuFile;

  /// No description provided for @menuEdit.
  ///
  /// In uk, this message translates to:
  /// **'Правка'**
  String get menuEdit;

  /// No description provided for @menuView.
  ///
  /// In uk, this message translates to:
  /// **'Вигляд'**
  String get menuView;

  /// No description provided for @menuImage.
  ///
  /// In uk, this message translates to:
  /// **'Зображення'**
  String get menuImage;

  /// No description provided for @menuLayers.
  ///
  /// In uk, this message translates to:
  /// **'Шари'**
  String get menuLayers;

  /// No description provided for @menuAdjustments.
  ///
  /// In uk, this message translates to:
  /// **'Коригування'**
  String get menuAdjustments;

  /// No description provided for @menuEffects.
  ///
  /// In uk, this message translates to:
  /// **'Ефекти'**
  String get menuEffects;

  /// No description provided for @menuOpenRecent.
  ///
  /// In uk, this message translates to:
  /// **'Нещодавні'**
  String get menuOpenRecent;

  /// No description provided for @menuRecentEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Нещодавніх файлів немає'**
  String get menuRecentEmpty;

  /// No description provided for @menuTheme.
  ///
  /// In uk, this message translates to:
  /// **'Тема'**
  String get menuTheme;

  /// No description provided for @menuSettings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get menuSettings;

  /// No description provided for @unitsPixels.
  ///
  /// In uk, this message translates to:
  /// **'пкс'**
  String get unitsPixels;

  /// No description provided for @themeSystem.
  ///
  /// In uk, this message translates to:
  /// **'Як у системі'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In uk, this message translates to:
  /// **'Темна'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In uk, this message translates to:
  /// **'Світла'**
  String get themeLight;

  /// No description provided for @commandLabel.
  ///
  /// In uk, this message translates to:
  /// **'{id, select, new{Створити…} open{Відкрити…} close{Закрити} save{Зберегти} save_as{Зберегти як…} exit{Вийти} undo{Скасувати} redo{Повторити} cut{Вирізати} copy{Копіювати} paste{Вставити} paste_into_new_layer{Вставити в новий шар} paste_into_new_image{Вставити в нове зображення} erase_selection{Стерти виділене} fill_selection{Залити виділене} invert_selection{Обернути виділення} select_all{Виділити все} deselect{Зняти виділення} zoom_in{Наблизити} zoom_out{Віддалити} zoom_to_window{За розміром вікна} zoom_to_selection{За виділенням} actual_size{Справжній розмір} pixel_grid{Піксельна сітка} rulers{Лінійки} crop_to_selection{Обрізати за виділенням} resize{Змінити розмір…} canvas_size{Розмір полотна…} flip_horizontal{Віддзеркалити по горизонталі} flip_vertical{Віддзеркалити по вертикалі} rotate90_cw{Повернути на 90° за годинниковою} rotate90_ccw{Повернути на 90° проти годинникової} rotate180{Повернути на 180°} flatten{Звести шари} add_layer{Додати шар} delete_layer{Видалити шар} duplicate_layer{Дублювати шар} merge_layer_down{Злити з нижнім} import_from_file{Імпортувати з файлу…} flip_layer_horizontal{Віддзеркалити шар по горизонталі} flip_layer_vertical{Віддзеркалити шар по вертикалі} move_layer_up{Підняти шар} move_layer_down{Опустити шар} layer_properties{Властивості шару…} adjust_auto_level{Авторівні} adjust_black_and_white{Чорно-біле} adjust_brightness_contrast{Яскравість / контраст…} adjust_curves{Криві…} adjust_hue_saturation{Відтінок / насиченість…} adjust_invert_colors{Обернути кольори} adjust_levels{Рівні…} adjust_posterize{Постеризація…} adjust_sepia{Сепія} repeat_effect{Повторити ефект} effect_oil_painting{Олійний живопис…} effect_gaussian_blur{Розмиття Гаусса…} effect_motion_blur{Розмиття в русі…} effect_pixelate{Пікселізація…} effect_add_noise{Шум…} effect_median{Медіана…} effect_sharpen{Різкість…} effect_edge_detect{Виявлення країв…} effect_emboss{Тиснення…} effect_outline{Контур…} toggle_tools{Інструменти} toggle_history{Історія} toggle_layers{Шари} toggle_colors{Кольори} next_image{Наступне зображення} previous_image{Попереднє зображення} help{Довідка} effect_ink_sketch{Ескіз тушшю…} effect_pencil_sketch{Олівцевий ескіз…} effect_fragment{Фрагменти…} effect_radial_blur{Радіальне розмиття…} effect_surface_blur{Розмиття поверхні…} effect_unfocus{Розфокус…} effect_zoom_blur{Розмиття наближенням…} effect_bulge{Опуклість…} effect_dents{Вм\'ятини…} effect_frosted_glass{Матове скло…} effect_polar_inversion{Полярна інверсія…} effect_tile_reflection{Відбиття плиток…} effect_twist{Скручування…} effect_reduce_noise{Зменшення шуму…} effect_glow{Сяйво…} effect_red_eye_removal{Усунення червоних очей…} effect_soften_portrait{М\'який портрет…} effect_clouds{Хмари…} effect_julia_fractal{Фрактал Жюліа…} effect_mandelbrot_fractal{Фрактал Мандельброта…} effect_relief{Рельєф…} other{}}'**
  String commandLabel(String id);

  /// No description provided for @dialogTitle.
  ///
  /// In uk, this message translates to:
  /// **'{id, select, adjust_brightness_contrast{Яскравість / контраст} adjust_curves{Криві} adjust_hue_saturation{Відтінок / насиченість} adjust_levels{Рівні} adjust_posterize{Постеризація} effect_oil_painting{Олійний живопис} effect_gaussian_blur{Розмиття Гаусса} effect_motion_blur{Розмиття в русі} effect_pixelate{Пікселізація} effect_add_noise{Шум} effect_median{Медіана} effect_sharpen{Різкість} effect_edge_detect{Виявлення країв} effect_emboss{Тиснення} effect_outline{Контур} layer_properties{Властивості шару} effect_ink_sketch{Ескіз тушшю} effect_pencil_sketch{Олівцевий ескіз} effect_fragment{Фрагменти} effect_radial_blur{Радіальне розмиття} effect_surface_blur{Розмиття поверхні} effect_unfocus{Розфокус} effect_zoom_blur{Розмиття наближенням} effect_bulge{Опуклість} effect_dents{Вм\'ятини} effect_frosted_glass{Матове скло} effect_polar_inversion{Полярна інверсія} effect_tile_reflection{Відбиття плиток} effect_twist{Скручування} effect_reduce_noise{Зменшення шуму} effect_glow{Сяйво} effect_red_eye_removal{Усунення червоних очей} effect_soften_portrait{М\'який портрет} effect_clouds{Хмари} effect_julia_fractal{Фрактал Жюліа} effect_mandelbrot_fractal{Фрактал Мандельброта} effect_relief{Рельєф} other{}}'**
  String dialogTitle(String id);

  /// No description provided for @effectGroup.
  ///
  /// In uk, this message translates to:
  /// **'{name, select, artistic{Мистецькі} blurs{Розмиття} distort{Спотворення} noise{Шум} photo{Фото} stylize{Стилізація} render{Візуалізація} other{}}'**
  String effectGroup(String name);

  /// No description provided for @toolName.
  ///
  /// In uk, this message translates to:
  /// **'{id, select, rectangle_select{Прямокутне виділення} move_selected_pixels{Переміщення виділених пікселів} lasso_select{Ласо} move_selection{Переміщення виділення} ellipse_select{Еліптичне виділення} zoom{Масштаб} magic_wand{Чарівна паличка} pan{Рука} paint_bucket{Заливка} gradient{Градієнт} paintbrush{Пензель} eraser{Гумка} pencil{Олівець} color_picker{Піпетка} clone_stamp{Штамп} recolor{Перефарбування} text{Текст} line_curve{Лінія / крива} rectangle{Прямокутник} rounded_rectangle{Заокруглений прямокутник} ellipse{Еліпс} freeform_shape{Довільна фігура} other{}}'**
  String toolName(String id);

  /// No description provided for @toolHint.
  ///
  /// In uk, this message translates to:
  /// **'{id, select, rectangle_select{Протягніть, щоб виділити прямокутник. Shift — квадрат.} move_selected_pixels{Перетягніть виділене, щоб перемістити: права кнопка повертає, ручки масштабують. Ctrl лишає копію, стрілки зсувають.} lasso_select{Протягніть, щоб обвести виділення.} move_selection{Перетягніть контур виділення. Пікселі лишаються на місці.} ellipse_select{Протягніть, щоб виділити еліпс. Shift — коло.} zoom{Ліве клацання наближає, праве віддаляє, рамка наближає до себе.} magic_wand{Клацніть, щоб виділити ділянку схожого кольору. Shift — по всьому зображенню.} pan{Перетягніть, щоб зсунути вигляд.} paint_bucket{Ліве клацання заливає основним кольором, праве — додатковим.} gradient{Протягніть, щоб намалювати градієнт. Ручки його змінюють, Enter завершує.} paintbrush{Ліва кнопка малює основним кольором, права — додатковим.} eraser{Протягніть, щоб стерти до прозорого.} pencil{Малює лінії в один піксель без згладжування.} color_picker{Ліве клацання бере основний колір, праве — додатковий.} clone_stamp{Ctrl+клацання задає джерело, далі протягніть, щоб малювати з нього.} recolor{Замінює додатковий колір основним там, де малюєте. Ctrl+клацання бере колір.} text{Клацніть, щоб поставити курсор, і друкуйте. Права кнопка чи ручка рухають текст, Esc завершує.} line_curve{Протягніть, щоб намалювати лінію. Ручки її вигинають, Enter завершує.} rectangle{Протягніть, щоб намалювати прямокутник. Shift — квадрат.} rounded_rectangle{Протягніть, щоб намалювати заокруглений прямокутник. Shift — квадрат.} ellipse{Протягніть, щоб намалювати еліпс. Shift — коло.} freeform_shape{Протягніть, щоб намалювати замкнену довільну фігуру.} other{}}'**
  String toolHint(String id);

  /// No description provided for @paramName.
  ///
  /// In uk, this message translates to:
  /// **'{name, select, radius{Радіус} angle{Кут} distance{Відстань} centered{По центру} amount{Сила} intensity{Інтенсивність} saturation{Насиченість} coverage{Покриття} seed{Зерно} percentile{Перцентиль} cell_size{Розмір клітинки} brush_size{Розмір пензля} coarseness{Грубість} thickness{Товщина} brightness{Яскравість} contrast{Контраст} hue{Відтінок} lightness{Світлота} red{Червоний} green{Зелений} blue{Синій} input_low{Вхід: темне} input_high{Вхід: світле} output_low{Вихід: темне} output_high{Вихід: світле} gamma{Гама} ink_outline{Контур тушшю} coloring{Забарвлення} tip_size{Розмір вістря} color_range{Діапазон кольору} fragments{Фрагменти} rotation{Поворот} offset_x{Зсув X} offset_y{Зсув Y} quality{Якість} threshold{Поріг} scale{Масштаб} refraction{Заломлення} roughness{Шорсткість} tension{Натяг} max_scatter{Найбільший розкид} min_scatter{Найменший розкид} samples{Відліки} edge_behavior{Поведінка на краю} tile_size{Розмір плитки} curvature{Кривизна} size{Розмір} strength{Сила} tolerance{Допуск} softness{М\'якість} lighting{Освітлення} warmth{Теплота} power{Потужність} blend_mode{Режим змішування} factor{Множник} zoom{Наближення} invert_colors{Обернути кольори} other{}}'**
  String paramName(String name);

  /// No description provided for @blendModeName.
  ///
  /// In uk, this message translates to:
  /// **'{mode, select, normal{Звичайне} multiply{Множення} additive{Додавання} colorBurn{Затемнення основи} colorDodge{Освітлення основи} reflect{Відбиття} glow{Світіння} overlay{Перекриття} difference{Різниця} negation{Заперечення} lighten{Світліше} darken{Темніше} screen{Екран} xor{Виключне АБО} other{}}'**
  String blendModeName(String mode);

  /// No description provided for @failureCode.
  ///
  /// In uk, this message translates to:
  /// **'{code, select, out_of_memory{Для зображення забракло пам\'яті.} invalid_size{Такого розміру зображення бути не може.} layer_index{Такого шару немає.} last_layer{Останній шар видалити не можна.} no_layer_below{Під цим шаром немає шару, з яким злити.} edit_in_progress{Спершу завершіть поточну дію.} no_edit{Немає дії, яку завершити.} no_selection{Нічого не виділено.} nothing_lifted{Нічого не піднято.} invalid_parameter{Значення поза межами.} io{Файл не вдалося прочитати чи записати.} decode{Зображення не вдалося прочитати.} encode{Зображення не вдалося записати.} open_raster{Файл OpenRaster пошкоджено.} palette{Файл палітри пошкоджено.} cancelled{Обчислення скасовано.} other{Сталася помилка.}}'**
  String failureCode(String code);

  /// No description provided for @failureStorage.
  ///
  /// In uk, this message translates to:
  /// **'Файл не вдалося прочитати чи записати.'**
  String get failureStorage;

  /// No description provided for @failureInvalidData.
  ///
  /// In uk, this message translates to:
  /// **'Дані не вдалося прочитати.'**
  String get failureInvalidData;

  /// No description provided for @failureUnknown.
  ///
  /// In uk, this message translates to:
  /// **'Сталася неочікувана помилка.'**
  String get failureUnknown;

  /// No description provided for @panelTools.
  ///
  /// In uk, this message translates to:
  /// **'Інструменти'**
  String get panelTools;

  /// No description provided for @panelHistory.
  ///
  /// In uk, this message translates to:
  /// **'Історія'**
  String get panelHistory;

  /// No description provided for @panelLayers.
  ///
  /// In uk, this message translates to:
  /// **'Шари'**
  String get panelLayers;

  /// No description provided for @panelColors.
  ///
  /// In uk, this message translates to:
  /// **'Кольори'**
  String get panelColors;

  /// No description provided for @panelHide.
  ///
  /// In uk, this message translates to:
  /// **'Сховати'**
  String get panelHide;

  /// No description provided for @colorsPrimary.
  ///
  /// In uk, this message translates to:
  /// **'Основний'**
  String get colorsPrimary;

  /// No description provided for @colorsSecondary.
  ///
  /// In uk, this message translates to:
  /// **'Додатковий'**
  String get colorsSecondary;

  /// No description provided for @colorsPrimaryHint.
  ///
  /// In uk, this message translates to:
  /// **'Основний колір: ним малює ліва кнопка'**
  String get colorsPrimaryHint;

  /// No description provided for @colorsSecondaryHint.
  ///
  /// In uk, this message translates to:
  /// **'Додатковий колір: ним малює права кнопка'**
  String get colorsSecondaryHint;

  /// No description provided for @colorsSwap.
  ///
  /// In uk, this message translates to:
  /// **'Обміняти кольори (X)'**
  String get colorsSwap;

  /// No description provided for @colorsReset.
  ///
  /// In uk, this message translates to:
  /// **'Чорний і білий'**
  String get colorsReset;

  /// No description provided for @colorsMore.
  ///
  /// In uk, this message translates to:
  /// **'Більше'**
  String get colorsMore;

  /// No description provided for @colorsLess.
  ///
  /// In uk, this message translates to:
  /// **'Менше'**
  String get colorsLess;

  /// No description provided for @colorsHex.
  ///
  /// In uk, this message translates to:
  /// **'Hex'**
  String get colorsHex;

  /// No description provided for @colorsAlpha.
  ///
  /// In uk, this message translates to:
  /// **'Альфа'**
  String get colorsAlpha;

  /// No description provided for @colorsHue.
  ///
  /// In uk, this message translates to:
  /// **'Т'**
  String get colorsHue;

  /// No description provided for @colorsSat.
  ///
  /// In uk, this message translates to:
  /// **'Н'**
  String get colorsSat;

  /// No description provided for @colorsValue.
  ///
  /// In uk, this message translates to:
  /// **'Я'**
  String get colorsValue;

  /// No description provided for @colorsRed.
  ///
  /// In uk, this message translates to:
  /// **'R'**
  String get colorsRed;

  /// No description provided for @colorsGreen.
  ///
  /// In uk, this message translates to:
  /// **'G'**
  String get colorsGreen;

  /// No description provided for @colorsBlue.
  ///
  /// In uk, this message translates to:
  /// **'B'**
  String get colorsBlue;

  /// No description provided for @colorsPaletteHint.
  ///
  /// In uk, this message translates to:
  /// **'Ліва кнопка — основний колір, права — додатковий'**
  String get colorsPaletteHint;

  /// No description provided for @settingWidth.
  ///
  /// In uk, this message translates to:
  /// **'Ширина'**
  String get settingWidth;

  /// No description provided for @settingHardness.
  ///
  /// In uk, this message translates to:
  /// **'Твердість'**
  String get settingHardness;

  /// No description provided for @settingAntialias.
  ///
  /// In uk, this message translates to:
  /// **'Згладжування'**
  String get settingAntialias;

  /// No description provided for @settingAlphaBlending.
  ///
  /// In uk, this message translates to:
  /// **'Змішування альфи'**
  String get settingAlphaBlending;

  /// No description provided for @settingTolerance.
  ///
  /// In uk, this message translates to:
  /// **'Допуск'**
  String get settingTolerance;

  /// No description provided for @settingFloodMode.
  ///
  /// In uk, this message translates to:
  /// **'Поширення'**
  String get settingFloodMode;

  /// No description provided for @floodLocal.
  ///
  /// In uk, this message translates to:
  /// **'Суміжні'**
  String get floodLocal;

  /// No description provided for @floodGlobal.
  ///
  /// In uk, this message translates to:
  /// **'Усе зображення'**
  String get floodGlobal;

  /// No description provided for @settingSelectionMode.
  ///
  /// In uk, this message translates to:
  /// **'Режим виділення'**
  String get settingSelectionMode;

  /// No description provided for @combineMode.
  ///
  /// In uk, this message translates to:
  /// **'{mode, select, replace{Замінити} union{Додати} exclude{Відняти} xor{Виключне АБО} intersect{Перетнути} other{}}'**
  String combineMode(String mode);

  /// No description provided for @settingDrawMode.
  ///
  /// In uk, this message translates to:
  /// **'Розмір'**
  String get settingDrawMode;

  /// No description provided for @drawNormal.
  ///
  /// In uk, this message translates to:
  /// **'Довільний'**
  String get drawNormal;

  /// No description provided for @drawFixedRatio.
  ///
  /// In uk, this message translates to:
  /// **'Сталі пропорції'**
  String get drawFixedRatio;

  /// No description provided for @drawFixedSize.
  ///
  /// In uk, this message translates to:
  /// **'Сталий розмір'**
  String get drawFixedSize;

  /// No description provided for @settingResampling.
  ///
  /// In uk, this message translates to:
  /// **'Передискретизація'**
  String get settingResampling;

  /// No description provided for @resamplingNearest.
  ///
  /// In uk, this message translates to:
  /// **'Найближчий сусід'**
  String get resamplingNearest;

  /// No description provided for @resamplingBilinear.
  ///
  /// In uk, this message translates to:
  /// **'Білінійна'**
  String get resamplingBilinear;

  /// No description provided for @settingGradient.
  ///
  /// In uk, this message translates to:
  /// **'Тип'**
  String get settingGradient;

  /// No description provided for @gradientKind.
  ///
  /// In uk, this message translates to:
  /// **'{kind, select, linear{Лінійний} linearReflected{Лінійний дзеркальний} diamond{Ромб} radial{Радіальний} conical{Конічний} other{}}'**
  String gradientKind(String kind);

  /// No description provided for @gradientColor.
  ///
  /// In uk, this message translates to:
  /// **'Колір'**
  String get gradientColor;

  /// No description provided for @gradientTransparency.
  ///
  /// In uk, this message translates to:
  /// **'Прозорість'**
  String get gradientTransparency;

  /// No description provided for @settingShape.
  ///
  /// In uk, this message translates to:
  /// **'Малює'**
  String get settingShape;

  /// No description provided for @shapeOutline.
  ///
  /// In uk, this message translates to:
  /// **'Контур'**
  String get shapeOutline;

  /// No description provided for @shapeInterior.
  ///
  /// In uk, this message translates to:
  /// **'Заливка'**
  String get shapeInterior;

  /// No description provided for @shapeBoth.
  ///
  /// In uk, this message translates to:
  /// **'Контур і заливка'**
  String get shapeBoth;

  /// No description provided for @settingAfterPick.
  ///
  /// In uk, this message translates to:
  /// **'Потім'**
  String get settingAfterPick;

  /// No description provided for @pickStay.
  ///
  /// In uk, this message translates to:
  /// **'Лишитися'**
  String get pickStay;

  /// No description provided for @pickPrevious.
  ///
  /// In uk, this message translates to:
  /// **'Попередній інструмент'**
  String get pickPrevious;

  /// No description provided for @pickPencil.
  ///
  /// In uk, this message translates to:
  /// **'Олівець'**
  String get pickPencil;

  /// No description provided for @settingNone.
  ///
  /// In uk, this message translates to:
  /// **'Цей інструмент не має параметрів.'**
  String get settingNone;

  /// No description provided for @toolUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'{name} ще не зроблено'**
  String toolUnavailable(String name);

  /// No description provided for @historyFirst.
  ///
  /// In uk, this message translates to:
  /// **'На початок'**
  String get historyFirst;

  /// No description provided for @historyUndo.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get historyUndo;

  /// No description provided for @historyRedo.
  ///
  /// In uk, this message translates to:
  /// **'Повторити'**
  String get historyRedo;

  /// No description provided for @historyLast.
  ///
  /// In uk, this message translates to:
  /// **'У кінець'**
  String get historyLast;

  /// No description provided for @historyNewImage.
  ///
  /// In uk, this message translates to:
  /// **'Нове зображення'**
  String get historyNewImage;

  /// No description provided for @historyOpenImage.
  ///
  /// In uk, this message translates to:
  /// **'Відкрите зображення'**
  String get historyOpenImage;

  /// No description provided for @layerVisible.
  ///
  /// In uk, this message translates to:
  /// **'Чи показано шар'**
  String get layerVisible;

  /// No description provided for @layerBackground.
  ///
  /// In uk, this message translates to:
  /// **'Тло'**
  String get layerBackground;

  /// No description provided for @layerName.
  ///
  /// In uk, this message translates to:
  /// **'Назва'**
  String get layerName;

  /// No description provided for @layerOpacity.
  ///
  /// In uk, this message translates to:
  /// **'Непрозорість'**
  String get layerOpacity;

  /// No description provided for @layerBlendMode.
  ///
  /// In uk, this message translates to:
  /// **'Режим змішування'**
  String get layerBlendMode;

  /// No description provided for @ok.
  ///
  /// In uk, this message translates to:
  /// **'Гаразд'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @dontSave.
  ///
  /// In uk, this message translates to:
  /// **'Не зберігати'**
  String get dontSave;

  /// No description provided for @keepCanvas.
  ///
  /// In uk, this message translates to:
  /// **'Не змінювати'**
  String get keepCanvas;

  /// No description provided for @expandCanvas.
  ///
  /// In uk, this message translates to:
  /// **'Збільшити полотно'**
  String get expandCanvas;

  /// No description provided for @width.
  ///
  /// In uk, this message translates to:
  /// **'Ширина'**
  String get width;

  /// No description provided for @height.
  ///
  /// In uk, this message translates to:
  /// **'Висота'**
  String get height;

  /// No description provided for @pixels.
  ///
  /// In uk, this message translates to:
  /// **'пікселів'**
  String get pixels;

  /// No description provided for @newImageTitle.
  ///
  /// In uk, this message translates to:
  /// **'Нове зображення'**
  String get newImageTitle;

  /// No description provided for @resizeTitle.
  ///
  /// In uk, this message translates to:
  /// **'Розмір зображення'**
  String get resizeTitle;

  /// No description provided for @canvasSizeTitle.
  ///
  /// In uk, this message translates to:
  /// **'Розмір полотна'**
  String get canvasSizeTitle;

  /// No description provided for @keepRatio.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти пропорції'**
  String get keepRatio;

  /// No description provided for @anchor.
  ///
  /// In uk, this message translates to:
  /// **'Прив\'язка'**
  String get anchor;

  /// No description provided for @sizeTooLarge.
  ///
  /// In uk, this message translates to:
  /// **'Завелике зображення: не більше {max} мегапікселів.'**
  String sizeTooLarge(int max);

  /// No description provided for @unsavedTitle.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти зміни?'**
  String get unsavedTitle;

  /// No description provided for @unsavedMessage.
  ///
  /// In uk, this message translates to:
  /// **'«{name}» має незбережені зміни.'**
  String unsavedMessage(String name);

  /// No description provided for @flattenTitle.
  ///
  /// In uk, this message translates to:
  /// **'Звести шари?'**
  String get flattenTitle;

  /// No description provided for @flattenMessage.
  ///
  /// In uk, this message translates to:
  /// **'Формат {format} не зберігає шарів: зображення буде зведено в один шар. Скасувати це можна в Історії.'**
  String flattenMessage(String format);

  /// No description provided for @flatten.
  ///
  /// In uk, this message translates to:
  /// **'Звести'**
  String get flatten;

  /// No description provided for @jpegQualityTitle.
  ///
  /// In uk, this message translates to:
  /// **'Якість JPEG'**
  String get jpegQualityTitle;

  /// No description provided for @quality.
  ///
  /// In uk, this message translates to:
  /// **'Якість'**
  String get quality;

  /// No description provided for @largerTitle.
  ///
  /// In uk, this message translates to:
  /// **'Зображення більше за полотно'**
  String get largerTitle;

  /// No description provided for @largerMessage.
  ///
  /// In uk, this message translates to:
  /// **'Збільшити полотно, щоб вмістити його?'**
  String get largerMessage;

  /// No description provided for @reseed.
  ///
  /// In uk, this message translates to:
  /// **'Інше зерно'**
  String get reseed;

  /// No description provided for @rendering.
  ///
  /// In uk, this message translates to:
  /// **'Обчислення…'**
  String get rendering;

  /// No description provided for @statusPointer.
  ///
  /// In uk, this message translates to:
  /// **'{x}, {y}'**
  String statusPointer(int x, int y);

  /// No description provided for @statusSelection.
  ///
  /// In uk, this message translates to:
  /// **'{width} × {height}'**
  String statusSelection(int width, int height);

  /// No description provided for @statusZoom.
  ///
  /// In uk, this message translates to:
  /// **'{percent} %'**
  String statusZoom(String percent);

  /// No description provided for @statusOpening.
  ///
  /// In uk, this message translates to:
  /// **'Відкриття {name}…'**
  String statusOpening(String name);

  /// No description provided for @statusSaving.
  ///
  /// In uk, this message translates to:
  /// **'Збереження {name}…'**
  String statusSaving(String name);

  /// No description provided for @savedTo.
  ///
  /// In uk, this message translates to:
  /// **'Збережено: {name}'**
  String savedTo(String name);

  /// No description provided for @dropHere.
  ///
  /// In uk, this message translates to:
  /// **'Відкрити'**
  String get dropHere;

  /// No description provided for @dropHint.
  ///
  /// In uk, this message translates to:
  /// **'Кожен файл відкриється новим зображенням'**
  String get dropHint;

  /// No description provided for @imagesList.
  ///
  /// In uk, this message translates to:
  /// **'Відкриті зображення'**
  String get imagesList;

  /// No description provided for @helpTitle.
  ///
  /// In uk, this message translates to:
  /// **'Paintbox'**
  String get helpTitle;

  /// No description provided for @helpMessage.
  ///
  /// In uk, this message translates to:
  /// **'Редактор зображень із шарами. Інструменти — літерами (S, M, O перебирають сусідні), [ і ] — ширина пензля, X — обміняти кольори, пробіл — рука, Ctrl+коліщатко — масштаб, F5–F8 — вікна.'**
  String get helpMessage;

  /// No description provided for @settingLineStart.
  ///
  /// In uk, this message translates to:
  /// **'Початок'**
  String get settingLineStart;

  /// No description provided for @settingLineEnd.
  ///
  /// In uk, this message translates to:
  /// **'Кінець'**
  String get settingLineEnd;

  /// No description provided for @settingDash.
  ///
  /// In uk, this message translates to:
  /// **'Штрих'**
  String get settingDash;

  /// No description provided for @settingSwapSize.
  ///
  /// In uk, this message translates to:
  /// **'Поміняти ширину й висоту'**
  String get settingSwapSize;

  /// No description provided for @settingLineStyle.
  ///
  /// In uk, this message translates to:
  /// **'Стиль'**
  String get settingLineStyle;

  /// No description provided for @lineCap.
  ///
  /// In uk, this message translates to:
  /// **'{cap, select, flat{Плаский} arrow{Стрілка} arrowFilled{Заповнена стрілка} rounded{Заокруглений} other{}}'**
  String lineCap(String cap);

  /// No description provided for @dashStyle.
  ///
  /// In uk, this message translates to:
  /// **'{dash, select, solid{Суцільний} dash{Риска} dashDot{Риска-крапка} dashDotDot{Риска-дві крапки} dot{Крапки} other{}}'**
  String dashStyle(String dash);

  /// No description provided for @settingFont.
  ///
  /// In uk, this message translates to:
  /// **'Шрифт'**
  String get settingFont;

  /// No description provided for @settingFontSize.
  ///
  /// In uk, this message translates to:
  /// **'Розмір'**
  String get settingFontSize;

  /// No description provided for @textBold.
  ///
  /// In uk, this message translates to:
  /// **'Жирний'**
  String get textBold;

  /// No description provided for @textItalic.
  ///
  /// In uk, this message translates to:
  /// **'Курсив'**
  String get textItalic;

  /// No description provided for @textUnderline.
  ///
  /// In uk, this message translates to:
  /// **'Підкреслений'**
  String get textUnderline;

  /// No description provided for @textStrikeout.
  ///
  /// In uk, this message translates to:
  /// **'Закреслений'**
  String get textStrikeout;

  /// No description provided for @textAlign.
  ///
  /// In uk, this message translates to:
  /// **'{align, select, left{Ліворуч} center{По центру} right{Праворуч} other{}}'**
  String textAlign(String align);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
