// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Naamloos $number';
  }

  @override
  String get menuFile => 'Bestand';

  @override
  String get menuEdit => 'Bewerken';

  @override
  String get menuView => 'Beeld';

  @override
  String get menuImage => 'Afbeelding';

  @override
  String get menuLayers => 'Lagen';

  @override
  String get menuAdjustments => 'Aanpassingen';

  @override
  String get menuEffects => 'Effecten';

  @override
  String get menuOpenRecent => 'Recent geopend';

  @override
  String get menuRecentEmpty => 'Geen recente bestanden';

  @override
  String get menuTheme => 'Thema';

  @override
  String get menuSettings => 'Instellingen';

  @override
  String get menuAccent => 'Accentkleur';

  @override
  String get menuLanguage => 'Taal';

  @override
  String get languageSystem => 'Systeemstandaard';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Blauw',
      'green': 'Groen',
      'amber': 'Amber',
      'purple': 'Paars',
      'red': 'Rood',
      'gray': 'Grijs',
      'custom': 'Aangepast…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Aangepaste accentkleur';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Systeemstandaard';

  @override
  String get themeDark => 'Donker';

  @override
  String get themeLight => 'Licht';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nieuw…',
      'open': 'Openen…',
      'close': 'Sluiten',
      'save': 'Opslaan',
      'save_as': 'Opslaan als…',
      'exit': 'Afsluiten',
      'undo': 'Ongedaan maken',
      'redo': 'Opnieuw',
      'cut': 'Knippen',
      'copy': 'Kopiëren',
      'paste': 'Plakken',
      'paste_into_new_layer': 'Plakken in nieuwe laag',
      'paste_into_new_image': 'Plakken in nieuwe afbeelding',
      'erase_selection': 'Selectie wissen',
      'fill_selection': 'Selectie vullen',
      'invert_selection': 'Selectie omkeren',
      'select_all': 'Alles selecteren',
      'deselect': 'Selectie opheffen',
      'zoom_in': 'Inzoomen',
      'zoom_out': 'Uitzoomen',
      'zoom_to_window': 'Passend in venster',
      'zoom_to_selection': 'Zoomen naar selectie',
      'actual_size': 'Werkelijke grootte',
      'pixel_grid': 'Pixelraster',
      'rulers': 'Linialen',
      'crop_to_selection': 'Bijsnijden tot selectie',
      'resize': 'Formaat wijzigen…',
      'canvas_size': 'Canvasgrootte…',
      'flip_horizontal': 'Horizontaal spiegelen',
      'flip_vertical': 'Verticaal spiegelen',
      'rotate90_cw': '90° rechtsom draaien',
      'rotate90_ccw': '90° linksom draaien',
      'rotate180': '180° draaien',
      'flatten': 'Afvlakken',
      'add_layer': 'Nieuwe laag toevoegen',
      'delete_layer': 'Laag verwijderen',
      'duplicate_layer': 'Laag dupliceren',
      'merge_layer_down': 'Laag omlaag samenvoegen',
      'import_from_file': 'Importeren uit bestand…',
      'flip_layer_horizontal': 'Laag horizontaal spiegelen',
      'flip_layer_vertical': 'Laag verticaal spiegelen',
      'move_layer_up': 'Laag omhoog',
      'move_layer_down': 'Laag omlaag',
      'layer_properties': 'Laageigenschappen…',
      'adjust_auto_level': 'Automatische niveaus',
      'adjust_black_and_white': 'Zwart-wit',
      'adjust_brightness_contrast': 'Helderheid / contrast…',
      'adjust_curves': 'Curven…',
      'adjust_hue_saturation': 'Tint / verzadiging…',
      'adjust_invert_colors': 'Kleuren omkeren',
      'adjust_levels': 'Niveaus…',
      'adjust_posterize': 'Posteriseren…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Effect herhalen',
      'effect_oil_painting': 'Olieverfschilderij…',
      'effect_gaussian_blur': 'Gaussiaanse vervaging…',
      'effect_motion_blur': 'Bewegingsvervaging…',
      'effect_pixelate': 'Pixeleren…',
      'effect_add_noise': 'Ruis toevoegen…',
      'effect_median': 'Mediaan…',
      'effect_sharpen': 'Verscherpen…',
      'effect_edge_detect': 'Randen detecteren…',
      'effect_emboss': 'Embossing…',
      'effect_outline': 'Contour…',
      'toggle_tools': 'Gereedschappen',
      'toggle_history': 'Geschiedenis',
      'toggle_layers': 'Lagen',
      'toggle_colors': 'Kleuren',
      'next_image': 'Volgende afbeelding',
      'previous_image': 'Vorige afbeelding',
      'help': 'Help',
      'effect_ink_sketch': 'Inkttekening…',
      'effect_pencil_sketch': 'Potloodschets…',
      'effect_fragment': 'Fragmenteren…',
      'effect_radial_blur': 'Radiale vervaging…',
      'effect_surface_blur': 'Oppervlaktevervaging…',
      'effect_unfocus': 'Onscherp maken…',
      'effect_zoom_blur': 'Zoomvervaging…',
      'effect_bulge': 'Uitstulpen…',
      'effect_dents': 'Deuken…',
      'effect_frosted_glass': 'Matglas…',
      'effect_polar_inversion': 'Polaire inversie…',
      'effect_tile_reflection': 'Tegelreflectie…',
      'effect_twist': 'Verdraaien…',
      'effect_reduce_noise': 'Ruis verminderen…',
      'effect_glow': 'Gloed…',
      'effect_red_eye_removal': 'Rode ogen verwijderen…',
      'effect_soften_portrait': 'Portret verzachten…',
      'effect_clouds': 'Wolken…',
      'effect_julia_fractal': 'Julia-fractal…',
      'effect_mandelbrot_fractal': 'Mandelbrot-fractal…',
      'effect_relief': 'Reliëf…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artistiek',
      'blurs': 'Vervagen',
      'distort': 'Vervormen',
      'noise': 'Ruis',
      'photo': 'Foto',
      'stylize': 'Stileren',
      'render': 'Renderen',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Rechthoekselectie',
      'move_selected_pixels': 'Geselecteerde pixels verplaatsen',
      'lasso_select': 'Lassoselectie',
      'move_selection': 'Selectie verplaatsen',
      'ellipse_select': 'Ellipsselectie',
      'zoom': 'Zoomen',
      'magic_wand': 'Toverstaf',
      'pan': 'Hand',
      'paint_bucket': 'Verfemmer',
      'gradient': 'Kleurverloop',
      'paintbrush': 'Penseel',
      'eraser': 'Gum',
      'pencil': 'Potlood',
      'color_picker': 'Pipet',
      'clone_stamp': 'Kloonstempel',
      'recolor': 'Herkleuren',
      'text': 'Tekst',
      'line_curve': 'Lijn / curve',
      'rectangle': 'Rechthoek',
      'rounded_rectangle': 'Afgeronde rechthoek',
      'ellipse': 'Ellips',
      'freeform_shape': 'Vrije vorm',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Sleep om een rechthoek te selecteren. Houd Shift ingedrukt voor een vierkant.',
      'move_selected_pixels': 'Sleep de selectie om deze te verplaatsen. Sleep met de rechterknop om deze te draaien en sleep de grepen om deze te schalen. Met Ctrl blijft er een kopie achter; met de pijltoetsen verschuift u de selectie stapsgewijs.',
      'lasso_select': 'Sleep om de omtrek van een selectie te tekenen.',
      'move_selection': 'Sleep de selectieomtrek om deze te verplaatsen. De pixels blijven op hun plaats.',
      'ellipse_select': 'Sleep om een ellips te selecteren. Houd Shift ingedrukt voor een cirkel.',
      'zoom': 'Klik met de linkerknop om in te zoomen en met de rechterknop om uit te zoomen, of sleep een kader om op dat gebied in te zoomen.',
      'magic_wand': 'Klik op een kleur om het gebied eromheen te selecteren. Houd Shift ingedrukt om deze kleur in de hele afbeelding te selecteren.',
      'pan': 'Sleep om de weergave te verschuiven.',
      'paint_bucket': 'Een linkerklik vult met de primaire kleur, een rechterklik met de secundaire.',
      'gradient': 'Sleep om een kleurverloop te tekenen. Sleep de grepen om het aan te passen; druk op Enter om te voltooien.',
      'paintbrush': 'De linkerknop schildert met de primaire kleur, de rechterknop met de secundaire.',
      'eraser': 'Sleep om te wissen tot transparantie.',
      'pencil': 'Tekent lijnen van één pixel breed zonder anti-aliasing.',
      'color_picker': 'Een linkerklik neemt de primaire kleur op, een rechterklik de secundaire.',
      'clone_stamp': 'Stel de bron in met Ctrl+klik en sleep daarna om vanuit de bron te schilderen.',
      'recolor': 'Vervangt de secundaire kleur door de primaire waar u schildert. Met Ctrl+klik neemt u een kleur op.',
      'text': 'Klik om de cursor te plaatsen en typ daarna. Sleep de greep of sleep met de rechterknop om de tekst te verplaatsen; druk op Esc om te voltooien.',
      'line_curve': 'Sleep om een lijn te tekenen. Sleep de grepen om deze te buigen; druk op Enter om te voltooien.',
      'rectangle': 'Sleep om een rechthoek te tekenen. Houd Shift ingedrukt voor een vierkant.',
      'rounded_rectangle': 'Sleep om een afgeronde rechthoek te tekenen. Houd Shift ingedrukt voor een vierkant.',
      'ellipse': 'Sleep om een ellips te tekenen. Houd Shift ingedrukt voor een cirkel.',
      'freeform_shape': 'Sleep om een gesloten vrije vorm te tekenen.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Straal',
      'angle': 'Hoek',
      'distance': 'Afstand',
      'centered': 'Gecentreerd',
      'amount': 'Hoeveelheid',
      'intensity': 'Intensiteit',
      'saturation': 'Verzadiging',
      'coverage': 'Bedekking',
      'seed': 'Startwaarde',
      'percentile': 'Percentiel',
      'cell_size': 'Celgrootte',
      'brush_size': 'Penseelgrootte',
      'coarseness': 'Grofheid',
      'thickness': 'Dikte',
      'brightness': 'Helderheid',
      'contrast': 'Contrast',
      'hue': 'Tint',
      'lightness': 'Lichtheid',
      'red': 'Rood',
      'green': 'Groen',
      'blue': 'Blauw',
      'input_low': 'Invoer: donker',
      'input_high': 'Invoer: licht',
      'output_low': 'Uitvoer: donker',
      'output_high': 'Uitvoer: licht',
      'gamma': 'Gamma',
      'ink_outline': 'Inktcontour',
      'coloring': 'Inkleuring',
      'tip_size': 'Grootte potloodpunt',
      'color_range': 'Kleurbereik',
      'fragments': 'Fragmenten',
      'rotation': 'Rotatie',
      'offset_x': 'Verschuiving X',
      'offset_y': 'Verschuiving Y',
      'quality': 'Kwaliteit',
      'threshold': 'Drempelwaarde',
      'scale': 'Schaal',
      'refraction': 'Breking',
      'roughness': 'Ruwheid',
      'tension': 'Spanning',
      'max_scatter': 'Maximale spreiding',
      'min_scatter': 'Minimale spreiding',
      'samples': 'Aantal samples',
      'edge_behavior': 'Randgedrag',
      'tile_size': 'Tegelgrootte',
      'curvature': 'Kromming',
      'size': 'Grootte',
      'strength': 'Sterkte',
      'tolerance': 'Tolerantie',
      'softness': 'Zachtheid',
      'lighting': 'Belichting',
      'warmth': 'Warmte',
      'power': 'Kracht',
      'blend_mode': 'Mengmodus',
      'factor': 'Factor',
      'zoom': 'Zoom',
      'invert_colors': 'Kleuren omkeren',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normaal',
      'multiply': 'Vermenigvuldigen',
      'additive': 'Optellen',
      'colorBurn': 'Kleur doordrukken',
      'colorDodge': 'Kleur tegenhouden',
      'reflect': 'Reflecteren',
      'glow': 'Gloed',
      'overlay': 'Bedekken',
      'difference': 'Verschil',
      'negation': 'Negatie',
      'lighten': 'Lichter',
      'darken': 'Donkerder',
      'screen': 'Bleken',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Er is onvoldoende geheugen voor de afbeelding.',
      'invalid_size': 'De afbeeldingsgrootte is ongeldig.',
      'layer_index': 'Deze laag bestaat niet.',
      'last_layer': 'De laatste laag kan niet worden verwijderd.',
      'no_layer_below': 'Er is geen onderliggende laag om mee samen te voegen.',
      'edit_in_progress': 'Voltooi eerst de lopende bewerking.',
      'no_edit': 'Er is geen lopende bewerking om te voltooien.',
      'no_selection': 'Er is niets geselecteerd.',
      'nothing_lifted': 'Er zijn geen pixels losgemaakt.',
      'invalid_parameter': 'De waarde valt buiten het toegestane bereik.',
      'io': 'Het bestand kan niet worden gelezen of geschreven.',
      'decode': 'De afbeelding kan niet worden gelezen.',
      'encode': 'De afbeelding kan niet worden geschreven.',
      'open_raster': 'Het OpenRaster-bestand is beschadigd.',
      'palette': 'Het paletbestand is beschadigd.',
      'cancelled': 'De berekening is geannuleerd.',
      'other': 'Er is iets misgegaan.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage =>
      'Het bestand kan niet worden gelezen of geschreven.';

  @override
  String get failureInvalidData => 'De gegevens kunnen niet worden gelezen.';

  @override
  String get failureUnknown => 'Er is iets onverwachts misgegaan.';

  @override
  String get panelTools => 'Gereedschappen';

  @override
  String get panelHistory => 'Geschiedenis';

  @override
  String get panelLayers => 'Lagen';

  @override
  String get panelColors => 'Kleuren';

  @override
  String get panelHide => 'Verbergen';

  @override
  String get colorsPrimary => 'Primair';

  @override
  String get colorsSecondary => 'Secundair';

  @override
  String get colorsPrimaryHint =>
      'Primaire kleur: de linkermuisknop schildert hiermee';

  @override
  String get colorsSecondaryHint =>
      'Secundaire kleur: de rechtermuisknop schildert hiermee';

  @override
  String get colorsSwap => 'Kleuren omwisselen (X)';

  @override
  String get colorsReset => 'Herstellen naar zwart en wit';

  @override
  String get colorsMore => 'Meer';

  @override
  String get colorsLess => 'Minder';

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
      'Een linkerklik stelt de primaire kleur in, een rechterklik de secundaire';

  @override
  String get settingWidth => 'Breedte';

  @override
  String get settingHardness => 'Hardheid';

  @override
  String get settingAntialias => 'Anti-aliasing';

  @override
  String get settingAlphaBlending => 'Alfamenging';

  @override
  String get settingTolerance => 'Tolerantie';

  @override
  String get settingFloodMode => 'Vulmodus';

  @override
  String get floodLocal => 'Aaneengesloten';

  @override
  String get floodGlobal => 'Globaal';

  @override
  String get settingSelectionMode => 'Selectiemodus';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Vervangen',
      'union': 'Toevoegen',
      'exclude': 'Aftrekken',
      'xor': 'Xor',
      'intersect': 'Doorsnede',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Selectiegrootte';

  @override
  String get drawNormal => 'Normaal';

  @override
  String get drawFixedRatio => 'Vaste verhouding';

  @override
  String get drawFixedSize => 'Vaste grootte';

  @override
  String get settingResampling => 'Herbemonstering';

  @override
  String get resamplingNearest => 'Naaste buur';

  @override
  String get resamplingBilinear => 'Bilineair';

  @override
  String get settingGradient => 'Type';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineair',
      'linearReflected': 'Lineair gespiegeld',
      'diamond': 'Ruit',
      'radial': 'Radiaal',
      'conical': 'Conisch',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Kleur';

  @override
  String get gradientTransparency => 'Transparantie';

  @override
  String get settingShape => 'Vormstijl';

  @override
  String get shapeOutline => 'Omtrek';

  @override
  String get shapeInterior => 'Vulling';

  @override
  String get shapeBoth => 'Omtrek en vulling';

  @override
  String get settingAfterPick => 'Na het oppikken';

  @override
  String get pickStay => 'Dit gereedschap behouden';

  @override
  String get pickPrevious => 'Naar het vorige gereedschap';

  @override
  String get pickPencil => 'Naar het potlood';

  @override
  String get settingNone => 'Dit gereedschap heeft geen instellingen.';

  @override
  String toolUnavailable(String name) {
    return 'Het gereedschap ‘$name’ is nog niet beschikbaar';
  }

  @override
  String get historyFirst => 'Naar de eerste stap';

  @override
  String get historyUndo => 'Ongedaan maken';

  @override
  String get historyRedo => 'Opnieuw';

  @override
  String get historyLast => 'Naar de laatste stap';

  @override
  String get historyNewImage => 'Nieuwe afbeelding';

  @override
  String get historyOpenImage => 'Afbeelding openen';

  @override
  String get layerVisible => 'Laag tonen of verbergen';

  @override
  String get layerBackground => 'Achtergrond';

  @override
  String get layerName => 'Naam';

  @override
  String get layerOpacity => 'Dekking';

  @override
  String get layerBlendMode => 'Mengmodus';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get dontSave => 'Niet opslaan';

  @override
  String get keepCanvas => 'Canvas behouden';

  @override
  String get expandCanvas => 'Canvas vergroten';

  @override
  String get width => 'Breedte';

  @override
  String get height => 'Hoogte';

  @override
  String get pixels => 'pixels';

  @override
  String get newImageTitle => 'Nieuwe afbeelding';

  @override
  String get resizeTitle => 'Afbeeldingsformaat wijzigen';

  @override
  String get canvasSizeTitle => 'Canvasgrootte';

  @override
  String get keepRatio => 'Hoogte-breedteverhouding behouden';

  @override
  String get anchor => 'Ankerpunt';

  @override
  String sizeTooLarge(int max) {
    return 'De afbeelding is te groot: de limiet is $max megapixel.';
  }

  @override
  String get unsavedTitle => 'Wijzigingen opslaan?';

  @override
  String unsavedMessage(String name) {
    return '‘$name’ bevat niet-opgeslagen wijzigingen.';
  }

  @override
  String get flattenTitle => 'Afbeelding afvlakken?';

  @override
  String flattenMessage(String format) {
    return 'De indeling $format ondersteunt geen lagen, dus de afbeelding wordt afgevlakt tot één laag. U kunt dit ongedaan maken in het venster Geschiedenis.';
  }

  @override
  String get flatten => 'Afvlakken';

  @override
  String get jpegQualityTitle => 'JPEG-kwaliteit';

  @override
  String get quality => 'Kwaliteit';

  @override
  String get largerTitle => 'De afbeelding is groter dan het canvas';

  @override
  String get largerMessage =>
      'Het canvas vergroten zodat de afbeelding erin past?';

  @override
  String get reseed => 'Nieuwe startwaarde';

  @override
  String get rendering => 'Berekenen…';

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
    return '$percent%';
  }

  @override
  String statusOpening(String name) {
    return '$name wordt geopend…';
  }

  @override
  String statusSaving(String name) {
    return '$name wordt opgeslagen…';
  }

  @override
  String savedTo(String name) {
    return 'Opgeslagen: $name';
  }

  @override
  String get dropHere => 'Loslaten om te openen';

  @override
  String get dropHint => 'Elk bestand wordt als nieuwe afbeelding geopend';

  @override
  String get imagesList => 'Geopende afbeeldingen';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Een rasterafbeeldingseditor met lagen. Druk op een letter om een gereedschap te kiezen; door nogmaals op S, M of O te drukken, doorloopt u de verwante gereedschappen. [ en ] wijzigen de penseelbreedte, X verwisselt de kleuren, met de spatiebalk ingedrukt verschuift u de weergave, Ctrl+muiswiel zoomt en F5–F8 tonen of verbergen de vensters.';

  @override
  String get settingLineStart => 'Begin';

  @override
  String get settingLineEnd => 'Einde';

  @override
  String get settingDash => 'Streeppatroon';

  @override
  String get settingSwapSize => 'Breedte en hoogte verwisselen';

  @override
  String get settingLineStyle => 'Stijl';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Vlak',
      'arrow': 'Pijl',
      'arrowFilled': 'Gevulde pijl',
      'rounded': 'Afgerond',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Doorgetrokken',
      'dash': 'Streep',
      'dashDot': 'Streep-punt',
      'dashDotDot': 'Streep-punt-punt',
      'dot': 'Punt',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Lettertype';

  @override
  String get settingFontSize => 'Grootte';

  @override
  String get textBold => 'Vet';

  @override
  String get textItalic => 'Cursief';

  @override
  String get textUnderline => 'Onderstreept';

  @override
  String get textStrikeout => 'Doorgestreept';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Links',
      'center': 'Gecentreerd',
      'right': 'Rechts',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Afbeeldingen';
}
