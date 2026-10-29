// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Unbenannt $number';
  }

  @override
  String get menuFile => 'Datei';

  @override
  String get menuEdit => 'Bearbeiten';

  @override
  String get menuView => 'Ansicht';

  @override
  String get menuImage => 'Bild';

  @override
  String get menuLayers => 'Ebenen';

  @override
  String get menuAdjustments => 'Korrekturen';

  @override
  String get menuEffects => 'Effekte';

  @override
  String get menuOpenRecent => 'Zuletzt geöffnet';

  @override
  String get menuRecentEmpty => 'Keine zuletzt geöffneten Dateien';

  @override
  String get menuTheme => 'Design';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuAccent => 'Akzentfarbe';

  @override
  String get menuLanguage => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Blau',
      'green': 'Grün',
      'amber': 'Bernstein',
      'purple': 'Lila',
      'red': 'Rot',
      'gray': 'Grau',
      'custom': 'Benutzerdefiniert…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Benutzerdefinierte Akzentfarbe';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Neu…',
      'open': 'Öffnen…',
      'close': 'Schließen',
      'save': 'Speichern',
      'save_as': 'Speichern unter…',
      'exit': 'Beenden',
      'undo': 'Rückgängig',
      'redo': 'Wiederholen',
      'cut': 'Ausschneiden',
      'copy': 'Kopieren',
      'paste': 'Einfügen',
      'paste_into_new_layer': 'In neue Ebene einfügen',
      'paste_into_new_image': 'In neues Bild einfügen',
      'erase_selection': 'Auswahl löschen',
      'fill_selection': 'Auswahl füllen',
      'invert_selection': 'Auswahl umkehren',
      'select_all': 'Alles auswählen',
      'deselect': 'Auswahl aufheben',
      'zoom_in': 'Vergrößern',
      'zoom_out': 'Verkleinern',
      'zoom_to_window': 'An Fenster anpassen',
      'zoom_to_selection': 'An Auswahl anpassen',
      'actual_size': 'Originalgröße',
      'pixel_grid': 'Pixelraster',
      'rulers': 'Lineale',
      'crop_to_selection': 'Auf Auswahl zuschneiden',
      'resize': 'Größe ändern…',
      'canvas_size': 'Leinwandgröße…',
      'flip_horizontal': 'Horizontal spiegeln',
      'flip_vertical': 'Vertikal spiegeln',
      'rotate90_cw': 'Um 90° im Uhrzeigersinn drehen',
      'rotate90_ccw': 'Um 90° gegen den Uhrzeigersinn drehen',
      'rotate180': 'Um 180° drehen',
      'flatten': 'Auf eine Ebene reduzieren',
      'add_layer': 'Neue Ebene hinzufügen',
      'delete_layer': 'Ebene löschen',
      'duplicate_layer': 'Ebene duplizieren',
      'merge_layer_down': 'Mit darunterliegender Ebene zusammenführen',
      'import_from_file': 'Aus Datei importieren…',
      'flip_layer_horizontal': 'Ebene horizontal spiegeln',
      'flip_layer_vertical': 'Ebene vertikal spiegeln',
      'move_layer_up': 'Ebene nach oben',
      'move_layer_down': 'Ebene nach unten',
      'layer_properties': 'Ebeneneigenschaften…',
      'adjust_auto_level': 'Automatische Tonwertkorrektur',
      'adjust_black_and_white': 'Schwarzweiß',
      'adjust_brightness_contrast': 'Helligkeit / Kontrast…',
      'adjust_curves': 'Gradationskurven…',
      'adjust_hue_saturation': 'Farbton / Sättigung…',
      'adjust_invert_colors': 'Farben umkehren',
      'adjust_levels': 'Tonwertkorrektur…',
      'adjust_posterize': 'Tonwerttrennung…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Effekt wiederholen',
      'effect_oil_painting': 'Ölgemälde…',
      'effect_gaussian_blur': 'Gaußscher Weichzeichner…',
      'effect_motion_blur': 'Bewegungsunschärfe…',
      'effect_pixelate': 'Verpixeln…',
      'effect_add_noise': 'Rauschen hinzufügen…',
      'effect_median': 'Median…',
      'effect_sharpen': 'Schärfen…',
      'effect_edge_detect': 'Kanten erkennen…',
      'effect_emboss': 'Prägen…',
      'effect_outline': 'Kontur…',
      'toggle_tools': 'Werkzeuge',
      'toggle_history': 'Verlauf',
      'toggle_layers': 'Ebenen',
      'toggle_colors': 'Farben',
      'next_image': 'Nächstes Bild',
      'previous_image': 'Vorheriges Bild',
      'help': 'Hilfe',
      'effect_ink_sketch': 'Tintenskizze…',
      'effect_pencil_sketch': 'Bleistiftskizze…',
      'effect_fragment': 'Fragmentieren…',
      'effect_radial_blur': 'Radiale Unschärfe…',
      'effect_surface_blur': 'Oberflächenunschärfe…',
      'effect_unfocus': 'Defokussieren…',
      'effect_zoom_blur': 'Zoom-Unschärfe…',
      'effect_bulge': 'Wölben…',
      'effect_dents': 'Beulen…',
      'effect_frosted_glass': 'Milchglas…',
      'effect_polar_inversion': 'Polare Inversion…',
      'effect_tile_reflection': 'Kachelspiegelung…',
      'effect_twist': 'Verdrehen…',
      'effect_reduce_noise': 'Rauschen entfernen…',
      'effect_glow': 'Leuchten…',
      'effect_red_eye_removal': 'Rote Augen entfernen…',
      'effect_soften_portrait': 'Porträt weichzeichnen…',
      'effect_clouds': 'Wolken…',
      'effect_julia_fractal': 'Julia-Fraktal…',
      'effect_mandelbrot_fractal': 'Mandelbrot-Fraktal…',
      'effect_relief': 'Relief…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Künstlerisch',
      'blurs': 'Weichzeichnen',
      'distort': 'Verzerren',
      'noise': 'Rauschen',
      'photo': 'Foto',
      'stylize': 'Stilisieren',
      'render': 'Rendern',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Rechteckauswahl',
      'move_selected_pixels': 'Ausgewählte Pixel verschieben',
      'lasso_select': 'Lasso-Auswahl',
      'move_selection': 'Auswahl verschieben',
      'ellipse_select': 'Ellipsenauswahl',
      'zoom': 'Lupe',
      'magic_wand': 'Zauberstab',
      'pan': 'Hand',
      'paint_bucket': 'Farbeimer',
      'gradient': 'Farbverlauf',
      'paintbrush': 'Pinsel',
      'eraser': 'Radiergummi',
      'pencil': 'Bleistift',
      'color_picker': 'Farbpipette',
      'clone_stamp': 'Kopierstempel',
      'recolor': 'Umfärben',
      'text': 'Text',
      'line_curve': 'Linie / Kurve',
      'rectangle': 'Rechteck',
      'rounded_rectangle': 'Abgerundetes Rechteck',
      'ellipse': 'Ellipse',
      'freeform_shape': 'Freiform',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Ziehen Sie, um ein Rechteck auszuwählen. Halten Sie die Umschalttaste gedrückt, um ein Quadrat zu erhalten.',
      'move_selected_pixels': 'Ziehen Sie die Auswahl, um sie zu verschieben. Ziehen Sie mit der rechten Maustaste, um sie zu drehen, und ziehen Sie an den Griffen, um sie zu skalieren. Mit Strg bleibt eine Kopie zurück; mit den Pfeiltasten verschieben Sie sie schrittweise.',
      'lasso_select': 'Ziehen Sie, um den Umriss einer Auswahl zu zeichnen.',
      'move_selection': 'Ziehen Sie den Auswahlrahmen, um ihn zu verschieben. Die Pixel bleiben an ihrer Stelle.',
      'ellipse_select': 'Ziehen Sie, um eine Ellipse auszuwählen. Halten Sie die Umschalttaste gedrückt, um einen Kreis zu erhalten.',
      'zoom': 'Klicken Sie mit der linken Maustaste, um zu vergrößern, mit der rechten, um zu verkleinern, oder ziehen Sie einen Rahmen auf, um diesen Bereich einzupassen.',
      'magic_wand': 'Klicken Sie auf eine Farbe, um den angrenzenden Bereich auszuwählen. Halten Sie die Umschalttaste gedrückt, um die Farbe im gesamten Bild auszuwählen.',
      'pan': 'Ziehen Sie, um die Ansicht zu verschieben.',
      'paint_bucket': 'Ein Linksklick füllt mit der Primärfarbe, ein Rechtsklick mit der Sekundärfarbe.',
      'gradient': 'Ziehen Sie, um einen Farbverlauf zu zeichnen. Ziehen Sie an den Griffen, um ihn anzupassen; drücken Sie die Eingabetaste, um ihn abzuschließen.',
      'paintbrush': 'Mit der linken Maustaste malen Sie in der Primärfarbe, mit der rechten in der Sekundärfarbe.',
      'eraser': 'Ziehen Sie, um Bereiche transparent zu radieren.',
      'pencil': 'Zeichnet ein Pixel breite Linien ohne Kantenglättung.',
      'color_picker': 'Ein Linksklick übernimmt die Primärfarbe, ein Rechtsklick die Sekundärfarbe.',
      'clone_stamp': 'Legen Sie die Quelle mit Strg+Klick fest und ziehen Sie dann, um mit ihr zu malen.',
      'recolor': 'Ersetzt beim Malen die Sekundärfarbe durch die Primärfarbe. Mit Strg+Klick nehmen Sie eine Farbe auf.',
      'text': 'Klicken Sie, um den Cursor zu setzen, und tippen Sie dann. Ziehen Sie den Griff oder ziehen Sie mit der rechten Maustaste, um den Text zu verschieben; drücken Sie Esc, um ihn abzuschließen.',
      'line_curve': 'Ziehen Sie, um eine Linie zu zeichnen. Ziehen Sie an den Griffen, um sie zu biegen; drücken Sie die Eingabetaste, um sie abzuschließen.',
      'rectangle': 'Ziehen Sie, um ein Rechteck zu zeichnen. Halten Sie die Umschalttaste gedrückt, um ein Quadrat zu erhalten.',
      'rounded_rectangle': 'Ziehen Sie, um ein abgerundetes Rechteck zu zeichnen. Halten Sie die Umschalttaste gedrückt, um ein Quadrat zu erhalten.',
      'ellipse': 'Ziehen Sie, um eine Ellipse zu zeichnen. Halten Sie die Umschalttaste gedrückt, um einen Kreis zu erhalten.',
      'freeform_shape':
          'Ziehen Sie, um eine geschlossene Freiform zu zeichnen.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Radius',
      'angle': 'Winkel',
      'distance': 'Abstand',
      'centered': 'Zentriert',
      'amount': 'Menge',
      'intensity': 'Intensität',
      'saturation': 'Sättigung',
      'coverage': 'Abdeckung',
      'seed': 'Startwert',
      'percentile': 'Perzentil',
      'cell_size': 'Zellgröße',
      'brush_size': 'Pinselgröße',
      'coarseness': 'Grobheit',
      'thickness': 'Dicke',
      'brightness': 'Helligkeit',
      'contrast': 'Kontrast',
      'hue': 'Farbton',
      'lightness': 'Helligkeit',
      'red': 'Rot',
      'green': 'Grün',
      'blue': 'Blau',
      'input_low': 'Eingabe: Tiefen',
      'input_high': 'Eingabe: Lichter',
      'output_low': 'Ausgabe: Tiefen',
      'output_high': 'Ausgabe: Lichter',
      'gamma': 'Gamma',
      'ink_outline': 'Tintenkontur',
      'coloring': 'Färbung',
      'tip_size': 'Größe der Bleistiftspitze',
      'color_range': 'Farbbereich',
      'fragments': 'Fragmente',
      'rotation': 'Drehung',
      'offset_x': 'Versatz X',
      'offset_y': 'Versatz Y',
      'quality': 'Qualität',
      'threshold': 'Schwellenwert',
      'scale': 'Skalierung',
      'refraction': 'Brechung',
      'roughness': 'Rauheit',
      'tension': 'Spannung',
      'max_scatter': 'Maximale Streuung',
      'min_scatter': 'Minimale Streuung',
      'samples': 'Abtastwerte',
      'edge_behavior': 'Kantenverhalten',
      'tile_size': 'Kachelgröße',
      'curvature': 'Krümmung',
      'size': 'Größe',
      'strength': 'Stärke',
      'tolerance': 'Toleranz',
      'softness': 'Weichheit',
      'lighting': 'Beleuchtung',
      'warmth': 'Wärme',
      'power': 'Kraft',
      'blend_mode': 'Mischmodus',
      'factor': 'Faktor',
      'zoom': 'Zoom',
      'invert_colors': 'Farben umkehren',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Multiplizieren',
      'additive': 'Addieren',
      'colorBurn': 'Farbig nachbelichten',
      'colorDodge': 'Farbig abwedeln',
      'reflect': 'Reflektieren',
      'glow': 'Leuchten',
      'overlay': 'Überlagern',
      'difference': 'Differenz',
      'negation': 'Negation',
      'lighten': 'Aufhellen',
      'darken': 'Abdunkeln',
      'screen': 'Negativ multiplizieren',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory':
          'Für das Bild ist nicht genügend Arbeitsspeicher vorhanden.',
      'invalid_size': 'Die Bildgröße ist ungültig.',
      'layer_index': 'Diese Ebene existiert nicht.',
      'last_layer': 'Die letzte Ebene kann nicht gelöscht werden.',
      'no_layer_below':
          'Darunter gibt es keine Ebene, mit der zusammengeführt werden kann.',
      'edit_in_progress': 'Schließen Sie zuerst den laufenden Vorgang ab.',
      'no_edit':
          'Es gibt keinen laufenden Vorgang, der abgeschlossen werden kann.',
      'no_selection': 'Es ist nichts ausgewählt.',
      'nothing_lifted': 'Es wurden keine Pixel herausgelöst.',
      'invalid_parameter': 'Der Wert liegt außerhalb des zulässigen Bereichs.',
      'io': 'Die Datei konnte nicht gelesen oder geschrieben werden.',
      'decode': 'Das Bild konnte nicht gelesen werden.',
      'encode': 'Das Bild konnte nicht geschrieben werden.',
      'open_raster': 'Die OpenRaster-Datei ist beschädigt.',
      'palette': 'Die Palettendatei ist beschädigt.',
      'cancelled': 'Die Berechnung wurde abgebrochen.',
      'other': 'Ein Fehler ist aufgetreten.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage =>
      'Die Datei konnte nicht gelesen oder geschrieben werden.';

  @override
  String get failureInvalidData => 'Die Daten konnten nicht gelesen werden.';

  @override
  String get failureUnknown => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get panelTools => 'Werkzeuge';

  @override
  String get panelHistory => 'Verlauf';

  @override
  String get panelLayers => 'Ebenen';

  @override
  String get panelColors => 'Farben';

  @override
  String get panelHide => 'Ausblenden';

  @override
  String get colorsPrimary => 'Primär';

  @override
  String get colorsSecondary => 'Sekundär';

  @override
  String get colorsPrimaryHint => 'Primärfarbe: Damit malt die linke Maustaste';

  @override
  String get colorsSecondaryHint =>
      'Sekundärfarbe: Damit malt die rechte Maustaste';

  @override
  String get colorsSwap => 'Farben tauschen (X)';

  @override
  String get colorsReset => 'Auf Schwarz und Weiß zurücksetzen';

  @override
  String get colorsMore => 'Mehr';

  @override
  String get colorsLess => 'Weniger';

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
      'Ein Linksklick legt die Primärfarbe fest, ein Rechtsklick die Sekundärfarbe';

  @override
  String get settingWidth => 'Breite';

  @override
  String get settingHardness => 'Härte';

  @override
  String get settingAntialias => 'Kantenglättung';

  @override
  String get settingAlphaBlending => 'Alpha-Überblendung';

  @override
  String get settingTolerance => 'Toleranz';

  @override
  String get settingFloodMode => 'Füllmodus';

  @override
  String get floodLocal => 'Zusammenhängend';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Auswahlmodus';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Ersetzen',
      'union': 'Vereinigen',
      'exclude': 'Ausschließen',
      'xor': 'XOR',
      'intersect': 'Schnittmenge',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Auswahlgröße';

  @override
  String get drawNormal => 'Normal';

  @override
  String get drawFixedRatio => 'Festes Seitenverhältnis';

  @override
  String get drawFixedSize => 'Feste Größe';

  @override
  String get settingResampling => 'Interpolation';

  @override
  String get resamplingNearest => 'Nächster Nachbar';

  @override
  String get resamplingBilinear => 'Bilinear';

  @override
  String get settingGradient => 'Typ';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Linear',
      'linearReflected': 'Linear gespiegelt',
      'diamond': 'Raute',
      'radial': 'Radial',
      'conical': 'Konisch',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Farbe';

  @override
  String get gradientTransparency => 'Transparenz';

  @override
  String get settingShape => 'Formstil';

  @override
  String get shapeOutline => 'Kontur';

  @override
  String get shapeInterior => 'Füllung';

  @override
  String get shapeBoth => 'Kontur und Füllung';

  @override
  String get settingAfterPick => 'Nach dem Aufnehmen';

  @override
  String get pickStay => 'Dieses Werkzeug beibehalten';

  @override
  String get pickPrevious => 'Zum vorherigen Werkzeug wechseln';

  @override
  String get pickPencil => 'Zum Bleistift wechseln';

  @override
  String get settingNone => 'Dieses Werkzeug hat keine Einstellungen.';

  @override
  String toolUnavailable(String name) {
    return 'Das Werkzeug „$name“ ist noch nicht verfügbar';
  }

  @override
  String get historyFirst => 'Zum ersten Schritt';

  @override
  String get historyUndo => 'Rückgängig';

  @override
  String get historyRedo => 'Wiederholen';

  @override
  String get historyLast => 'Zum letzten Schritt';

  @override
  String get historyNewImage => 'Neues Bild';

  @override
  String get historyOpenImage => 'Bild öffnen';

  @override
  String get layerVisible => 'Ebene ein- oder ausblenden';

  @override
  String get layerBackground => 'Hintergrund';

  @override
  String get layerName => 'Name';

  @override
  String get layerOpacity => 'Deckkraft';

  @override
  String get layerBlendMode => 'Mischmodus';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get dontSave => 'Nicht speichern';

  @override
  String get keepCanvas => 'Leinwand beibehalten';

  @override
  String get expandCanvas => 'Leinwand vergrößern';

  @override
  String get width => 'Breite';

  @override
  String get height => 'Höhe';

  @override
  String get pixels => 'Pixel';

  @override
  String get newImageTitle => 'Neues Bild';

  @override
  String get resizeTitle => 'Bildgröße ändern';

  @override
  String get canvasSizeTitle => 'Leinwandgröße';

  @override
  String get keepRatio => 'Seitenverhältnis beibehalten';

  @override
  String get anchor => 'Ankerpunkt';

  @override
  String sizeTooLarge(int max) {
    return 'Das Bild ist zu groß: Die Obergrenze liegt bei $max Megapixeln.';
  }

  @override
  String get unsavedTitle => 'Änderungen speichern?';

  @override
  String unsavedMessage(String name) {
    return '„$name“ enthält ungespeicherte Änderungen.';
  }

  @override
  String get flattenTitle => 'Bild auf eine Ebene reduzieren?';

  @override
  String flattenMessage(String format) {
    return 'Das Format $format unterstützt keine Ebenen, daher wird das Bild auf eine Ebene reduziert. Sie können dies im Fenster „Verlauf“ rückgängig machen.';
  }

  @override
  String get flatten => 'Reduzieren';

  @override
  String get jpegQualityTitle => 'JPEG-Qualität';

  @override
  String get quality => 'Qualität';

  @override
  String get largerTitle => 'Das Bild ist größer als die Leinwand';

  @override
  String get largerMessage =>
      'Leinwand vergrößern, damit das Bild hineinpasst?';

  @override
  String get reseed => 'Neuer Startwert';

  @override
  String get rendering => 'Wird berechnet…';

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
    return '$name wird geöffnet…';
  }

  @override
  String statusSaving(String name) {
    return '$name wird gespeichert…';
  }

  @override
  String savedTo(String name) {
    return 'Gespeichert: $name';
  }

  @override
  String get dropHere => 'Zum Öffnen hier ablegen';

  @override
  String get dropHint => 'Jede Datei wird als neues Bild geöffnet';

  @override
  String get imagesList => 'Geöffnete Bilder';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Ein Rasterbildeditor mit Ebenen. Drücken Sie einen Buchstaben, um ein Werkzeug zu wählen; erneutes Drücken von S, M oder O wechselt zwischen den zugehörigen Werkzeugen. [ und ] ändern die Pinselbreite, X tauscht die Farben, mit gedrückter Leertaste verschieben Sie die Ansicht, Strg+Mausrad zoomt, und F5–F8 blenden die Fenster ein oder aus.';

  @override
  String get settingLineStart => 'Anfang';

  @override
  String get settingLineEnd => 'Ende';

  @override
  String get settingDash => 'Strichmuster';

  @override
  String get settingSwapSize => 'Breite und Höhe tauschen';

  @override
  String get settingLineStyle => 'Stil';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Flach',
      'arrow': 'Pfeil',
      'arrowFilled': 'Gefüllter Pfeil',
      'rounded': 'Abgerundet',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Durchgezogen',
      'dash': 'Strich',
      'dashDot': 'Strich-Punkt',
      'dashDotDot': 'Strich-Punkt-Punkt',
      'dot': 'Punkt',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Schriftart';

  @override
  String get settingFontSize => 'Größe';

  @override
  String get textBold => 'Fett';

  @override
  String get textItalic => 'Kursiv';

  @override
  String get textUnderline => 'Unterstrichen';

  @override
  String get textStrikeout => 'Durchgestrichen';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Links',
      'center': 'Zentriert',
      'right': 'Rechts',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Bilder';
}
