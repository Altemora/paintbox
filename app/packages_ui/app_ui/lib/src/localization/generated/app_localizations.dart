import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_be.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
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
    Locale('be'),
    Locale('bg'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fi'),
    Locale('fr'),
    Locale('hr'),
    Locale('hu'),
    Locale('it'),
    Locale('kk'),
    Locale('lt'),
    Locale('lv'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('sk'),
    Locale('sv'),
    Locale('tr'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Paintbox'**
  String get appTitle;

  /// No description provided for @untitledImage.
  ///
  /// In en, this message translates to:
  /// **'Untitled {number}'**
  String untitledImage(int number);

  /// No description provided for @menuFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get menuView;

  /// No description provided for @menuImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get menuImage;

  /// No description provided for @menuLayers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get menuLayers;

  /// No description provided for @menuAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Adjustments'**
  String get menuAdjustments;

  /// No description provided for @menuEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get menuEffects;

  /// No description provided for @menuOpenRecent.
  ///
  /// In en, this message translates to:
  /// **'Open Recent'**
  String get menuOpenRecent;

  /// No description provided for @menuRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent files'**
  String get menuRecentEmpty;

  /// No description provided for @menuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get menuTheme;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get menuAccent;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @accentName.
  ///
  /// In en, this message translates to:
  /// **'{name, select, blue{Blue} green{Green} amber{Amber} purple{Purple} red{Red} gray{Gray} custom{Custom…} other{}}'**
  String accentName(String name);

  /// No description provided for @accentCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom accent color'**
  String get accentCustomTitle;

  /// No description provided for @unitsPixels.
  ///
  /// In en, this message translates to:
  /// **'px'**
  String get unitsPixels;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @commandLabel.
  ///
  /// In en, this message translates to:
  /// **'{id, select, new{New…} open{Open…} close{Close} save{Save} save_as{Save As…} exit{Exit} undo{Undo} redo{Redo} cut{Cut} copy{Copy} paste{Paste} paste_into_new_layer{Paste into New Layer} paste_into_new_image{Paste into New Image} erase_selection{Erase Selection} fill_selection{Fill Selection} invert_selection{Invert Selection} select_all{Select All} deselect{Deselect} zoom_in{Zoom In} zoom_out{Zoom Out} zoom_to_window{Zoom to Window} zoom_to_selection{Zoom to Selection} actual_size{Actual Size} pixel_grid{Pixel Grid} rulers{Rulers} crop_to_selection{Crop to Selection} resize{Resize…} canvas_size{Canvas Size…} flip_horizontal{Flip Horizontal} flip_vertical{Flip Vertical} rotate90_cw{Rotate 90° Clockwise} rotate90_ccw{Rotate 90° Counterclockwise} rotate180{Rotate 180°} flatten{Flatten} add_layer{Add New Layer} delete_layer{Delete Layer} duplicate_layer{Duplicate Layer} merge_layer_down{Merge Layer Down} import_from_file{Import From File…} flip_layer_horizontal{Flip Layer Horizontal} flip_layer_vertical{Flip Layer Vertical} move_layer_up{Move Layer Up} move_layer_down{Move Layer Down} layer_properties{Layer Properties…} adjust_auto_level{Auto-Level} adjust_black_and_white{Black and White} adjust_brightness_contrast{Brightness / Contrast…} adjust_curves{Curves…} adjust_hue_saturation{Hue / Saturation…} adjust_invert_colors{Invert Colors} adjust_levels{Levels…} adjust_posterize{Posterize…} adjust_sepia{Sepia} repeat_effect{Repeat Effect} effect_oil_painting{Oil Painting…} effect_gaussian_blur{Gaussian Blur…} effect_motion_blur{Motion Blur…} effect_pixelate{Pixelate…} effect_add_noise{Add Noise…} effect_median{Median…} effect_sharpen{Sharpen…} effect_edge_detect{Edge Detect…} effect_emboss{Emboss…} effect_outline{Outline…} toggle_tools{Tools} toggle_history{History} toggle_layers{Layers} toggle_colors{Colors} next_image{Next Image} previous_image{Previous Image} help{Help} effect_ink_sketch{Ink Sketch…} effect_pencil_sketch{Pencil Sketch…} effect_fragment{Fragment…} effect_radial_blur{Radial Blur…} effect_surface_blur{Surface Blur…} effect_unfocus{Unfocus…} effect_zoom_blur{Zoom Blur…} effect_bulge{Bulge…} effect_dents{Dents…} effect_frosted_glass{Frosted Glass…} effect_polar_inversion{Polar Inversion…} effect_tile_reflection{Tile Reflection…} effect_twist{Twist…} effect_reduce_noise{Reduce Noise…} effect_glow{Glow…} effect_red_eye_removal{Red Eye Removal…} effect_soften_portrait{Soften Portrait…} effect_clouds{Clouds…} effect_julia_fractal{Julia Fractal…} effect_mandelbrot_fractal{Mandelbrot Fractal…} effect_relief{Relief…} other{}}'**
  String commandLabel(String id);

  /// No description provided for @effectGroup.
  ///
  /// In en, this message translates to:
  /// **'{name, select, artistic{Artistic} blurs{Blurs} distort{Distort} noise{Noise} photo{Photo} stylize{Stylize} render{Render} other{}}'**
  String effectGroup(String name);

  /// No description provided for @toolName.
  ///
  /// In en, this message translates to:
  /// **'{id, select, rectangle_select{Rectangle Select} move_selected_pixels{Move Selected Pixels} lasso_select{Lasso Select} move_selection{Move Selection} ellipse_select{Ellipse Select} zoom{Zoom} magic_wand{Magic Wand} pan{Pan} paint_bucket{Paint Bucket} gradient{Gradient} paintbrush{Paintbrush} eraser{Eraser} pencil{Pencil} color_picker{Color Picker} clone_stamp{Clone Stamp} recolor{Recolor} text{Text} line_curve{Line / Curve} rectangle{Rectangle} rounded_rectangle{Rounded Rectangle} ellipse{Ellipse} freeform_shape{Freeform Shape} other{}}'**
  String toolName(String id);

  /// No description provided for @toolHint.
  ///
  /// In en, this message translates to:
  /// **'{id, select, rectangle_select{Drag to select a rectangle. Hold Shift for a square.} move_selected_pixels{Drag the selection to move it. Drag with the right button to rotate it, drag the handles to scale it. Ctrl leaves a copy; the arrow keys nudge it.} lasso_select{Drag to draw the outline of a selection.} move_selection{Drag the selection outline to move it. The pixels stay in place.} ellipse_select{Drag to select an ellipse. Hold Shift for a circle.} zoom{Left-click to zoom in, right-click to zoom out, or drag a box to zoom to it.} magic_wand{Click a color to select the area around it. Hold Shift to select it across the image.} pan{Drag to move the view.} paint_bucket{Left-click fills with the primary color, right-click with the secondary.} gradient{Drag to draw a gradient. Drag the handles to adjust it; press Enter to finish.} paintbrush{The left button paints with the primary color, the right button with the secondary.} eraser{Drag to erase to transparency.} pencil{Draws one-pixel lines without antialiasing.} color_picker{Left-click picks the primary color, right-click the secondary.} clone_stamp{Ctrl+click to set the source, then drag to paint from it.} recolor{Replaces the secondary color with the primary where you paint. Ctrl+click picks a color.} text{Click to place the cursor, then type. Drag the handle or drag with the right button to move the text; press Esc to finish.} line_curve{Drag to draw a line. Drag the handles to bend it; press Enter to finish.} rectangle{Drag to draw a rectangle. Hold Shift for a square.} rounded_rectangle{Drag to draw a rounded rectangle. Hold Shift for a square.} ellipse{Drag to draw an ellipse. Hold Shift for a circle.} freeform_shape{Drag to draw a closed freeform shape.} other{}}'**
  String toolHint(String id);

  /// No description provided for @paramName.
  ///
  /// In en, this message translates to:
  /// **'{name, select, radius{Radius} angle{Angle} distance{Distance} centered{Centered} amount{Amount} intensity{Intensity} saturation{Saturation} coverage{Coverage} seed{Seed} percentile{Percentile} cell_size{Cell Size} brush_size{Brush Size} coarseness{Coarseness} thickness{Thickness} brightness{Brightness} contrast{Contrast} hue{Hue} lightness{Lightness} red{Red} green{Green} blue{Blue} input_low{Input Low} input_high{Input High} output_low{Output Low} output_high{Output High} gamma{Gamma} ink_outline{Ink Outline} coloring{Coloring} tip_size{Pencil Tip Size} color_range{Color Range} fragments{Fragments} rotation{Rotation} offset_x{Offset X} offset_y{Offset Y} quality{Quality} threshold{Threshold} scale{Scale} refraction{Refraction} roughness{Roughness} tension{Tension} max_scatter{Maximum Scatter} min_scatter{Minimum Scatter} samples{Samples} edge_behavior{Edge Behavior} tile_size{Tile Size} curvature{Curvature} size{Size} strength{Strength} tolerance{Tolerance} softness{Softness} lighting{Lighting} warmth{Warmth} power{Power} blend_mode{Blend Mode} factor{Factor} zoom{Zoom} invert_colors{Invert Colors} other{}}'**
  String paramName(String name);

  /// No description provided for @blendModeName.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, normal{Normal} multiply{Multiply} additive{Additive} colorBurn{Color Burn} colorDodge{Color Dodge} reflect{Reflect} glow{Glow} overlay{Overlay} difference{Difference} negation{Negation} lighten{Lighten} darken{Darken} screen{Screen} xor{Xor} other{}}'**
  String blendModeName(String mode);

  /// No description provided for @failureCode.
  ///
  /// In en, this message translates to:
  /// **'{code, select, out_of_memory{There is not enough memory for the image.} invalid_size{The image size is not valid.} layer_index{There is no such layer.} last_layer{The last layer cannot be deleted.} no_layer_below{There is no layer below to merge into.} edit_in_progress{Finish what is in progress first.} no_edit{There is nothing in progress to finish.} no_selection{Nothing is selected.} nothing_lifted{No pixels are lifted.} invalid_parameter{The value is out of range.} io{The file could not be read or written.} decode{The image could not be read.} encode{The image could not be written.} open_raster{The OpenRaster file is damaged.} palette{The palette file is damaged.} cancelled{The calculation was cancelled.} other{Something went wrong.}}'**
  String failureCode(String code);

  /// No description provided for @failureStorage.
  ///
  /// In en, this message translates to:
  /// **'The file could not be read or written.'**
  String get failureStorage;

  /// No description provided for @failureInvalidData.
  ///
  /// In en, this message translates to:
  /// **'The data could not be read.'**
  String get failureInvalidData;

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected went wrong.'**
  String get failureUnknown;

  /// No description provided for @panelTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get panelTools;

  /// No description provided for @panelHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get panelHistory;

  /// No description provided for @panelLayers.
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get panelLayers;

  /// No description provided for @panelColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get panelColors;

  /// No description provided for @panelHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get panelHide;

  /// No description provided for @colorsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get colorsPrimary;

  /// No description provided for @colorsSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get colorsSecondary;

  /// No description provided for @colorsPrimaryHint.
  ///
  /// In en, this message translates to:
  /// **'Primary color: the left mouse button paints with it'**
  String get colorsPrimaryHint;

  /// No description provided for @colorsSecondaryHint.
  ///
  /// In en, this message translates to:
  /// **'Secondary color: the right mouse button paints with it'**
  String get colorsSecondaryHint;

  /// No description provided for @colorsSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap colors (X)'**
  String get colorsSwap;

  /// No description provided for @colorsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to black and white'**
  String get colorsReset;

  /// No description provided for @colorsMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get colorsMore;

  /// No description provided for @colorsLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get colorsLess;

  /// No description provided for @colorsHex.
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get colorsHex;

  /// No description provided for @colorsAlpha.
  ///
  /// In en, this message translates to:
  /// **'Alpha'**
  String get colorsAlpha;

  /// No description provided for @colorsHue.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get colorsHue;

  /// No description provided for @colorsSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get colorsSat;

  /// No description provided for @colorsValue.
  ///
  /// In en, this message translates to:
  /// **'V'**
  String get colorsValue;

  /// No description provided for @colorsRed.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get colorsRed;

  /// No description provided for @colorsGreen.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get colorsGreen;

  /// No description provided for @colorsBlue.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get colorsBlue;

  /// No description provided for @colorsPaletteHint.
  ///
  /// In en, this message translates to:
  /// **'Left-click sets the primary color, right-click the secondary'**
  String get colorsPaletteHint;

  /// No description provided for @settingWidth.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get settingWidth;

  /// No description provided for @settingHardness.
  ///
  /// In en, this message translates to:
  /// **'Hardness'**
  String get settingHardness;

  /// No description provided for @settingAntialias.
  ///
  /// In en, this message translates to:
  /// **'Antialiasing'**
  String get settingAntialias;

  /// No description provided for @settingAlphaBlending.
  ///
  /// In en, this message translates to:
  /// **'Alpha blending'**
  String get settingAlphaBlending;

  /// No description provided for @settingTolerance.
  ///
  /// In en, this message translates to:
  /// **'Tolerance'**
  String get settingTolerance;

  /// No description provided for @settingFloodMode.
  ///
  /// In en, this message translates to:
  /// **'Flood mode'**
  String get settingFloodMode;

  /// No description provided for @floodLocal.
  ///
  /// In en, this message translates to:
  /// **'Contiguous'**
  String get floodLocal;

  /// No description provided for @floodGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get floodGlobal;

  /// No description provided for @settingSelectionMode.
  ///
  /// In en, this message translates to:
  /// **'Selection mode'**
  String get settingSelectionMode;

  /// No description provided for @combineMode.
  ///
  /// In en, this message translates to:
  /// **'{mode, select, replace{Replace} union{Union} exclude{Exclude} xor{Xor} intersect{Intersect} other{}}'**
  String combineMode(String mode);

  /// No description provided for @settingDrawMode.
  ///
  /// In en, this message translates to:
  /// **'Selection size'**
  String get settingDrawMode;

  /// No description provided for @drawNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get drawNormal;

  /// No description provided for @drawFixedRatio.
  ///
  /// In en, this message translates to:
  /// **'Fixed Ratio'**
  String get drawFixedRatio;

  /// No description provided for @drawFixedSize.
  ///
  /// In en, this message translates to:
  /// **'Fixed Size'**
  String get drawFixedSize;

  /// No description provided for @settingResampling.
  ///
  /// In en, this message translates to:
  /// **'Resampling'**
  String get settingResampling;

  /// No description provided for @resamplingNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest neighbor'**
  String get resamplingNearest;

  /// No description provided for @resamplingBilinear.
  ///
  /// In en, this message translates to:
  /// **'Bilinear'**
  String get resamplingBilinear;

  /// No description provided for @settingGradient.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get settingGradient;

  /// No description provided for @gradientKind.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, linear{Linear} linearReflected{Linear Reflected} diamond{Diamond} radial{Radial} conical{Conical} other{}}'**
  String gradientKind(String kind);

  /// No description provided for @gradientColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get gradientColor;

  /// No description provided for @gradientTransparency.
  ///
  /// In en, this message translates to:
  /// **'Transparency'**
  String get gradientTransparency;

  /// No description provided for @settingShape.
  ///
  /// In en, this message translates to:
  /// **'Shape style'**
  String get settingShape;

  /// No description provided for @shapeOutline.
  ///
  /// In en, this message translates to:
  /// **'Outline'**
  String get shapeOutline;

  /// No description provided for @shapeInterior.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get shapeInterior;

  /// No description provided for @shapeBoth.
  ///
  /// In en, this message translates to:
  /// **'Outline and fill'**
  String get shapeBoth;

  /// No description provided for @settingAfterPick.
  ///
  /// In en, this message translates to:
  /// **'After picking'**
  String get settingAfterPick;

  /// No description provided for @pickStay.
  ///
  /// In en, this message translates to:
  /// **'Keep this tool'**
  String get pickStay;

  /// No description provided for @pickPrevious.
  ///
  /// In en, this message translates to:
  /// **'Switch to the previous tool'**
  String get pickPrevious;

  /// No description provided for @pickPencil.
  ///
  /// In en, this message translates to:
  /// **'Switch to the Pencil'**
  String get pickPencil;

  /// No description provided for @settingNone.
  ///
  /// In en, this message translates to:
  /// **'This tool has no settings.'**
  String get settingNone;

  /// No description provided for @toolUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{name} is not available yet'**
  String toolUnavailable(String name);

  /// No description provided for @historyFirst.
  ///
  /// In en, this message translates to:
  /// **'Go to the first step'**
  String get historyFirst;

  /// No description provided for @historyUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get historyUndo;

  /// No description provided for @historyRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get historyRedo;

  /// No description provided for @historyLast.
  ///
  /// In en, this message translates to:
  /// **'Go to the last step'**
  String get historyLast;

  /// No description provided for @historyNewImage.
  ///
  /// In en, this message translates to:
  /// **'New Image'**
  String get historyNewImage;

  /// No description provided for @historyOpenImage.
  ///
  /// In en, this message translates to:
  /// **'Open Image'**
  String get historyOpenImage;

  /// No description provided for @layerVisible.
  ///
  /// In en, this message translates to:
  /// **'Show or hide the layer'**
  String get layerVisible;

  /// No description provided for @layerBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get layerBackground;

  /// No description provided for @layerName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get layerName;

  /// No description provided for @layerOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get layerOpacity;

  /// No description provided for @layerBlendMode.
  ///
  /// In en, this message translates to:
  /// **'Blend mode'**
  String get layerBlendMode;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @dontSave.
  ///
  /// In en, this message translates to:
  /// **'Don\'t save'**
  String get dontSave;

  /// No description provided for @keepCanvas.
  ///
  /// In en, this message translates to:
  /// **'Keep the canvas'**
  String get keepCanvas;

  /// No description provided for @expandCanvas.
  ///
  /// In en, this message translates to:
  /// **'Expand the canvas'**
  String get expandCanvas;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @pixels.
  ///
  /// In en, this message translates to:
  /// **'pixels'**
  String get pixels;

  /// No description provided for @newImageTitle.
  ///
  /// In en, this message translates to:
  /// **'New Image'**
  String get newImageTitle;

  /// No description provided for @resizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Resize Image'**
  String get resizeTitle;

  /// No description provided for @canvasSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Canvas Size'**
  String get canvasSizeTitle;

  /// No description provided for @keepRatio.
  ///
  /// In en, this message translates to:
  /// **'Maintain aspect ratio'**
  String get keepRatio;

  /// No description provided for @anchor.
  ///
  /// In en, this message translates to:
  /// **'Anchor'**
  String get anchor;

  /// No description provided for @sizeTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The image is too large: the limit is {max} megapixels.'**
  String sizeTooLarge(int max);

  /// No description provided for @unsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Save changes?'**
  String get unsavedTitle;

  /// No description provided for @unsavedMessage.
  ///
  /// In en, this message translates to:
  /// **'“{name}” has unsaved changes.'**
  String unsavedMessage(String name);

  /// No description provided for @flattenTitle.
  ///
  /// In en, this message translates to:
  /// **'Flatten the image?'**
  String get flattenTitle;

  /// No description provided for @flattenMessage.
  ///
  /// In en, this message translates to:
  /// **'The {format} format does not keep layers, so the image will be flattened into one layer. You can undo this in the History window.'**
  String flattenMessage(String format);

  /// No description provided for @flatten.
  ///
  /// In en, this message translates to:
  /// **'Flatten'**
  String get flatten;

  /// No description provided for @jpegQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'JPEG Quality'**
  String get jpegQualityTitle;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @largerTitle.
  ///
  /// In en, this message translates to:
  /// **'The image is larger than the canvas'**
  String get largerTitle;

  /// No description provided for @largerMessage.
  ///
  /// In en, this message translates to:
  /// **'Expand the canvas to hold it?'**
  String get largerMessage;

  /// No description provided for @reseed.
  ///
  /// In en, this message translates to:
  /// **'Reseed'**
  String get reseed;

  /// No description provided for @rendering.
  ///
  /// In en, this message translates to:
  /// **'Rendering…'**
  String get rendering;

  /// No description provided for @statusPointer.
  ///
  /// In en, this message translates to:
  /// **'{x}, {y}'**
  String statusPointer(int x, int y);

  /// No description provided for @statusSelection.
  ///
  /// In en, this message translates to:
  /// **'{width} × {height}'**
  String statusSelection(int width, int height);

  /// No description provided for @statusZoom.
  ///
  /// In en, this message translates to:
  /// **'{percent} %'**
  String statusZoom(String percent);

  /// No description provided for @statusOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening {name}…'**
  String statusOpening(String name);

  /// No description provided for @statusSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving {name}…'**
  String statusSaving(String name);

  /// No description provided for @savedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved: {name}'**
  String savedTo(String name);

  /// No description provided for @dropHere.
  ///
  /// In en, this message translates to:
  /// **'Drop to open'**
  String get dropHere;

  /// No description provided for @dropHint.
  ///
  /// In en, this message translates to:
  /// **'Each file opens as a new image'**
  String get dropHint;

  /// No description provided for @imagesList.
  ///
  /// In en, this message translates to:
  /// **'Open images'**
  String get imagesList;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Paintbox'**
  String get helpTitle;

  /// No description provided for @helpMessage.
  ///
  /// In en, this message translates to:
  /// **'A raster image editor with layers. Press a letter to choose a tool; pressing S, M or O again cycles through the related tools. [ and ] change the brush width, X swaps the colors, holding Space pans the view, Ctrl+mouse wheel zooms, and F5–F8 show or hide the windows.'**
  String get helpMessage;

  /// No description provided for @settingLineStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get settingLineStart;

  /// No description provided for @settingLineEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get settingLineEnd;

  /// No description provided for @settingDash.
  ///
  /// In en, this message translates to:
  /// **'Dash'**
  String get settingDash;

  /// No description provided for @settingSwapSize.
  ///
  /// In en, this message translates to:
  /// **'Swap width and height'**
  String get settingSwapSize;

  /// No description provided for @settingLineStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get settingLineStyle;

  /// No description provided for @lineCap.
  ///
  /// In en, this message translates to:
  /// **'{cap, select, flat{Flat} arrow{Arrow} arrowFilled{Filled arrow} rounded{Rounded} other{}}'**
  String lineCap(String cap);

  /// No description provided for @dashStyle.
  ///
  /// In en, this message translates to:
  /// **'{dash, select, solid{Solid} dash{Dash} dashDot{Dash dot} dashDotDot{Dash dot dot} dot{Dot} other{}}'**
  String dashStyle(String dash);

  /// No description provided for @settingFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get settingFont;

  /// No description provided for @settingFontSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get settingFontSize;

  /// No description provided for @textBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get textBold;

  /// No description provided for @textItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get textItalic;

  /// No description provided for @textUnderline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get textUnderline;

  /// No description provided for @textStrikeout.
  ///
  /// In en, this message translates to:
  /// **'Strikeout'**
  String get textStrikeout;

  /// No description provided for @textAlign.
  ///
  /// In en, this message translates to:
  /// **'{align, select, left{Left} center{Center} right{Right} other{}}'**
  String textAlign(String align);

  /// The file dialogs' type that takes every image format.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get fileTypeImages;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'be',
    'bg',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'hr',
    'hu',
    'it',
    'kk',
    'lt',
    'lv',
    'nl',
    'pl',
    'pt',
    'ro',
    'sk',
    'sv',
    'tr',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'be':
      return AppLocalizationsBe();
    case 'bg':
      return AppLocalizationsBg();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'it':
      return AppLocalizationsIt();
    case 'kk':
      return AppLocalizationsKk();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'sk':
      return AppLocalizationsSk();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
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
