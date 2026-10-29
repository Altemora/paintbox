// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Untitled $number';
  }

  @override
  String get menuFile => 'File';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuView => 'View';

  @override
  String get menuImage => 'Image';

  @override
  String get menuLayers => 'Layers';

  @override
  String get menuAdjustments => 'Adjustments';

  @override
  String get menuEffects => 'Effects';

  @override
  String get menuOpenRecent => 'Open Recent';

  @override
  String get menuRecentEmpty => 'No recent files';

  @override
  String get menuTheme => 'Theme';

  @override
  String get menuSettings => 'Settings';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'As the system';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'New…',
      'open': 'Open…',
      'close': 'Close',
      'save': 'Save',
      'save_as': 'Save As…',
      'exit': 'Exit',
      'undo': 'Undo',
      'redo': 'Redo',
      'cut': 'Cut',
      'copy': 'Copy',
      'paste': 'Paste',
      'paste_into_new_layer': 'Paste into New Layer',
      'paste_into_new_image': 'Paste into New Image',
      'erase_selection': 'Erase Selection',
      'fill_selection': 'Fill Selection',
      'invert_selection': 'Invert Selection',
      'select_all': 'Select All',
      'deselect': 'Deselect',
      'zoom_in': 'Zoom In',
      'zoom_out': 'Zoom Out',
      'zoom_to_window': 'Zoom to Window',
      'zoom_to_selection': 'Zoom to Selection',
      'actual_size': 'Actual Size',
      'pixel_grid': 'Pixel Grid',
      'rulers': 'Rulers',
      'crop_to_selection': 'Crop to Selection',
      'resize': 'Resize…',
      'canvas_size': 'Canvas Size…',
      'flip_horizontal': 'Flip Horizontal',
      'flip_vertical': 'Flip Vertical',
      'rotate90_cw': 'Rotate 90° Clockwise',
      'rotate90_ccw': 'Rotate 90° Counter-clockwise',
      'rotate180': 'Rotate 180°',
      'flatten': 'Flatten',
      'add_layer': 'Add New Layer',
      'delete_layer': 'Delete Layer',
      'duplicate_layer': 'Duplicate Layer',
      'merge_layer_down': 'Merge Layer Down',
      'import_from_file': 'Import From File…',
      'flip_layer_horizontal': 'Flip Horizontal',
      'flip_layer_vertical': 'Flip Vertical',
      'move_layer_up': 'Move Layer Up',
      'move_layer_down': 'Move Layer Down',
      'layer_properties': 'Layer Properties…',
      'adjust_auto_level': 'Auto-Level',
      'adjust_black_and_white': 'Black and White',
      'adjust_brightness_contrast': 'Brightness / Contrast…',
      'adjust_curves': 'Curves…',
      'adjust_hue_saturation': 'Hue / Saturation…',
      'adjust_invert_colors': 'Invert Colors',
      'adjust_levels': 'Levels…',
      'adjust_posterize': 'Posterize…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Repeat',
      'effect_oil_painting': 'Oil Painting…',
      'effect_gaussian_blur': 'Gaussian Blur…',
      'effect_motion_blur': 'Motion Blur…',
      'effect_pixelate': 'Pixelate…',
      'effect_add_noise': 'Add Noise…',
      'effect_median': 'Median…',
      'effect_sharpen': 'Sharpen…',
      'effect_edge_detect': 'Edge Detect…',
      'effect_emboss': 'Emboss…',
      'effect_outline': 'Outline…',
      'toggle_tools': 'Tools',
      'toggle_history': 'History',
      'toggle_layers': 'Layers',
      'toggle_colors': 'Colors',
      'next_image': 'Next Image',
      'previous_image': 'Previous Image',
      'help': 'Help Topics',
      'effect_ink_sketch': 'Ink Sketch…',
      'effect_pencil_sketch': 'Pencil Sketch…',
      'effect_fragment': 'Fragment…',
      'effect_radial_blur': 'Radial Blur…',
      'effect_surface_blur': 'Surface Blur…',
      'effect_unfocus': 'Unfocus…',
      'effect_zoom_blur': 'Zoom Blur…',
      'effect_bulge': 'Bulge…',
      'effect_dents': 'Dents…',
      'effect_frosted_glass': 'Frosted Glass…',
      'effect_polar_inversion': 'Polar Inversion…',
      'effect_tile_reflection': 'Tile Reflection…',
      'effect_twist': 'Twist…',
      'effect_reduce_noise': 'Reduce Noise…',
      'effect_glow': 'Glow…',
      'effect_red_eye_removal': 'Red Eye Removal…',
      'effect_soften_portrait': 'Soften Portrait…',
      'effect_clouds': 'Clouds…',
      'effect_julia_fractal': 'Julia Fractal…',
      'effect_mandelbrot_fractal': 'Mandelbrot Fractal…',
      'effect_relief': 'Relief…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dialogTitle(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'adjust_brightness_contrast': 'Brightness / Contrast',
      'adjust_curves': 'Curves',
      'adjust_hue_saturation': 'Hue / Saturation',
      'adjust_levels': 'Levels',
      'adjust_posterize': 'Posterize',
      'effect_oil_painting': 'Oil Painting',
      'effect_gaussian_blur': 'Gaussian Blur',
      'effect_motion_blur': 'Motion Blur',
      'effect_pixelate': 'Pixelate',
      'effect_add_noise': 'Add Noise',
      'effect_median': 'Median',
      'effect_sharpen': 'Sharpen',
      'effect_edge_detect': 'Edge Detect',
      'effect_emboss': 'Emboss',
      'effect_outline': 'Outline',
      'layer_properties': 'Layer Properties',
      'effect_ink_sketch': 'Ink Sketch',
      'effect_pencil_sketch': 'Pencil Sketch',
      'effect_fragment': 'Fragment',
      'effect_radial_blur': 'Radial Blur',
      'effect_surface_blur': 'Surface Blur',
      'effect_unfocus': 'Unfocus',
      'effect_zoom_blur': 'Zoom Blur',
      'effect_bulge': 'Bulge',
      'effect_dents': 'Dents',
      'effect_frosted_glass': 'Frosted Glass',
      'effect_polar_inversion': 'Polar Inversion',
      'effect_tile_reflection': 'Tile Reflection',
      'effect_twist': 'Twist',
      'effect_reduce_noise': 'Reduce Noise',
      'effect_glow': 'Glow',
      'effect_red_eye_removal': 'Red Eye Removal',
      'effect_soften_portrait': 'Soften Portrait',
      'effect_clouds': 'Clouds',
      'effect_julia_fractal': 'Julia Fractal',
      'effect_mandelbrot_fractal': 'Mandelbrot Fractal',
      'effect_relief': 'Relief',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artistic',
      'blurs': 'Blurs',
      'distort': 'Distort',
      'noise': 'Noise',
      'photo': 'Photo',
      'stylize': 'Stylize',
      'render': 'Render',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Rectangle Select',
      'move_selected_pixels': 'Move Selected Pixels',
      'lasso_select': 'Lasso Select',
      'move_selection': 'Move Selection',
      'ellipse_select': 'Ellipse Select',
      'zoom': 'Zoom',
      'magic_wand': 'Magic Wand',
      'pan': 'Pan',
      'paint_bucket': 'Paint Bucket',
      'gradient': 'Gradient',
      'paintbrush': 'Paintbrush',
      'eraser': 'Eraser',
      'pencil': 'Pencil',
      'color_picker': 'Color Picker',
      'clone_stamp': 'Clone Stamp',
      'recolor': 'Recolor',
      'text': 'Text',
      'line_curve': 'Line / Curve',
      'rectangle': 'Rectangle',
      'rounded_rectangle': 'Rounded Rectangle',
      'ellipse': 'Ellipse',
      'freeform_shape': 'Freeform Shape',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Drag to select a rectangle. Shift makes a square.',
      'move_selected_pixels': 'Drag the selection to move it: the right button turns it, the handles scale it. Ctrl leaves a copy, the arrow keys nudge.',
      'lasso_select': 'Drag to draw the outline of a selection.',
      'move_selection': 'Drag the selection outline. The pixels stay.',
      'ellipse_select': 'Drag to select an ellipse. Shift makes a circle.',
      'zoom': 'Left click zooms in, right click zooms out, a drawn box zooms to it.',
      'magic_wand': 'Click to select an area of similar colour. Shift selects over the whole image.',
      'pan': 'Drag to move the view.',
      'paint_bucket': 'Left click fills with the primary colour, right click with the secondary.',
      'gradient':
          'Drag to draw a gradient. The handles change it, Enter finishes.',
      'paintbrush': 'The left button paints with the primary colour, the right with the secondary.',
      'eraser': 'Drag to erase to transparency.',
      'pencil': 'Draws one-pixel lines without antialiasing.',
      'color_picker':
          'Left click picks the primary colour, right click the secondary.',
      'clone_stamp': 'Ctrl+click sets the source, then drag to paint from it.',
      'recolor': 'Replaces the secondary colour with the primary where you paint. Ctrl+click picks.',
      'text': 'Click to place the cursor, then type. The right button or the handle moves the text, Esc finishes.',
      'line_curve': 'Drag to draw a line. The handles bend it, Enter finishes.',
      'rectangle': 'Drag to draw a rectangle. Shift makes a square.',
      'rounded_rectangle':
          'Drag to draw a rounded rectangle. Shift makes a square.',
      'ellipse': 'Drag to draw an ellipse. Shift makes a circle.',
      'freeform_shape': 'Drag to draw a closed freeform shape.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Radius',
      'angle': 'Angle',
      'distance': 'Distance',
      'centered': 'Centered',
      'amount': 'Amount',
      'intensity': 'Intensity',
      'saturation': 'Saturation',
      'coverage': 'Coverage',
      'seed': 'Seed',
      'percentile': 'Percentile',
      'cell_size': 'Cell Size',
      'brush_size': 'Brush Size',
      'coarseness': 'Coarseness',
      'thickness': 'Thickness',
      'brightness': 'Brightness',
      'contrast': 'Contrast',
      'hue': 'Hue',
      'lightness': 'Lightness',
      'red': 'Red',
      'green': 'Green',
      'blue': 'Blue',
      'input_low': 'Input Low',
      'input_high': 'Input High',
      'output_low': 'Output Low',
      'output_high': 'Output High',
      'gamma': 'Gamma',
      'ink_outline': 'Ink Outline',
      'coloring': 'Coloring',
      'tip_size': 'Pencil Tip Size',
      'color_range': 'Color Range',
      'fragments': 'Fragments',
      'rotation': 'Rotation',
      'offset_x': 'Offset X',
      'offset_y': 'Offset Y',
      'quality': 'Quality',
      'threshold': 'Threshold',
      'scale': 'Scale',
      'refraction': 'Refraction',
      'roughness': 'Roughness',
      'tension': 'Tension',
      'max_scatter': 'Maximum Scatter',
      'min_scatter': 'Minimum Scatter',
      'samples': 'Samples',
      'edge_behavior': 'Edge Behavior',
      'tile_size': 'Tile Size',
      'curvature': 'Curvature',
      'size': 'Size',
      'strength': 'Strength',
      'tolerance': 'Tolerance',
      'softness': 'Softness',
      'lighting': 'Lighting',
      'warmth': 'Warmth',
      'power': 'Power',
      'blend_mode': 'Blend Mode',
      'factor': 'Factor',
      'zoom': 'Zoom',
      'invert_colors': 'Invert Colors',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Multiply',
      'additive': 'Additive',
      'colorBurn': 'Color Burn',
      'colorDodge': 'Color Dodge',
      'reflect': 'Reflect',
      'glow': 'Glow',
      'overlay': 'Overlay',
      'difference': 'Difference',
      'negation': 'Negation',
      'lighten': 'Lighten',
      'darken': 'Darken',
      'screen': 'Screen',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'There is not enough memory for the image.',
      'invalid_size': 'An image cannot have this size.',
      'layer_index': 'There is no such layer.',
      'last_layer': 'The last layer cannot be deleted.',
      'no_layer_below': 'There is no layer below to merge into.',
      'edit_in_progress': 'Finish what is in progress first.',
      'no_edit': 'There is nothing to finish.',
      'no_selection': 'Nothing is selected.',
      'nothing_lifted': 'Nothing is lifted.',
      'invalid_parameter': 'The value is out of range.',
      'io': 'The file could not be read or written.',
      'decode': 'The image could not be read.',
      'encode': 'The image could not be written.',
      'open_raster': 'The OpenRaster file is damaged.',
      'palette': 'The palette file is damaged.',
      'cancelled': 'The render was cancelled.',
      'other': 'Something went wrong.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'The file could not be read or written.';

  @override
  String get failureInvalidData => 'The data could not be read.';

  @override
  String get failureUnknown => 'Something unexpected went wrong.';

  @override
  String get panelTools => 'Tools';

  @override
  String get panelHistory => 'History';

  @override
  String get panelLayers => 'Layers';

  @override
  String get panelColors => 'Colors';

  @override
  String get panelHide => 'Hide';

  @override
  String get colorsPrimary => 'Primary';

  @override
  String get colorsSecondary => 'Secondary';

  @override
  String get colorsPrimaryHint =>
      'The primary colour: the left button paints with it';

  @override
  String get colorsSecondaryHint =>
      'The secondary colour: the right button paints with it';

  @override
  String get colorsSwap => 'Swap colours (X)';

  @override
  String get colorsReset => 'Black and white';

  @override
  String get colorsMore => 'More';

  @override
  String get colorsLess => 'Less';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Alpha';

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
      'Left button: the primary colour, right: the secondary';

  @override
  String get settingWidth => 'Width';

  @override
  String get settingHardness => 'Hardness';

  @override
  String get settingAntialias => 'Antialiasing';

  @override
  String get settingAlphaBlending => 'Alpha blending';

  @override
  String get settingTolerance => 'Tolerance';

  @override
  String get settingFloodMode => 'Flood mode';

  @override
  String get floodLocal => 'Contiguous';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Selection mode';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Replace',
      'union': 'Union',
      'exclude': 'Exclude',
      'xor': 'Xor',
      'intersect': 'Intersect',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Draw mode';

  @override
  String get drawNormal => 'Normal';

  @override
  String get drawFixedRatio => 'Fixed Ratio';

  @override
  String get drawFixedSize => 'Fixed Size';

  @override
  String get settingResampling => 'Resampling';

  @override
  String get resamplingNearest => 'Nearest neighbor';

  @override
  String get resamplingBilinear => 'Bilinear';

  @override
  String get settingGradient => 'Type';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Linear',
      'linearReflected': 'Linear Reflected',
      'diamond': 'Diamond',
      'radial': 'Radial',
      'conical': 'Conical',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Color';

  @override
  String get gradientTransparency => 'Transparency';

  @override
  String get settingShape => 'Draws';

  @override
  String get shapeOutline => 'Outline';

  @override
  String get shapeInterior => 'Fill';

  @override
  String get shapeBoth => 'Outline and fill';

  @override
  String get settingAfterPick => 'After click';

  @override
  String get pickStay => 'Do not switch';

  @override
  String get pickPrevious => 'Previous tool';

  @override
  String get pickPencil => 'Pencil';

  @override
  String get settingNone => 'This tool has no settings.';

  @override
  String toolUnavailable(String name) {
    return '$name is not made yet';
  }

  @override
  String get historyFirst => 'To the start';

  @override
  String get historyUndo => 'Undo';

  @override
  String get historyRedo => 'Redo';

  @override
  String get historyLast => 'To the end';

  @override
  String get historyNewImage => 'New Image';

  @override
  String get historyOpenImage => 'Open Image';

  @override
  String get layerVisible => 'Whether the layer shows';

  @override
  String get layerBackground => 'Background';

  @override
  String get layerName => 'Name';

  @override
  String get layerOpacity => 'Opacity';

  @override
  String get layerBlendMode => 'Blend mode';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get dontSave => 'Don\'t save';

  @override
  String get keepCanvas => 'Keep the canvas';

  @override
  String get expandCanvas => 'Expand the canvas';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get pixels => 'pixels';

  @override
  String get newImageTitle => 'New Image';

  @override
  String get resizeTitle => 'Resize Image';

  @override
  String get canvasSizeTitle => 'Canvas Size';

  @override
  String get keepRatio => 'Maintain aspect ratio';

  @override
  String get anchor => 'Anchor';

  @override
  String sizeTooLarge(int max) {
    return 'The image is too large: at most $max megapixels.';
  }

  @override
  String get unsavedTitle => 'Save changes?';

  @override
  String unsavedMessage(String name) {
    return '“$name” has unsaved changes.';
  }

  @override
  String get flattenTitle => 'Flatten the image?';

  @override
  String flattenMessage(String format) {
    return '$format keeps no layers: the image will be flattened into one. History can undo it.';
  }

  @override
  String get flatten => 'Flatten';

  @override
  String get jpegQualityTitle => 'JPEG Quality';

  @override
  String get quality => 'Quality';

  @override
  String get largerTitle => 'The image is larger than the canvas';

  @override
  String get largerMessage => 'Expand the canvas to hold it?';

  @override
  String get reseed => 'Reseed';

  @override
  String get rendering => 'Rendering…';

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
    return 'Opening $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Saving $name…';
  }

  @override
  String savedTo(String name) {
    return 'Saved: $name';
  }

  @override
  String get dropHere => 'Open';

  @override
  String get dropHint => 'Each file opens as a new image';

  @override
  String get imagesList => 'Open images';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'An image editor with layers. Tools by letter (S, M, O cycle their neighbours), [ and ] the brush width, X swaps the colours, Space pans, Ctrl+wheel zooms, F5–F8 the windows.';

  @override
  String get settingLineStart => 'Start';

  @override
  String get settingLineEnd => 'End';

  @override
  String get settingDash => 'Dash';

  @override
  String get settingSwapSize => 'Swap width and height';

  @override
  String get settingLineStyle => 'Style';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Flat',
      'arrow': 'Arrow',
      'arrowFilled': 'Filled arrow',
      'rounded': 'Rounded',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Solid',
      'dash': 'Dash',
      'dashDot': 'Dash dot',
      'dashDotDot': 'Dash dot dot',
      'dot': 'Dot',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Font';

  @override
  String get settingFontSize => 'Size';

  @override
  String get textBold => 'Bold';

  @override
  String get textItalic => 'Italic';

  @override
  String get textUnderline => 'Underline';

  @override
  String get textStrikeout => 'Strikeout';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Left',
      'center': 'Center',
      'right': 'Right',
      'other': '',
    });
    return '$_temp0';
  }
}
