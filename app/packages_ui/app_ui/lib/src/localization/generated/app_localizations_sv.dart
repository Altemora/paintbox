// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Namnlös $number';
  }

  @override
  String get menuFile => 'Arkiv';

  @override
  String get menuEdit => 'Redigera';

  @override
  String get menuView => 'Visa';

  @override
  String get menuImage => 'Bild';

  @override
  String get menuLayers => 'Lager';

  @override
  String get menuAdjustments => 'Justeringar';

  @override
  String get menuEffects => 'Effekter';

  @override
  String get menuOpenRecent => 'Öppna senaste';

  @override
  String get menuRecentEmpty => 'Inga senaste filer';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Inställningar';

  @override
  String get menuAccent => 'Accentfärg';

  @override
  String get menuLanguage => 'Språk';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Blå',
      'green': 'Grön',
      'amber': 'Bärnsten',
      'purple': 'Lila',
      'red': 'Röd',
      'gray': 'Grå',
      'custom': 'Anpassad…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Anpassad accentfärg';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get themeDark => 'Mörkt';

  @override
  String get themeLight => 'Ljust';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nytt…',
      'open': 'Öppna…',
      'close': 'Stäng',
      'save': 'Spara',
      'save_as': 'Spara som…',
      'exit': 'Avsluta',
      'undo': 'Ångra',
      'redo': 'Gör om',
      'cut': 'Klipp ut',
      'copy': 'Kopiera',
      'paste': 'Klistra in',
      'paste_into_new_layer': 'Klistra in i nytt lager',
      'paste_into_new_image': 'Klistra in i ny bild',
      'erase_selection': 'Radera markerat område',
      'fill_selection': 'Fyll markering',
      'invert_selection': 'Invertera markering',
      'select_all': 'Markera allt',
      'deselect': 'Avmarkera',
      'zoom_in': 'Zooma in',
      'zoom_out': 'Zooma ut',
      'zoom_to_window': 'Anpassa till fönster',
      'zoom_to_selection': 'Zooma till markering',
      'actual_size': 'Verklig storlek',
      'pixel_grid': 'Pixelrutnät',
      'rulers': 'Linjaler',
      'crop_to_selection': 'Beskär till markering',
      'resize': 'Ändra storlek…',
      'canvas_size': 'Arbetsytans storlek…',
      'flip_horizontal': 'Vänd vågrätt',
      'flip_vertical': 'Vänd lodrätt',
      'rotate90_cw': 'Rotera 90° medurs',
      'rotate90_ccw': 'Rotera 90° moturs',
      'rotate180': 'Rotera 180°',
      'flatten': 'Platta till',
      'add_layer': 'Lägg till nytt lager',
      'delete_layer': 'Ta bort lager',
      'duplicate_layer': 'Duplicera lager',
      'merge_layer_down': 'Sammanfoga lager nedåt',
      'import_from_file': 'Importera från fil…',
      'flip_layer_horizontal': 'Vänd lager vågrätt',
      'flip_layer_vertical': 'Vänd lager lodrätt',
      'move_layer_up': 'Flytta lager uppåt',
      'move_layer_down': 'Flytta lager nedåt',
      'layer_properties': 'Lageregenskaper…',
      'adjust_auto_level': 'Autonivå',
      'adjust_black_and_white': 'Svartvitt',
      'adjust_brightness_contrast': 'Ljusstyrka / kontrast…',
      'adjust_curves': 'Kurvor…',
      'adjust_hue_saturation': 'Nyans / mättnad…',
      'adjust_invert_colors': 'Invertera färger',
      'adjust_levels': 'Nivåer…',
      'adjust_posterize': 'Posterisera…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Upprepa effekt',
      'effect_oil_painting': 'Oljemålning…',
      'effect_gaussian_blur': 'Gaussisk oskärpa…',
      'effect_motion_blur': 'Rörelseoskärpa…',
      'effect_pixelate': 'Pixla…',
      'effect_add_noise': 'Lägg till brus…',
      'effect_median': 'Median…',
      'effect_sharpen': 'Skärpa…',
      'effect_edge_detect': 'Kantdetektering…',
      'effect_emboss': 'Prägling…',
      'effect_outline': 'Kontur…',
      'toggle_tools': 'Verktyg',
      'toggle_history': 'Historik',
      'toggle_layers': 'Lager',
      'toggle_colors': 'Färger',
      'next_image': 'Nästa bild',
      'previous_image': 'Föregående bild',
      'help': 'Hjälp',
      'effect_ink_sketch': 'Bläckskiss…',
      'effect_pencil_sketch': 'Blyertsskiss…',
      'effect_fragment': 'Fragment…',
      'effect_radial_blur': 'Radiell oskärpa…',
      'effect_surface_blur': 'Ytoskärpa…',
      'effect_unfocus': 'Avfokusering…',
      'effect_zoom_blur': 'Zoomoskärpa…',
      'effect_bulge': 'Utbuktning…',
      'effect_dents': 'Bucklor…',
      'effect_frosted_glass': 'Frostat glas…',
      'effect_polar_inversion': 'Polär inversion…',
      'effect_tile_reflection': 'Rutreflektion…',
      'effect_twist': 'Vridning…',
      'effect_reduce_noise': 'Minska brus…',
      'effect_glow': 'Glöd…',
      'effect_red_eye_removal': 'Ta bort röda ögon…',
      'effect_soften_portrait': 'Mjuka upp porträtt…',
      'effect_clouds': 'Moln…',
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
      'artistic': 'Konstnärligt',
      'blurs': 'Oskärpa',
      'distort': 'Förvrängning',
      'noise': 'Brus',
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
      'move_selected_pixels': 'Flytta markerade pixlar',
      'lasso_select': 'Lassomarkering',
      'move_selection': 'Flytta markering',
      'ellipse_select': 'Ellipsmarkering',
      'zoom': 'Zoom',
      'magic_wand': 'Trollstav',
      'pan': 'Hand',
      'paint_bucket': 'Färghink',
      'gradient': 'Övertoning',
      'paintbrush': 'Pensel',
      'eraser': 'Suddgummi',
      'pencil': 'Blyertspenna',
      'color_picker': 'Pipett',
      'clone_stamp': 'Klonstämpel',
      'recolor': 'Omfärgning',
      'text': 'Text',
      'line_curve': 'Linje / kurva',
      'rectangle': 'Rektangel',
      'rounded_rectangle': 'Rundad rektangel',
      'ellipse': 'Ellips',
      'freeform_shape': 'Frihandsform',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select':
          'Dra för att markera en rektangel. Håll ned Shift för en kvadrat.',
      'move_selected_pixels': 'Dra markeringen för att flytta den. Dra med höger knapp för att rotera den och dra i handtagen för att skala den. Ctrl lämnar kvar en kopia; piltangenterna flyttar den stegvis.',
      'lasso_select': 'Dra för att rita konturen av en markering.',
      'move_selection': 'Dra markeringskonturen för att flytta den. Pixlarna stannar på plats.',
      'ellipse_select':
          'Dra för att markera en ellips. Håll ned Shift för en cirkel.',
      'zoom': 'Vänsterklicka för att zooma in, högerklicka för att zooma ut eller dra en ram för att zooma till den.',
      'magic_wand': 'Klicka på en färg för att markera området runt den. Håll ned Shift för att markera färgen i hela bilden.',
      'pan': 'Dra för att flytta vyn.',
      'paint_bucket': 'Vänsterklick fyller med primärfärgen, högerklick med sekundärfärgen.',
      'gradient': 'Dra för att rita en övertoning. Dra i handtagen för att justera den; tryck på Enter för att slutföra.',
      'paintbrush': 'Vänster knapp målar med primärfärgen, höger knapp med sekundärfärgen.',
      'eraser': 'Dra för att sudda ut till genomskinlighet.',
      'pencil': 'Ritar en pixel breda linjer utan kantutjämning.',
      'color_picker':
          'Vänsterklick hämtar primärfärgen, högerklick sekundärfärgen.',
      'clone_stamp': 'Ctrl+klicka för att ange källan och dra sedan för att måla från den.',
      'recolor': 'Ersätter sekundärfärgen med primärfärgen där du målar. Ctrl+klick hämtar en färg.',
      'text': 'Klicka för att placera markören och skriv sedan. Dra i handtaget eller dra med höger knapp för att flytta texten; tryck på Esc för att slutföra.',
      'line_curve': 'Dra för att rita en linje. Dra i handtagen för att böja den; tryck på Enter för att slutföra.',
      'rectangle':
          'Dra för att rita en rektangel. Håll ned Shift för en kvadrat.',
      'rounded_rectangle': 'Dra för att rita en rundad rektangel. Håll ned Shift för en kvadrat.',
      'ellipse': 'Dra för att rita en ellips. Håll ned Shift för en cirkel.',
      'freeform_shape': 'Dra för att rita en sluten frihandsform.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Radie',
      'angle': 'Vinkel',
      'distance': 'Avstånd',
      'centered': 'Centrerad',
      'amount': 'Mängd',
      'intensity': 'Intensitet',
      'saturation': 'Mättnad',
      'coverage': 'Täckning',
      'seed': 'Startvärde',
      'percentile': 'Percentil',
      'cell_size': 'Cellstorlek',
      'brush_size': 'Penselstorlek',
      'coarseness': 'Kornighet',
      'thickness': 'Tjocklek',
      'brightness': 'Ljusstyrka',
      'contrast': 'Kontrast',
      'hue': 'Nyans',
      'lightness': 'Ljushet',
      'red': 'Röd',
      'green': 'Grön',
      'blue': 'Blå',
      'input_low': 'Indata låg',
      'input_high': 'Indata hög',
      'output_low': 'Utdata låg',
      'output_high': 'Utdata hög',
      'gamma': 'Gamma',
      'ink_outline': 'Bläckkontur',
      'coloring': 'Färgläggning',
      'tip_size': 'Pennspetsens storlek',
      'color_range': 'Färgomfång',
      'fragments': 'Fragment',
      'rotation': 'Rotation',
      'offset_x': 'Förskjutning X',
      'offset_y': 'Förskjutning Y',
      'quality': 'Kvalitet',
      'threshold': 'Tröskelvärde',
      'scale': 'Skala',
      'refraction': 'Brytning',
      'roughness': 'Ojämnhet',
      'tension': 'Spänning',
      'max_scatter': 'Största spridning',
      'min_scatter': 'Minsta spridning',
      'samples': 'Antal sampel',
      'edge_behavior': 'Kantbeteende',
      'tile_size': 'Rutstorlek',
      'curvature': 'Krökning',
      'size': 'Storlek',
      'strength': 'Styrka',
      'tolerance': 'Tolerans',
      'softness': 'Mjukhet',
      'lighting': 'Belysning',
      'warmth': 'Värme',
      'power': 'Kraft',
      'blend_mode': 'Blandningsläge',
      'factor': 'Faktor',
      'zoom': 'Zoom',
      'invert_colors': 'Invertera färger',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Multiplicera',
      'additive': 'Addera',
      'colorBurn': 'Efterbelys färg',
      'colorDodge': 'Färgskugga',
      'reflect': 'Reflektera',
      'glow': 'Glöd',
      'overlay': 'Täcka över',
      'difference': 'Differens',
      'negation': 'Negation',
      'lighten': 'Ljusare',
      'darken': 'Mörkare',
      'screen': 'Raster',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Det finns inte tillräckligt med minne för bilden.',
      'invalid_size': 'Bildstorleken är ogiltig.',
      'layer_index': 'Det finns inget sådant lager.',
      'last_layer': 'Det sista lagret kan inte tas bort.',
      'no_layer_below': 'Det finns inget lager under att sammanfoga med.',
      'edit_in_progress': 'Slutför den pågående åtgärden först.',
      'no_edit': 'Det finns ingen pågående åtgärd att slutföra.',
      'no_selection': 'Ingenting är markerat.',
      'nothing_lifted': 'Inga pixlar har lyfts ut.',
      'invalid_parameter': 'Värdet ligger utanför det tillåtna intervallet.',
      'io': 'Filen kunde inte läsas eller skrivas.',
      'decode': 'Bilden kunde inte läsas.',
      'encode': 'Bilden kunde inte skrivas.',
      'open_raster': 'OpenRaster-filen är skadad.',
      'palette': 'Palettfilen är skadad.',
      'cancelled': 'Beräkningen avbröts.',
      'other': 'Något gick fel.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Filen kunde inte läsas eller skrivas.';

  @override
  String get failureInvalidData => 'Data kunde inte läsas.';

  @override
  String get failureUnknown => 'Något oväntat gick fel.';

  @override
  String get panelTools => 'Verktyg';

  @override
  String get panelHistory => 'Historik';

  @override
  String get panelLayers => 'Lager';

  @override
  String get panelColors => 'Färger';

  @override
  String get panelHide => 'Dölj';

  @override
  String get colorsPrimary => 'Primär';

  @override
  String get colorsSecondary => 'Sekundär';

  @override
  String get colorsPrimaryHint => 'Primärfärg: vänster musknapp målar med den';

  @override
  String get colorsSecondaryHint =>
      'Sekundärfärg: höger musknapp målar med den';

  @override
  String get colorsSwap => 'Byt färger (X)';

  @override
  String get colorsReset => 'Återställ till svart och vitt';

  @override
  String get colorsMore => 'Mer';

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
      'Vänsterklick anger primärfärgen, högerklick sekundärfärgen';

  @override
  String get settingWidth => 'Bredd';

  @override
  String get settingHardness => 'Hårdhet';

  @override
  String get settingAntialias => 'Kantutjämning';

  @override
  String get settingAlphaBlending => 'Alfablandning';

  @override
  String get settingTolerance => 'Tolerans';

  @override
  String get settingFloodMode => 'Fyllningsläge';

  @override
  String get floodLocal => 'Sammanhängande';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Markeringsläge';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Ersätt',
      'union': 'Lägg till',
      'exclude': 'Dra ifrån',
      'xor': 'Xor',
      'intersect': 'Snitt',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Markeringsstorlek';

  @override
  String get drawNormal => 'Normal';

  @override
  String get drawFixedRatio => 'Fast proportion';

  @override
  String get drawFixedSize => 'Fast storlek';

  @override
  String get settingResampling => 'Omsampling';

  @override
  String get resamplingNearest => 'Närmaste granne';

  @override
  String get resamplingBilinear => 'Bilinjär';

  @override
  String get settingGradient => 'Typ';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Linjär',
      'linearReflected': 'Linjär speglad',
      'diamond': 'Diamant',
      'radial': 'Radiell',
      'conical': 'Konisk',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Färg';

  @override
  String get gradientTransparency => 'Genomskinlighet';

  @override
  String get settingShape => 'Formstil';

  @override
  String get shapeOutline => 'Kontur';

  @override
  String get shapeInterior => 'Fyllning';

  @override
  String get shapeBoth => 'Kontur och fyllning';

  @override
  String get settingAfterPick => 'Efter färghämtning';

  @override
  String get pickStay => 'Behåll det här verktyget';

  @override
  String get pickPrevious => 'Växla till föregående verktyg';

  @override
  String get pickPencil => 'Växla till Blyertspenna';

  @override
  String get settingNone => 'Det här verktyget har inga inställningar.';

  @override
  String toolUnavailable(String name) {
    return 'Verktyget ”$name” är inte tillgängligt ännu';
  }

  @override
  String get historyFirst => 'Gå till första steget';

  @override
  String get historyUndo => 'Ångra';

  @override
  String get historyRedo => 'Gör om';

  @override
  String get historyLast => 'Gå till sista steget';

  @override
  String get historyNewImage => 'Ny bild';

  @override
  String get historyOpenImage => 'Öppna bild';

  @override
  String get layerVisible => 'Visa eller dölj lagret';

  @override
  String get layerBackground => 'Bakgrund';

  @override
  String get layerName => 'Namn';

  @override
  String get layerOpacity => 'Opacitet';

  @override
  String get layerBlendMode => 'Blandningsläge';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Avbryt';

  @override
  String get save => 'Spara';

  @override
  String get dontSave => 'Spara inte';

  @override
  String get keepCanvas => 'Behåll arbetsytan';

  @override
  String get expandCanvas => 'Utöka arbetsytan';

  @override
  String get width => 'Bredd';

  @override
  String get height => 'Höjd';

  @override
  String get pixels => 'pixlar';

  @override
  String get newImageTitle => 'Ny bild';

  @override
  String get resizeTitle => 'Ändra bildstorlek';

  @override
  String get canvasSizeTitle => 'Arbetsytans storlek';

  @override
  String get keepRatio => 'Behåll proportioner';

  @override
  String get anchor => 'Förankring';

  @override
  String sizeTooLarge(int max) {
    return 'Bilden är för stor: gränsen är $max megapixel.';
  }

  @override
  String get unsavedTitle => 'Spara ändringar?';

  @override
  String unsavedMessage(String name) {
    return '”$name” har osparade ändringar.';
  }

  @override
  String get flattenTitle => 'Platta till bilden?';

  @override
  String flattenMessage(String format) {
    return 'Formatet $format kan inte bevara lager, så bilden plattas till och blir ett enda lager. Du kan ångra detta i fönstret Historik.';
  }

  @override
  String get flatten => 'Platta till';

  @override
  String get jpegQualityTitle => 'JPEG-kvalitet';

  @override
  String get quality => 'Kvalitet';

  @override
  String get largerTitle => 'Bilden är större än arbetsytan';

  @override
  String get largerMessage => 'Utöka arbetsytan så att bilden får plats?';

  @override
  String get reseed => 'Nytt startvärde';

  @override
  String get rendering => 'Beräknar…';

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
    return 'Öppnar $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Sparar $name…';
  }

  @override
  String savedTo(String name) {
    return 'Sparad: $name';
  }

  @override
  String get dropHere => 'Släpp för att öppna';

  @override
  String get dropHint => 'Varje fil öppnas som en ny bild';

  @override
  String get imagesList => 'Öppnade bilder';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'En rasterbildredigerare med lager. Tryck på en bokstav för att välja ett verktyg; trycker du på S, M eller O igen växlar du mellan de närliggande verktygen. [ och ] ändrar penselbredden, X byter plats på färgerna, när du håller ned blanksteg panorerar du vyn, Ctrl+mushjulet zoomar och F5–F8 visar eller döljer fönstren.';

  @override
  String get settingLineStart => 'Början';

  @override
  String get settingLineEnd => 'Slut';

  @override
  String get settingDash => 'Streckmönster';

  @override
  String get settingSwapSize => 'Byt bredd och höjd';

  @override
  String get settingLineStyle => 'Stil';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Platt',
      'arrow': 'Pil',
      'arrowFilled': 'Fylld pil',
      'rounded': 'Rundad',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Heldragen',
      'dash': 'Streck',
      'dashDot': 'Streck-punkt',
      'dashDotDot': 'Streck-punkt-punkt',
      'dot': 'Punkt',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Teckensnitt';

  @override
  String get settingFontSize => 'Storlek';

  @override
  String get textBold => 'Fet';

  @override
  String get textItalic => 'Kursiv';

  @override
  String get textUnderline => 'Understruken';

  @override
  String get textStrikeout => 'Genomstruken';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Vänster',
      'center': 'Centrerad',
      'right': 'Höger',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Bilder';
}
