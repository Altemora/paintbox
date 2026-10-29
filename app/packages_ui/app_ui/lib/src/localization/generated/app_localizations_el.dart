// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Χωρίς τίτλο $number';
  }

  @override
  String get menuFile => 'Αρχείο';

  @override
  String get menuEdit => 'Επεξεργασία';

  @override
  String get menuView => 'Προβολή';

  @override
  String get menuImage => 'Εικόνα';

  @override
  String get menuLayers => 'Επίπεδα';

  @override
  String get menuAdjustments => 'Προσαρμογές';

  @override
  String get menuEffects => 'Εφέ';

  @override
  String get menuOpenRecent => 'Άνοιγμα πρόσφατου';

  @override
  String get menuRecentEmpty => 'Δεν υπάρχουν πρόσφατα αρχεία';

  @override
  String get menuTheme => 'Θέμα';

  @override
  String get menuSettings => 'Ρυθμίσεις';

  @override
  String get menuAccent => 'Χρώμα έμφασης';

  @override
  String get menuLanguage => 'Γλώσσα';

  @override
  String get languageSystem => 'Προεπιλογή συστήματος';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Μπλε',
      'green': 'Πράσινο',
      'amber': 'Κεχριμπαρί',
      'purple': 'Μωβ',
      'red': 'Κόκκινο',
      'gray': 'Γκρι',
      'custom': 'Προσαρμοσμένο…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Προσαρμοσμένο χρώμα έμφασης';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Προεπιλογή συστήματος';

  @override
  String get themeDark => 'Σκούρο';

  @override
  String get themeLight => 'Ανοιχτό';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Νέο…',
      'open': 'Άνοιγμα…',
      'close': 'Κλείσιμο',
      'save': 'Αποθήκευση',
      'save_as': 'Αποθήκευση ως…',
      'exit': 'Έξοδος',
      'undo': 'Αναίρεση',
      'redo': 'Επανάληψη',
      'cut': 'Αποκοπή',
      'copy': 'Αντιγραφή',
      'paste': 'Επικόλληση',
      'paste_into_new_layer': 'Επικόλληση σε νέο επίπεδο',
      'paste_into_new_image': 'Επικόλληση σε νέα εικόνα',
      'erase_selection': 'Διαγραφή επιλογής',
      'fill_selection': 'Γέμισμα επιλογής',
      'invert_selection': 'Αντιστροφή επιλογής',
      'select_all': 'Επιλογή όλων',
      'deselect': 'Αποεπιλογή',
      'zoom_in': 'Μεγέθυνση',
      'zoom_out': 'Σμίκρυνση',
      'zoom_to_window': 'Προσαρμογή στο παράθυρο',
      'zoom_to_selection': 'Προσαρμογή στην επιλογή',
      'actual_size': 'Πραγματικό μέγεθος',
      'pixel_grid': 'Πλέγμα εικονοστοιχείων',
      'rulers': 'Χάρακες',
      'crop_to_selection': 'Περικοπή στην επιλογή',
      'resize': 'Αλλαγή μεγέθους εικόνας…',
      'canvas_size': 'Μέγεθος καμβά…',
      'flip_horizontal': 'Οριζόντια αναστροφή',
      'flip_vertical': 'Κατακόρυφη αναστροφή',
      'rotate90_cw': 'Περιστροφή 90° δεξιόστροφα',
      'rotate90_ccw': 'Περιστροφή 90° αριστερόστροφα',
      'rotate180': 'Περιστροφή 180°',
      'flatten': 'Ισοπέδωση',
      'add_layer': 'Προσθήκη νέου επιπέδου',
      'delete_layer': 'Διαγραφή επιπέδου',
      'duplicate_layer': 'Διπλασιασμός επιπέδου',
      'merge_layer_down': 'Συγχώνευση με το κάτω επίπεδο',
      'import_from_file': 'Εισαγωγή από αρχείο…',
      'flip_layer_horizontal': 'Οριζόντια αναστροφή επιπέδου',
      'flip_layer_vertical': 'Κατακόρυφη αναστροφή επιπέδου',
      'move_layer_up': 'Μετακίνηση επιπέδου πάνω',
      'move_layer_down': 'Μετακίνηση επιπέδου κάτω',
      'layer_properties': 'Ιδιότητες επιπέδου…',
      'adjust_auto_level': 'Αυτόματες στάθμες',
      'adjust_black_and_white': 'Ασπρόμαυρο',
      'adjust_brightness_contrast': 'Φωτεινότητα / Αντίθεση…',
      'adjust_curves': 'Καμπύλες…',
      'adjust_hue_saturation': 'Απόχρωση / Κορεσμός…',
      'adjust_invert_colors': 'Αντιστροφή χρωμάτων',
      'adjust_levels': 'Στάθμες…',
      'adjust_posterize': 'Ποστεροποίηση…',
      'adjust_sepia': 'Σέπια',
      'repeat_effect': 'Επανάληψη εφέ',
      'effect_oil_painting': 'Ελαιογραφία…',
      'effect_gaussian_blur': 'Θόλωση Gauss…',
      'effect_motion_blur': 'Θόλωση κίνησης…',
      'effect_pixelate': 'Εικονοστοιχειοποίηση…',
      'effect_add_noise': 'Προσθήκη θορύβου…',
      'effect_median': 'Διάμεσος…',
      'effect_sharpen': 'Όξυνση…',
      'effect_edge_detect': 'Ανίχνευση ακμών…',
      'effect_emboss': 'Ανάγλυφη σφράγιση…',
      'effect_outline': 'Περίγραμμα…',
      'toggle_tools': 'Εργαλεία',
      'toggle_history': 'Ιστορικό',
      'toggle_layers': 'Επίπεδα',
      'toggle_colors': 'Χρώματα',
      'next_image': 'Επόμενη εικόνα',
      'previous_image': 'Προηγούμενη εικόνα',
      'help': 'Βοήθεια',
      'effect_ink_sketch': 'Σκίτσο με μελάνι…',
      'effect_pencil_sketch': 'Σκίτσο με μολύβι…',
      'effect_fragment': 'Κατακερματισμός…',
      'effect_radial_blur': 'Ακτινική θόλωση…',
      'effect_surface_blur': 'Θόλωση επιφάνειας…',
      'effect_unfocus': 'Αποεστίαση…',
      'effect_zoom_blur': 'Θόλωση ζουμ…',
      'effect_bulge': 'Διόγκωση…',
      'effect_dents': 'Βαθουλώματα…',
      'effect_frosted_glass': 'Θαμπό γυαλί…',
      'effect_polar_inversion': 'Πολική αναστροφή…',
      'effect_tile_reflection': 'Αντανάκλαση πλακιδίων…',
      'effect_twist': 'Συστροφή…',
      'effect_reduce_noise': 'Μείωση θορύβου…',
      'effect_glow': 'Λάμψη…',
      'effect_red_eye_removal': 'Αφαίρεση κόκκινων ματιών…',
      'effect_soften_portrait': 'Απάλυνση πορτρέτου…',
      'effect_clouds': 'Σύννεφα…',
      'effect_julia_fractal': 'Φράκταλ Julia…',
      'effect_mandelbrot_fractal': 'Φράκταλ Mandelbrot…',
      'effect_relief': 'Ανάγλυφο…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Καλλιτεχνικά',
      'blurs': 'Θολώσεις',
      'distort': 'Παραμόρφωση',
      'noise': 'Θόρυβος',
      'photo': 'Φωτογραφία',
      'stylize': 'Στυλιζάρισμα',
      'render': 'Απόδοση',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Ορθογώνια επιλογή',
      'move_selected_pixels': 'Μετακίνηση επιλεγμένων εικονοστοιχείων',
      'lasso_select': 'Επιλογή λάσο',
      'move_selection': 'Μετακίνηση επιλογής',
      'ellipse_select': 'Ελλειπτική επιλογή',
      'zoom': 'Ζουμ',
      'magic_wand': 'Μαγικό ραβδί',
      'pan': 'Χέρι',
      'paint_bucket': 'Κουβάς χρώματος',
      'gradient': 'Διαβάθμιση',
      'paintbrush': 'Πινέλο',
      'eraser': 'Γόμα',
      'pencil': 'Μολύβι',
      'color_picker': 'Σταγονόμετρο',
      'clone_stamp': 'Σφραγίδα κλωνοποίησης',
      'recolor': 'Επαναχρωματισμός',
      'text': 'Κείμενο',
      'line_curve': 'Γραμμή / καμπύλη',
      'rectangle': 'Ορθογώνιο',
      'rounded_rectangle': 'Στρογγυλεμένο ορθογώνιο',
      'ellipse': 'Έλλειψη',
      'freeform_shape': 'Ελεύθερο σχήμα',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Σύρετε για να επιλέξετε ένα ορθογώνιο. Κρατήστε πατημένο το Shift για τετράγωνο.',
      'move_selected_pixels': 'Σύρετε την επιλογή για να τη μετακινήσετε. Σύρετε με το δεξί κουμπί για να την περιστρέψετε ή σύρετε τις λαβές για να αλλάξετε το μέγεθός της. Το Ctrl αφήνει αντίγραφο· τα πλήκτρα βέλους τη μετακινούν λίγο.',
      'lasso_select': 'Σύρετε για να σχεδιάσετε το περίγραμμα μιας επιλογής.',
      'move_selection': 'Σύρετε το περίγραμμα της επιλογής για να το μετακινήσετε. Τα εικονοστοιχεία μένουν στη θέση τους.',
      'ellipse_select': 'Σύρετε για να επιλέξετε μια έλλειψη. Κρατήστε πατημένο το Shift για κύκλο.',
      'zoom': 'Κάντε αριστερό κλικ για μεγέθυνση, δεξί κλικ για σμίκρυνση ή σύρετε ένα πλαίσιο για να μεγεθύνετε την περιοχή του.',
      'magic_wand': 'Κάντε κλικ σε ένα χρώμα για να επιλέξετε την περιοχή γύρω του. Κρατήστε πατημένο το Shift για να το επιλέξετε σε όλη την εικόνα.',
      'pan': 'Σύρετε για να μετακινήσετε την προβολή.',
      'paint_bucket': 'Το αριστερό κλικ γεμίζει με το πρωτεύον χρώμα, το δεξί με το δευτερεύον.',
      'gradient': 'Σύρετε για να σχεδιάσετε μια διαβάθμιση. Σύρετε τις λαβές για να τη ρυθμίσετε· πατήστε Enter για ολοκλήρωση.',
      'paintbrush': 'Το αριστερό κουμπί ζωγραφίζει με το πρωτεύον χρώμα, το δεξί με το δευτερεύον.',
      'eraser': 'Σύρετε για να σβήσετε μέχρι τη διαφάνεια.',
      'pencil':
          'Σχεδιάζει γραμμές πάχους ενός εικονοστοιχείου χωρίς εξομάλυνση.',
      'color_picker':
          'Το αριστερό κλικ παίρνει το πρωτεύον χρώμα, το δεξί το δευτερεύον.',
      'clone_stamp': 'Κάντε Ctrl+κλικ για να ορίσετε την πηγή και έπειτα σύρετε για να ζωγραφίσετε από αυτήν.',
      'recolor': 'Αντικαθιστά το δευτερεύον χρώμα με το πρωτεύον όπου ζωγραφίζετε. Το Ctrl+κλικ παίρνει ένα χρώμα.',
      'text': 'Κάντε κλικ για να τοποθετήσετε τον δρομέα και πληκτρολογήστε. Σύρετε τη λαβή ή σύρετε με το δεξί κουμπί για να μετακινήσετε το κείμενο· πατήστε Esc για ολοκλήρωση.',
      'line_curve': 'Σύρετε για να σχεδιάσετε μια γραμμή. Σύρετε τις λαβές για να την καμπυλώσετε· πατήστε Enter για ολοκλήρωση.',
      'rectangle': 'Σύρετε για να σχεδιάσετε ένα ορθογώνιο. Κρατήστε πατημένο το Shift για τετράγωνο.',
      'rounded_rectangle': 'Σύρετε για να σχεδιάσετε ένα στρογγυλεμένο ορθογώνιο. Κρατήστε πατημένο το Shift για τετράγωνο.',
      'ellipse': 'Σύρετε για να σχεδιάσετε μια έλλειψη. Κρατήστε πατημένο το Shift για κύκλο.',
      'freeform_shape': 'Σύρετε για να σχεδιάσετε ένα κλειστό ελεύθερο σχήμα.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Ακτίνα',
      'angle': 'Γωνία',
      'distance': 'Απόσταση',
      'centered': 'Στο κέντρο',
      'amount': 'Ποσότητα',
      'intensity': 'Ένταση',
      'saturation': 'Κορεσμός',
      'coverage': 'Κάλυψη',
      'seed': 'Σπόρος',
      'percentile': 'Εκατοστημόριο',
      'cell_size': 'Μέγεθος κελιού',
      'brush_size': 'Μέγεθος πινέλου',
      'coarseness': 'Αδρότητα',
      'thickness': 'Πάχος',
      'brightness': 'Φωτεινότητα',
      'contrast': 'Αντίθεση',
      'hue': 'Απόχρωση',
      'lightness': 'Ανοιχτότητα',
      'red': 'Κόκκινο',
      'green': 'Πράσινο',
      'blue': 'Μπλε',
      'input_low': 'Ελάχιστη είσοδος',
      'input_high': 'Μέγιστη είσοδος',
      'output_low': 'Ελάχιστη έξοδος',
      'output_high': 'Μέγιστη έξοδος',
      'gamma': 'Γάμμα',
      'ink_outline': 'Περίγραμμα μελανιού',
      'coloring': 'Χρωματισμός',
      'tip_size': 'Μέγεθος μύτης μολυβιού',
      'color_range': 'Εύρος χρωμάτων',
      'fragments': 'Θραύσματα',
      'rotation': 'Περιστροφή',
      'offset_x': 'Μετατόπιση X',
      'offset_y': 'Μετατόπιση Y',
      'quality': 'Ποιότητα',
      'threshold': 'Κατώφλι',
      'scale': 'Κλίμακα',
      'refraction': 'Διάθλαση',
      'roughness': 'Τραχύτητα',
      'tension': 'Τάση',
      'max_scatter': 'Μέγιστη διασπορά',
      'min_scatter': 'Ελάχιστη διασπορά',
      'samples': 'Δείγματα',
      'edge_behavior': 'Συμπεριφορά στις άκρες',
      'tile_size': 'Μέγεθος πλακιδίου',
      'curvature': 'Καμπυλότητα',
      'size': 'Μέγεθος',
      'strength': 'Δύναμη',
      'tolerance': 'Ανοχή',
      'softness': 'Απαλότητα',
      'lighting': 'Φωτισμός',
      'warmth': 'Θερμότητα',
      'power': 'Ισχύς',
      'blend_mode': 'Λειτουργία ανάμειξης',
      'factor': 'Συντελεστής',
      'zoom': 'Ζουμ',
      'invert_colors': 'Αντιστροφή χρωμάτων',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Κανονική',
      'multiply': 'Πολλαπλασιασμός',
      'additive': 'Πρόσθεση',
      'colorBurn': 'Κάψιμο χρώματος',
      'colorDodge': 'Αποφυγή χρώματος',
      'reflect': 'Αντανάκλαση',
      'glow': 'Λάμψη',
      'overlay': 'Επικάλυψη',
      'difference': 'Διαφορά',
      'negation': 'Άρνηση',
      'lighten': 'Ξάνοιγμα',
      'darken': 'Σκούρεμα',
      'screen': 'Οθόνη',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Δεν υπάρχει αρκετή μνήμη για την εικόνα.',
      'invalid_size': 'Το μέγεθος της εικόνας δεν είναι έγκυρο.',
      'layer_index': 'Δεν υπάρχει τέτοιο επίπεδο.',
      'last_layer': 'Το τελευταίο επίπεδο δεν μπορεί να διαγραφεί.',
      'no_layer_below': 'Δεν υπάρχει επίπεδο από κάτω για συγχώνευση.',
      'edit_in_progress': 'Ολοκληρώστε πρώτα την τρέχουσα ενέργεια.',
      'no_edit': 'Δεν υπάρχει ενέργεια σε εξέλιξη για ολοκλήρωση.',
      'no_selection': 'Δεν έχει επιλεγεί τίποτα.',
      'nothing_lifted': 'Δεν υπάρχουν ανασηκωμένα εικονοστοιχεία.',
      'invalid_parameter': 'Η τιμή είναι εκτός ορίων.',
      'io': 'Δεν ήταν δυνατή η ανάγνωση ή η εγγραφή του αρχείου.',
      'decode': 'Δεν ήταν δυνατή η ανάγνωση της εικόνας.',
      'encode': 'Δεν ήταν δυνατή η εγγραφή της εικόνας.',
      'open_raster': 'Το αρχείο OpenRaster είναι κατεστραμμένο.',
      'palette': 'Το αρχείο παλέτας είναι κατεστραμμένο.',
      'cancelled': 'Ο υπολογισμός ακυρώθηκε.',
      'other': 'Παρουσιάστηκε σφάλμα.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage =>
      'Δεν ήταν δυνατή η ανάγνωση ή η εγγραφή του αρχείου.';

  @override
  String get failureInvalidData => 'Δεν ήταν δυνατή η ανάγνωση των δεδομένων.';

  @override
  String get failureUnknown => 'Παρουσιάστηκε απρόσμενο σφάλμα.';

  @override
  String get panelTools => 'Εργαλεία';

  @override
  String get panelHistory => 'Ιστορικό';

  @override
  String get panelLayers => 'Επίπεδα';

  @override
  String get panelColors => 'Χρώματα';

  @override
  String get panelHide => 'Απόκρυψη';

  @override
  String get colorsPrimary => 'Πρωτεύον';

  @override
  String get colorsSecondary => 'Δευτερεύον';

  @override
  String get colorsPrimaryHint =>
      'Πρωτεύον χρώμα: με αυτό ζωγραφίζει το αριστερό κουμπί του ποντικιού';

  @override
  String get colorsSecondaryHint =>
      'Δευτερεύον χρώμα: με αυτό ζωγραφίζει το δεξί κουμπί του ποντικιού';

  @override
  String get colorsSwap => 'Εναλλαγή χρωμάτων (X)';

  @override
  String get colorsReset => 'Επαναφορά σε μαύρο και λευκό';

  @override
  String get colorsMore => 'Περισσότερα';

  @override
  String get colorsLess => 'Λιγότερα';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Άλφα';

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
      'Το αριστερό κλικ ορίζει το πρωτεύον χρώμα, το δεξί το δευτερεύον';

  @override
  String get settingWidth => 'Πλάτος';

  @override
  String get settingHardness => 'Σκληρότητα';

  @override
  String get settingAntialias => 'Εξομάλυνση';

  @override
  String get settingAlphaBlending => 'Ανάμειξη άλφα';

  @override
  String get settingTolerance => 'Ανοχή';

  @override
  String get settingFloodMode => 'Λειτουργία γεμίσματος';

  @override
  String get floodLocal => 'Συνεχόμενη';

  @override
  String get floodGlobal => 'Καθολική';

  @override
  String get settingSelectionMode => 'Λειτουργία επιλογής';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Αντικατάσταση',
      'union': 'Ένωση',
      'exclude': 'Εξαίρεση',
      'xor': 'Xor',
      'intersect': 'Τομή',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Μέγεθος επιλογής';

  @override
  String get drawNormal => 'Ελεύθερο';

  @override
  String get drawFixedRatio => 'Σταθερή αναλογία';

  @override
  String get drawFixedSize => 'Σταθερό μέγεθος';

  @override
  String get settingResampling => 'Επαναδειγματοληψία';

  @override
  String get resamplingNearest => 'Πλησιέστερος γείτονας';

  @override
  String get resamplingBilinear => 'Διγραμμική';

  @override
  String get settingGradient => 'Τύπος';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Γραμμική',
      'linearReflected': 'Γραμμική κατοπτρική',
      'diamond': 'Ρόμβος',
      'radial': 'Ακτινική',
      'conical': 'Κωνική',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Χρώμα';

  @override
  String get gradientTransparency => 'Διαφάνεια';

  @override
  String get settingShape => 'Στυλ σχήματος';

  @override
  String get shapeOutline => 'Περίγραμμα';

  @override
  String get shapeInterior => 'Γέμισμα';

  @override
  String get shapeBoth => 'Περίγραμμα και γέμισμα';

  @override
  String get settingAfterPick => 'Μετά τη λήψη χρώματος';

  @override
  String get pickStay => 'Παραμονή σε αυτό το εργαλείο';

  @override
  String get pickPrevious => 'Επιστροφή στο προηγούμενο εργαλείο';

  @override
  String get pickPencil => 'Μετάβαση στο Μολύβι';

  @override
  String get settingNone => 'Αυτό το εργαλείο δεν έχει ρυθμίσεις.';

  @override
  String toolUnavailable(String name) {
    return 'Το εργαλείο «$name» δεν είναι ακόμη διαθέσιμο';
  }

  @override
  String get historyFirst => 'Μετάβαση στο πρώτο βήμα';

  @override
  String get historyUndo => 'Αναίρεση';

  @override
  String get historyRedo => 'Επανάληψη';

  @override
  String get historyLast => 'Μετάβαση στο τελευταίο βήμα';

  @override
  String get historyNewImage => 'Νέα εικόνα';

  @override
  String get historyOpenImage => 'Άνοιγμα εικόνας';

  @override
  String get layerVisible => 'Εμφάνιση ή απόκρυψη του επιπέδου';

  @override
  String get layerBackground => 'Φόντο';

  @override
  String get layerName => 'Όνομα';

  @override
  String get layerOpacity => 'Αδιαφάνεια';

  @override
  String get layerBlendMode => 'Λειτουργία ανάμειξης';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get dontSave => 'Χωρίς αποθήκευση';

  @override
  String get keepCanvas => 'Διατήρηση του καμβά';

  @override
  String get expandCanvas => 'Επέκταση του καμβά';

  @override
  String get width => 'Πλάτος';

  @override
  String get height => 'Ύψος';

  @override
  String get pixels => 'εικονοστοιχεία';

  @override
  String get newImageTitle => 'Νέα εικόνα';

  @override
  String get resizeTitle => 'Αλλαγή μεγέθους εικόνας';

  @override
  String get canvasSizeTitle => 'Μέγεθος καμβά';

  @override
  String get keepRatio => 'Διατήρηση αναλογίας διαστάσεων';

  @override
  String get anchor => 'Αγκύρωση';

  @override
  String sizeTooLarge(int max) {
    return 'Η εικόνα είναι πολύ μεγάλη: το όριο είναι $max megapixel.';
  }

  @override
  String get unsavedTitle => 'Αποθήκευση αλλαγών;';

  @override
  String unsavedMessage(String name) {
    return 'Το «$name» έχει μη αποθηκευμένες αλλαγές.';
  }

  @override
  String get flattenTitle => 'Ισοπέδωση της εικόνας;';

  @override
  String flattenMessage(String format) {
    return 'Η μορφή $format δεν διατηρεί επίπεδα, οπότε η εικόνα θα ισοπεδωθεί σε ένα επίπεδο. Μπορείτε να το αναιρέσετε στο παράθυρο Ιστορικό.';
  }

  @override
  String get flatten => 'Ισοπέδωση';

  @override
  String get jpegQualityTitle => 'Ποιότητα JPEG';

  @override
  String get quality => 'Ποιότητα';

  @override
  String get largerTitle => 'Η εικόνα είναι μεγαλύτερη από τον καμβά';

  @override
  String get largerMessage => 'Επέκταση του καμβά ώστε να τη χωρέσει;';

  @override
  String get reseed => 'Νέος σπόρος';

  @override
  String get rendering => 'Απόδοση…';

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
    return 'Άνοιγμα του $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Αποθήκευση του $name…';
  }

  @override
  String savedTo(String name) {
    return 'Αποθηκεύτηκε: $name';
  }

  @override
  String get dropHere => 'Αφήστε για άνοιγμα';

  @override
  String get dropHint => 'Κάθε αρχείο ανοίγει ως νέα εικόνα';

  @override
  String get imagesList => 'Ανοιχτές εικόνες';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Επεξεργαστής εικόνων ράστερ με επίπεδα. Πατήστε ένα γράμμα για να επιλέξετε εργαλείο· πατώντας ξανά S, M ή O εναλλάσσονται τα σχετικά εργαλεία. Τα [ και ] αλλάζουν το πλάτος του πινέλου, το X εναλλάσσει τα χρώματα, κρατώντας πατημένο το πλήκτρο διαστήματος μετακινείτε την προβολή, το Ctrl+ροδέλα του ποντικιού αλλάζει το ζουμ και τα F5–F8 εμφανίζουν ή αποκρύπτουν τα παράθυρα.';

  @override
  String get aboutLegal =>
      '© 2026 οι δημιουργοί του Paintbox. Το Paintbox είναι ελεύθερο λογισμικό: μπορείτε να το αναδιανείμετε και να το τροποποιήσετε σύμφωνα με τους όρους της GNU General Public License, έκδοση 3 ή νεότερη. Παρέχεται χωρίς καμία εγγύηση.';

  @override
  String get licenses => 'Άδειες χρήσης';

  @override
  String get settingLineStart => 'Αρχή';

  @override
  String get settingLineEnd => 'Τέλος';

  @override
  String get settingDash => 'Παύλες';

  @override
  String get settingSwapSize => 'Εναλλαγή πλάτους και ύψους';

  @override
  String get settingLineStyle => 'Στυλ';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Επίπεδο',
      'arrow': 'Βέλος',
      'arrowFilled': 'Γεμάτο βέλος',
      'rounded': 'Στρογγυλεμένο',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Συνεχής',
      'dash': 'Παύλα',
      'dashDot': 'Παύλα-τελεία',
      'dashDotDot': 'Παύλα-τελεία-τελεία',
      'dot': 'Τελεία',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Γραμματοσειρά';

  @override
  String get settingFontSize => 'Μέγεθος';

  @override
  String get textBold => 'Έντονα';

  @override
  String get textItalic => 'Πλάγια';

  @override
  String get textUnderline => 'Υπογράμμιση';

  @override
  String get textStrikeout => 'Διακριτή διαγραφή';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Αριστερά',
      'center': 'Κέντρο',
      'right': 'Δεξιά',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Εικόνες';
}
