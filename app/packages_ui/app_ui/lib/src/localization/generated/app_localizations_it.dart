// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Senza titolo $number';
  }

  @override
  String get menuFile => 'File';

  @override
  String get menuEdit => 'Modifica';

  @override
  String get menuView => 'Visualizza';

  @override
  String get menuImage => 'Immagine';

  @override
  String get menuLayers => 'Livelli';

  @override
  String get menuAdjustments => 'Regolazioni';

  @override
  String get menuEffects => 'Effetti';

  @override
  String get menuOpenRecent => 'Apri recenti';

  @override
  String get menuRecentEmpty => 'Nessun file recente';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Impostazioni';

  @override
  String get menuAccent => 'Colore d\'accento';

  @override
  String get menuLanguage => 'Lingua';

  @override
  String get languageSystem => 'Predefinito di sistema';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Blu',
      'green': 'Verde',
      'amber': 'Ambra',
      'purple': 'Viola',
      'red': 'Rosso',
      'gray': 'Grigio',
      'custom': 'Personalizzato…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Colore d\'accento personalizzato';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Predefinito di sistema';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeLight => 'Chiaro';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nuovo…',
      'open': 'Apri…',
      'close': 'Chiudi',
      'save': 'Salva',
      'save_as': 'Salva con nome…',
      'exit': 'Esci',
      'undo': 'Annulla',
      'redo': 'Ripeti',
      'cut': 'Taglia',
      'copy': 'Copia',
      'paste': 'Incolla',
      'paste_into_new_layer': 'Incolla in un nuovo livello',
      'paste_into_new_image': 'Incolla in una nuova immagine',
      'erase_selection': 'Cancella selezione',
      'fill_selection': 'Riempi selezione',
      'invert_selection': 'Inverti selezione',
      'select_all': 'Seleziona tutto',
      'deselect': 'Deseleziona',
      'zoom_in': 'Ingrandisci',
      'zoom_out': 'Riduci',
      'zoom_to_window': 'Adatta alla finestra',
      'zoom_to_selection': 'Adatta alla selezione',
      'actual_size': 'Dimensioni reali',
      'pixel_grid': 'Griglia dei pixel',
      'rulers': 'Righelli',
      'crop_to_selection': 'Ritaglia alla selezione',
      'resize': 'Ridimensiona immagine…',
      'canvas_size': 'Dimensioni tela…',
      'flip_horizontal': 'Rifletti orizzontalmente',
      'flip_vertical': 'Rifletti verticalmente',
      'rotate90_cw': 'Ruota di 90° in senso orario',
      'rotate90_ccw': 'Ruota di 90° in senso antiorario',
      'rotate180': 'Ruota di 180°',
      'flatten': 'Appiattisci',
      'add_layer': 'Aggiungi nuovo livello',
      'delete_layer': 'Elimina livello',
      'duplicate_layer': 'Duplica livello',
      'merge_layer_down': 'Unisci al livello sottostante',
      'import_from_file': 'Importa da file…',
      'flip_layer_horizontal': 'Rifletti livello orizzontalmente',
      'flip_layer_vertical': 'Rifletti livello verticalmente',
      'move_layer_up': 'Sposta livello su',
      'move_layer_down': 'Sposta livello giù',
      'layer_properties': 'Proprietà livello…',
      'adjust_auto_level': 'Livelli automatici',
      'adjust_black_and_white': 'Bianco e nero',
      'adjust_brightness_contrast': 'Luminosità / Contrasto…',
      'adjust_curves': 'Curve…',
      'adjust_hue_saturation': 'Tonalità / Saturazione…',
      'adjust_invert_colors': 'Inverti colori',
      'adjust_levels': 'Livelli…',
      'adjust_posterize': 'Posterizza…',
      'adjust_sepia': 'Seppia',
      'repeat_effect': 'Ripeti effetto',
      'effect_oil_painting': 'Pittura a olio…',
      'effect_gaussian_blur': 'Sfocatura gaussiana…',
      'effect_motion_blur': 'Sfocatura di movimento…',
      'effect_pixelate': 'Pixellizzazione…',
      'effect_add_noise': 'Aggiungi disturbo…',
      'effect_median': 'Mediana…',
      'effect_sharpen': 'Nitidezza…',
      'effect_edge_detect': 'Rilevamento bordi…',
      'effect_emboss': 'Goffratura…',
      'effect_outline': 'Contorno…',
      'toggle_tools': 'Strumenti',
      'toggle_history': 'Cronologia',
      'toggle_layers': 'Livelli',
      'toggle_colors': 'Colori',
      'next_image': 'Immagine successiva',
      'previous_image': 'Immagine precedente',
      'help': 'Guida',
      'effect_ink_sketch': 'Schizzo a inchiostro…',
      'effect_pencil_sketch': 'Schizzo a matita…',
      'effect_fragment': 'Frammentazione…',
      'effect_radial_blur': 'Sfocatura radiale…',
      'effect_surface_blur': 'Sfocatura superficie…',
      'effect_unfocus': 'Fuori fuoco…',
      'effect_zoom_blur': 'Sfocatura zoom…',
      'effect_bulge': 'Rigonfiamento…',
      'effect_dents': 'Ammaccature…',
      'effect_frosted_glass': 'Vetro smerigliato…',
      'effect_polar_inversion': 'Inversione polare…',
      'effect_tile_reflection': 'Riflessione a piastrelle…',
      'effect_twist': 'Torsione…',
      'effect_reduce_noise': 'Riduci disturbo…',
      'effect_glow': 'Bagliore…',
      'effect_red_eye_removal': 'Rimozione occhi rossi…',
      'effect_soften_portrait': 'Ammorbidisci ritratto…',
      'effect_clouds': 'Nuvole…',
      'effect_julia_fractal': 'Frattale di Julia…',
      'effect_mandelbrot_fractal': 'Frattale di Mandelbrot…',
      'effect_relief': 'Rilievo…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artistici',
      'blurs': 'Sfocature',
      'distort': 'Distorsione',
      'noise': 'Disturbo',
      'photo': 'Foto',
      'stylize': 'Stilizzazione',
      'render': 'Rendering',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Selezione rettangolare',
      'move_selected_pixels': 'Sposta pixel selezionati',
      'lasso_select': 'Selezione lazo',
      'move_selection': 'Sposta selezione',
      'ellipse_select': 'Selezione ellittica',
      'zoom': 'Zoom',
      'magic_wand': 'Bacchetta magica',
      'pan': 'Mano',
      'paint_bucket': 'Secchiello',
      'gradient': 'Sfumatura',
      'paintbrush': 'Pennello',
      'eraser': 'Gomma',
      'pencil': 'Matita',
      'color_picker': 'Contagocce',
      'clone_stamp': 'Timbro clone',
      'recolor': 'Ricolora',
      'text': 'Testo',
      'line_curve': 'Linea / curva',
      'rectangle': 'Rettangolo',
      'rounded_rectangle': 'Rettangolo arrotondato',
      'ellipse': 'Ellisse',
      'freeform_shape': 'Forma libera',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Trascina per selezionare un rettangolo. Tieni premuto Shift per ottenere un quadrato.',
      'move_selected_pixels': 'Trascina la selezione per spostarla. Trascina con il tasto destro per ruotarla, trascina le maniglie per ridimensionarla. Ctrl lascia una copia; i tasti freccia la spostano di poco.',
      'lasso_select': 'Trascina per disegnare il contorno di una selezione.',
      'move_selection': 'Trascina il contorno della selezione per spostarlo. I pixel restano al loro posto.',
      'ellipse_select': 'Trascina per selezionare un\'ellisse. Tieni premuto Shift per ottenere un cerchio.',
      'zoom': 'Fai clic con il tasto sinistro per ingrandire, con il destro per ridurre, oppure trascina un riquadro per ingrandire quell\'area.',
      'magic_wand': 'Fai clic su un colore per selezionare l\'area circostante. Tieni premuto Shift per selezionarlo in tutta l\'immagine.',
      'pan': 'Trascina per spostare la vista.',
      'paint_bucket': 'Il clic sinistro riempie con il colore primario, il clic destro con quello secondario.',
      'gradient': 'Trascina per disegnare una sfumatura. Trascina le maniglie per regolarla; premi Enter per terminare.',
      'paintbrush': 'Il tasto sinistro dipinge con il colore primario, il tasto destro con quello secondario.',
      'eraser': 'Trascina per cancellare fino alla trasparenza.',
      'pencil': 'Disegna linee di un pixel senza antialiasing.',
      'color_picker': 'Il clic sinistro preleva il colore primario, il clic destro quello secondario.',
      'clone_stamp': 'Fai Ctrl+clic per impostare l\'origine, poi trascina per dipingere a partire da essa.',
      'recolor': 'Sostituisce il colore secondario con quello primario dove dipingi. Ctrl+clic preleva un colore.',
      'text': 'Fai clic per posizionare il cursore, poi digita il testo. Trascina la maniglia o trascina con il tasto destro per spostare il testo; premi Esc per terminare.',
      'line_curve': 'Trascina per disegnare una linea. Trascina le maniglie per curvarla; premi Enter per terminare.',
      'rectangle': 'Trascina per disegnare un rettangolo. Tieni premuto Shift per ottenere un quadrato.',
      'rounded_rectangle': 'Trascina per disegnare un rettangolo arrotondato. Tieni premuto Shift per ottenere un quadrato.',
      'ellipse': 'Trascina per disegnare un\'ellisse. Tieni premuto Shift per ottenere un cerchio.',
      'freeform_shape': 'Trascina per disegnare una forma libera chiusa.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Raggio',
      'angle': 'Angolo',
      'distance': 'Distanza',
      'centered': 'Centrato',
      'amount': 'Quantità',
      'intensity': 'Intensità',
      'saturation': 'Saturazione',
      'coverage': 'Copertura',
      'seed': 'Seme',
      'percentile': 'Percentile',
      'cell_size': 'Dimensione cella',
      'brush_size': 'Dimensione pennello',
      'coarseness': 'Grana',
      'thickness': 'Spessore',
      'brightness': 'Luminosità',
      'contrast': 'Contrasto',
      'hue': 'Tonalità',
      'lightness': 'Chiarezza',
      'red': 'Rosso',
      'green': 'Verde',
      'blue': 'Blu',
      'input_low': 'Input minimo',
      'input_high': 'Input massimo',
      'output_low': 'Output minimo',
      'output_high': 'Output massimo',
      'gamma': 'Gamma',
      'ink_outline': 'Contorno a inchiostro',
      'coloring': 'Colorazione',
      'tip_size': 'Dimensione punta matita',
      'color_range': 'Intervallo colori',
      'fragments': 'Frammenti',
      'rotation': 'Rotazione',
      'offset_x': 'Spostamento X',
      'offset_y': 'Spostamento Y',
      'quality': 'Qualità',
      'threshold': 'Soglia',
      'scale': 'Scala',
      'refraction': 'Rifrazione',
      'roughness': 'Ruvidità',
      'tension': 'Tensione',
      'max_scatter': 'Dispersione massima',
      'min_scatter': 'Dispersione minima',
      'samples': 'Campioni',
      'edge_behavior': 'Comportamento ai bordi',
      'tile_size': 'Dimensione piastrella',
      'curvature': 'Curvatura',
      'size': 'Dimensione',
      'strength': 'Forza',
      'tolerance': 'Tolleranza',
      'softness': 'Morbidezza',
      'lighting': 'Illuminazione',
      'warmth': 'Calore',
      'power': 'Potenza',
      'blend_mode': 'Metodo di fusione',
      'factor': 'Fattore',
      'zoom': 'Zoom',
      'invert_colors': 'Inverti colori',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normale',
      'multiply': 'Moltiplica',
      'additive': 'Additivo',
      'colorBurn': 'Brucia colore',
      'colorDodge': 'Scherma colore',
      'reflect': 'Rifletti',
      'glow': 'Bagliore',
      'overlay': 'Sovrapponi',
      'difference': 'Differenza',
      'negation': 'Negazione',
      'lighten': 'Schiarisci',
      'darken': 'Scurisci',
      'screen': 'Scolora',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'La memoria non è sufficiente per l\'immagine.',
      'invalid_size': 'Le dimensioni dell\'immagine non sono valide.',
      'layer_index': 'Questo livello non esiste.',
      'last_layer': 'Impossibile eliminare l\'ultimo livello.',
      'no_layer_below': 'Non c\'è alcun livello sottostante con cui unire.',
      'edit_in_progress': 'Completa prima l\'operazione in corso.',
      'no_edit': 'Non c\'è alcuna operazione in corso da completare.',
      'no_selection': 'Non è selezionato nulla.',
      'nothing_lifted': 'Non ci sono pixel sollevati.',
      'invalid_parameter': 'Il valore è fuori dall\'intervallo consentito.',
      'io': 'Impossibile leggere o scrivere il file.',
      'decode': 'Impossibile leggere l\'immagine.',
      'encode': 'Impossibile scrivere l\'immagine.',
      'open_raster': 'Il file OpenRaster è danneggiato.',
      'palette': 'Il file della tavolozza è danneggiato.',
      'cancelled': 'Il calcolo è stato annullato.',
      'other': 'Si è verificato un errore.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Impossibile leggere o scrivere il file.';

  @override
  String get failureInvalidData => 'Impossibile leggere i dati.';

  @override
  String get failureUnknown => 'Si è verificato un errore imprevisto.';

  @override
  String get panelTools => 'Strumenti';

  @override
  String get panelHistory => 'Cronologia';

  @override
  String get panelLayers => 'Livelli';

  @override
  String get panelColors => 'Colori';

  @override
  String get panelHide => 'Nascondi';

  @override
  String get colorsPrimary => 'Primario';

  @override
  String get colorsSecondary => 'Secondario';

  @override
  String get colorsPrimaryHint =>
      'Colore primario: il tasto sinistro del mouse dipinge con questo colore';

  @override
  String get colorsSecondaryHint =>
      'Colore secondario: il tasto destro del mouse dipinge con questo colore';

  @override
  String get colorsSwap => 'Scambia i colori (X)';

  @override
  String get colorsReset => 'Ripristina nero e bianco';

  @override
  String get colorsMore => 'Più';

  @override
  String get colorsLess => 'Meno';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Alfa';

  @override
  String get colorsHue => 'T';

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
      'Il clic sinistro imposta il colore primario, il clic destro quello secondario';

  @override
  String get settingWidth => 'Larghezza';

  @override
  String get settingHardness => 'Durezza';

  @override
  String get settingAntialias => 'Antialiasing';

  @override
  String get settingAlphaBlending => 'Fusione alfa';

  @override
  String get settingTolerance => 'Tolleranza';

  @override
  String get settingFloodMode => 'Modalità di riempimento';

  @override
  String get floodLocal => 'Contiguo';

  @override
  String get floodGlobal => 'Globale';

  @override
  String get settingSelectionMode => 'Modalità di selezione';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Sostituisci',
      'union': 'Unisci',
      'exclude': 'Escludi',
      'xor': 'Xor',
      'intersect': 'Interseca',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Dimensione selezione';

  @override
  String get drawNormal => 'Libera';

  @override
  String get drawFixedRatio => 'Proporzioni fisse';

  @override
  String get drawFixedSize => 'Dimensione fissa';

  @override
  String get settingResampling => 'Ricampionamento';

  @override
  String get resamplingNearest => 'Vicino più prossimo';

  @override
  String get resamplingBilinear => 'Bilineare';

  @override
  String get settingGradient => 'Tipo';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineare',
      'linearReflected': 'Lineare riflessa',
      'diamond': 'Rombo',
      'radial': 'Radiale',
      'conical': 'Conica',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Colore';

  @override
  String get gradientTransparency => 'Trasparenza';

  @override
  String get settingShape => 'Stile forma';

  @override
  String get shapeOutline => 'Contorno';

  @override
  String get shapeInterior => 'Riempimento';

  @override
  String get shapeBoth => 'Contorno e riempimento';

  @override
  String get settingAfterPick => 'Dopo il prelievo';

  @override
  String get pickStay => 'Mantieni questo strumento';

  @override
  String get pickPrevious => 'Torna allo strumento precedente';

  @override
  String get pickPencil => 'Passa alla Matita';

  @override
  String get settingNone => 'Questo strumento non ha impostazioni.';

  @override
  String toolUnavailable(String name) {
    return 'Lo strumento «$name» non è ancora disponibile';
  }

  @override
  String get historyFirst => 'Vai al primo passaggio';

  @override
  String get historyUndo => 'Annulla';

  @override
  String get historyRedo => 'Ripeti';

  @override
  String get historyLast => 'Vai all\'ultimo passaggio';

  @override
  String get historyNewImage => 'Nuova immagine';

  @override
  String get historyOpenImage => 'Apri immagine';

  @override
  String get layerVisible => 'Mostra o nascondi il livello';

  @override
  String get layerBackground => 'Sfondo';

  @override
  String get layerName => 'Nome';

  @override
  String get layerOpacity => 'Opacità';

  @override
  String get layerBlendMode => 'Metodo di fusione';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get dontSave => 'Non salvare';

  @override
  String get keepCanvas => 'Mantieni la tela';

  @override
  String get expandCanvas => 'Espandi la tela';

  @override
  String get width => 'Larghezza';

  @override
  String get height => 'Altezza';

  @override
  String get pixels => 'pixel';

  @override
  String get newImageTitle => 'Nuova immagine';

  @override
  String get resizeTitle => 'Ridimensiona immagine';

  @override
  String get canvasSizeTitle => 'Dimensioni tela';

  @override
  String get keepRatio => 'Mantieni le proporzioni';

  @override
  String get anchor => 'Ancoraggio';

  @override
  String sizeTooLarge(int max) {
    return 'L\'immagine è troppo grande: il limite è di $max megapixel.';
  }

  @override
  String get unsavedTitle => 'Salvare le modifiche?';

  @override
  String unsavedMessage(String name) {
    return '«$name» contiene modifiche non salvate.';
  }

  @override
  String get flattenTitle => 'Appiattire l\'immagine?';

  @override
  String flattenMessage(String format) {
    return 'Il formato $format non conserva i livelli, quindi l\'immagine verrà appiattita in un unico livello. Puoi annullare questa operazione nella finestra Cronologia.';
  }

  @override
  String get flatten => 'Appiattisci';

  @override
  String get jpegQualityTitle => 'Qualità JPEG';

  @override
  String get quality => 'Qualità';

  @override
  String get largerTitle => 'L\'immagine è più grande della tela';

  @override
  String get largerMessage => 'Espandere la tela per contenerla?';

  @override
  String get reseed => 'Nuovo seme';

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
    return 'Apertura di $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Salvataggio di $name…';
  }

  @override
  String savedTo(String name) {
    return 'Salvato: $name';
  }

  @override
  String get dropHere => 'Rilascia per aprire';

  @override
  String get dropHint => 'Ogni file si apre come nuova immagine';

  @override
  String get imagesList => 'Immagini aperte';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Un editor di immagini raster con livelli. Premi una lettera per scegliere uno strumento; premendo di nuovo S, M o O si passa tra gli strumenti correlati. [ e ] cambiano la larghezza del pennello, X scambia i colori, tenendo premuta la barra spaziatrice si sposta la vista, Ctrl+rotellina del mouse cambia lo zoom e F5–F8 mostrano o nascondono le finestre.';

  @override
  String get aboutLegal =>
      '© 2026 gli autori di Paintbox. Paintbox è software libero: è possibile ridistribuirlo e modificarlo secondo i termini della GNU General Public License, versione 3 o successiva. Viene fornito senza alcuna garanzia.';

  @override
  String get licenses => 'Licenze';

  @override
  String get settingLineStart => 'Inizio';

  @override
  String get settingLineEnd => 'Fine';

  @override
  String get settingDash => 'Tratteggio';

  @override
  String get settingSwapSize => 'Scambia larghezza e altezza';

  @override
  String get settingLineStyle => 'Stile';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Piatta',
      'arrow': 'Freccia',
      'arrowFilled': 'Freccia piena',
      'rounded': 'Arrotondata',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Continuo',
      'dash': 'Tratto',
      'dashDot': 'Tratto punto',
      'dashDotDot': 'Tratto punto punto',
      'dot': 'Punto',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Carattere';

  @override
  String get settingFontSize => 'Dimensione';

  @override
  String get textBold => 'Grassetto';

  @override
  String get textItalic => 'Corsivo';

  @override
  String get textUnderline => 'Sottolineato';

  @override
  String get textStrikeout => 'Barrato';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Sinistra',
      'center': 'Centro',
      'right': 'Destra',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Immagini';
}
