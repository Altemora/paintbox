// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Bez naslova $number';
  }

  @override
  String get menuFile => 'Datoteka';

  @override
  String get menuEdit => 'Uređivanje';

  @override
  String get menuView => 'Prikaz';

  @override
  String get menuImage => 'Slika';

  @override
  String get menuLayers => 'Slojevi';

  @override
  String get menuAdjustments => 'Prilagodbe';

  @override
  String get menuEffects => 'Efekti';

  @override
  String get menuOpenRecent => 'Nedavne datoteke';

  @override
  String get menuRecentEmpty => 'Nema nedavnih datoteka';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Postavke';

  @override
  String get menuAccent => 'Boja isticanja';

  @override
  String get menuLanguage => 'Jezik';

  @override
  String get languageSystem => 'Zadano sustavom';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Plava',
      'green': 'Zelena',
      'amber': 'Jantarna',
      'purple': 'Ljubičasta',
      'red': 'Crvena',
      'gray': 'Siva',
      'custom': 'Prilagođena…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Prilagođena boja isticanja';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Zadano sustavom';

  @override
  String get themeDark => 'Tamna';

  @override
  String get themeLight => 'Svijetla';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Novo…',
      'open': 'Otvori…',
      'close': 'Zatvori',
      'save': 'Spremi',
      'save_as': 'Spremi kao…',
      'exit': 'Izlaz',
      'undo': 'Poništi',
      'redo': 'Ponovi',
      'cut': 'Izreži',
      'copy': 'Kopiraj',
      'paste': 'Zalijepi',
      'paste_into_new_layer': 'Zalijepi u novi sloj',
      'paste_into_new_image': 'Zalijepi u novu sliku',
      'erase_selection': 'Izbriši odabrano',
      'fill_selection': 'Ispuni odabrano',
      'invert_selection': 'Obrni odabir',
      'select_all': 'Odaberi sve',
      'deselect': 'Poništi odabir',
      'zoom_in': 'Povećaj',
      'zoom_out': 'Smanji',
      'zoom_to_window': 'Prilagodi prozoru',
      'zoom_to_selection': 'Prilagodi odabiru',
      'actual_size': 'Stvarna veličina',
      'pixel_grid': 'Mreža piksela',
      'rulers': 'Ravnala',
      'crop_to_selection': 'Obreži na odabir',
      'resize': 'Promijeni veličinu…',
      'canvas_size': 'Veličina platna…',
      'flip_horizontal': 'Zrcali vodoravno',
      'flip_vertical': 'Zrcali okomito',
      'rotate90_cw': 'Zakreni za 90° u smjeru kazaljke na satu',
      'rotate90_ccw': 'Zakreni za 90° suprotno od smjera kazaljke na satu',
      'rotate180': 'Zakreni za 180°',
      'flatten': 'Stopi slojeve',
      'add_layer': 'Dodaj novi sloj',
      'delete_layer': 'Izbriši sloj',
      'duplicate_layer': 'Udvostruči sloj',
      'merge_layer_down': 'Spoji s donjim slojem',
      'import_from_file': 'Uvezi iz datoteke…',
      'flip_layer_horizontal': 'Zrcali sloj vodoravno',
      'flip_layer_vertical': 'Zrcali sloj okomito',
      'move_layer_up': 'Pomakni sloj gore',
      'move_layer_down': 'Pomakni sloj dolje',
      'layer_properties': 'Svojstva sloja…',
      'adjust_auto_level': 'Automatske razine',
      'adjust_black_and_white': 'Crno-bijelo',
      'adjust_brightness_contrast': 'Svjetlina / kontrast…',
      'adjust_curves': 'Krivulje…',
      'adjust_hue_saturation': 'Nijansa / zasićenost…',
      'adjust_invert_colors': 'Invertiraj boje',
      'adjust_levels': 'Razine…',
      'adjust_posterize': 'Posterizacija…',
      'adjust_sepia': 'Sepija',
      'repeat_effect': 'Ponovi efekt',
      'effect_oil_painting': 'Uljana slika…',
      'effect_gaussian_blur': 'Gaussovo zamućenje…',
      'effect_motion_blur': 'Zamućenje pokreta…',
      'effect_pixelate': 'Pikselizacija…',
      'effect_add_noise': 'Dodavanje šuma…',
      'effect_median': 'Medijan…',
      'effect_sharpen': 'Izoštravanje…',
      'effect_edge_detect': 'Otkrivanje rubova…',
      'effect_emboss': 'Utiskivanje…',
      'effect_outline': 'Obris…',
      'toggle_tools': 'Alati',
      'toggle_history': 'Povijest',
      'toggle_layers': 'Slojevi',
      'toggle_colors': 'Boje',
      'next_image': 'Sljedeća slika',
      'previous_image': 'Prethodna slika',
      'help': 'Pomoć',
      'effect_ink_sketch': 'Skica tintom…',
      'effect_pencil_sketch': 'Skica olovkom…',
      'effect_fragment': 'Fragmentiranje…',
      'effect_radial_blur': 'Radijalno zamućenje…',
      'effect_surface_blur': 'Površinsko zamućenje…',
      'effect_unfocus': 'Defokusiranje…',
      'effect_zoom_blur': 'Zamućenje zumiranjem…',
      'effect_bulge': 'Izbočenje…',
      'effect_dents': 'Udubljenja…',
      'effect_frosted_glass': 'Mutno staklo…',
      'effect_polar_inversion': 'Polarna inverzija…',
      'effect_tile_reflection': 'Odraz pločica…',
      'effect_twist': 'Uvijanje…',
      'effect_reduce_noise': 'Smanjenje šuma…',
      'effect_glow': 'Sjaj…',
      'effect_red_eye_removal': 'Uklanjanje crvenih očiju…',
      'effect_soften_portrait': 'Omekšavanje portreta…',
      'effect_clouds': 'Oblaci…',
      'effect_julia_fractal': 'Julijin fraktal…',
      'effect_mandelbrot_fractal': 'Mandelbrotov fraktal…',
      'effect_relief': 'Reljef…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Umjetnički',
      'blurs': 'Zamućenja',
      'distort': 'Izobličenja',
      'noise': 'Šum',
      'photo': 'Fotografija',
      'stylize': 'Stilizacija',
      'render': 'Iscrtavanje',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Pravokutni odabir',
      'move_selected_pixels': 'Pomicanje odabranih piksela',
      'lasso_select': 'Laso odabir',
      'move_selection': 'Pomicanje odabira',
      'ellipse_select': 'Eliptični odabir',
      'zoom': 'Zumiranje',
      'magic_wand': 'Čarobni štapić',
      'pan': 'Pomicanje prikaza',
      'paint_bucket': 'Kanta boje',
      'gradient': 'Gradijent',
      'paintbrush': 'Kist',
      'eraser': 'Gumica',
      'pencil': 'Olovka',
      'color_picker': 'Kapaljka',
      'clone_stamp': 'Pečat za kloniranje',
      'recolor': 'Prebojavanje',
      'text': 'Tekst',
      'line_curve': 'Linija / krivulja',
      'rectangle': 'Pravokutnik',
      'rounded_rectangle': 'Zaobljeni pravokutnik',
      'ellipse': 'Elipsa',
      'freeform_shape': 'Slobodni oblik',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select':
          'Povucite kako biste odabrali pravokutnik. Držite Shift za kvadrat.',
      'move_selected_pixels': 'Povucite odabir kako biste ga pomaknuli. Povucite desnom tipkom kako biste ga zakrenuli ili povucite ručice kako biste mu promijenili veličinu. Ctrl ostavlja kopiju, a tipke sa strelicama pomiču odabir u malim koracima.',
      'lasso_select': 'Povucite kako biste nacrtali obris odabira.',
      'move_selection': 'Povucite obris odabira kako biste ga pomaknuli. Pikseli ostaju na mjestu.',
      'ellipse_select':
          'Povucite kako biste odabrali elipsu. Držite Shift za krug.',
      'zoom': 'Lijevi klik povećava prikaz, desni klik ga smanjuje, a povlačenjem okvira prikaz se povećava na označeno područje.',
      'magic_wand': 'Kliknite boju kako biste odabrali područje oko nje. Držite Shift kako biste tu boju odabrali na cijeloj slici.',
      'pan': 'Povucite kako biste pomaknuli prikaz.',
      'paint_bucket':
          'Lijevi klik ispunjava primarnom bojom, desni klik sekundarnom.',
      'gradient': 'Povucite kako biste nacrtali gradijent. Povucite ručice kako biste ga prilagodili; pritisnite Enter za završetak.',
      'paintbrush':
          'Lijeva tipka slika primarnom bojom, desna tipka sekundarnom.',
      'eraser': 'Povucite kako biste brisali do potpune prozirnosti.',
      'pencil': 'Crta linije debljine jednog piksela bez zaglađivanja rubova.',
      'color_picker': 'Lijevi klik uzima primarnu boju, desni klik sekundarnu.',
      'clone_stamp': 'Ctrl+klikom postavite izvor, a zatim povucite kako biste slikali iz njega.',
      'recolor': 'Zamjenjuje sekundarnu boju primarnom ondje gdje slikate. Ctrl+klik uzima boju.',
      'text': 'Kliknite kako biste postavili kursor, a zatim tipkajte. Povucite ručicu ili povucite desnom tipkom kako biste pomaknuli tekst; pritisnite Esc za završetak.',
      'line_curve': 'Povucite kako biste nacrtali liniju. Povucite ručice kako biste je savili; pritisnite Enter za završetak.',
      'rectangle':
          'Povucite kako biste nacrtali pravokutnik. Držite Shift za kvadrat.',
      'rounded_rectangle': 'Povucite kako biste nacrtali zaobljeni pravokutnik. Držite Shift za kvadrat.',
      'ellipse': 'Povucite kako biste nacrtali elipsu. Držite Shift za krug.',
      'freeform_shape':
          'Povucite kako biste nacrtali zatvoreni slobodni oblik.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Radijus',
      'angle': 'Kut',
      'distance': 'Udaljenost',
      'centered': 'Centrirano',
      'amount': 'Količina',
      'intensity': 'Intenzitet',
      'saturation': 'Zasićenost',
      'coverage': 'Pokrivenost',
      'seed': 'Sjeme',
      'percentile': 'Percentil',
      'cell_size': 'Veličina ćelije',
      'brush_size': 'Veličina kista',
      'coarseness': 'Grubost',
      'thickness': 'Debljina',
      'brightness': 'Svjetlina',
      'contrast': 'Kontrast',
      'hue': 'Nijansa',
      'lightness': 'Svjetloća',
      'red': 'Crvena',
      'green': 'Zelena',
      'blue': 'Plava',
      'input_low': 'Donja ulazna razina',
      'input_high': 'Gornja ulazna razina',
      'output_low': 'Donja izlazna razina',
      'output_high': 'Gornja izlazna razina',
      'gamma': 'Gama',
      'ink_outline': 'Obris tintom',
      'coloring': 'Bojenje',
      'tip_size': 'Veličina vrha olovke',
      'color_range': 'Raspon boja',
      'fragments': 'Fragmenti',
      'rotation': 'Zakretanje',
      'offset_x': 'Pomak X',
      'offset_y': 'Pomak Y',
      'quality': 'Kvaliteta',
      'threshold': 'Prag',
      'scale': 'Mjerilo',
      'refraction': 'Lom svjetlosti',
      'roughness': 'Hrapavost',
      'tension': 'Napetost',
      'max_scatter': 'Najveće raspršenje',
      'min_scatter': 'Najmanje raspršenje',
      'samples': 'Uzorci',
      'edge_behavior': 'Ponašanje rubova',
      'tile_size': 'Veličina pločice',
      'curvature': 'Zakrivljenost',
      'size': 'Veličina',
      'strength': 'Jačina',
      'tolerance': 'Tolerancija',
      'softness': 'Mekoća',
      'lighting': 'Osvjetljenje',
      'warmth': 'Toplina',
      'power': 'Potencija',
      'blend_mode': 'Način stapanja',
      'factor': 'Faktor',
      'zoom': 'Zumiranje',
      'invert_colors': 'Invertiraj boje',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normalno',
      'multiply': 'Množenje',
      'additive': 'Zbrajanje',
      'colorBurn': 'Tamnjenje boje',
      'colorDodge': 'Posvjetljivanje boje',
      'reflect': 'Refleksija',
      'glow': 'Sjaj',
      'overlay': 'Preklapanje',
      'difference': 'Razlika',
      'negation': 'Negacija',
      'lighten': 'Svjetlije',
      'darken': 'Tamnije',
      'screen': 'Zaslon',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Nema dovoljno memorije za sliku.',
      'invalid_size': 'Veličina slike nije valjana.',
      'layer_index': 'Takav sloj ne postoji.',
      'last_layer': 'Posljednji sloj nije moguće izbrisati.',
      'no_layer_below': 'Ispod nema sloja s kojim bi se ovaj spojio.',
      'edit_in_progress': 'Najprije dovršite radnju koja je u tijeku.',
      'no_edit': 'Nema radnje u tijeku koju treba dovršiti.',
      'no_selection': 'Ništa nije odabrano.',
      'nothing_lifted': 'Nema podignutih piksela.',
      'invalid_parameter': 'Vrijednost je izvan dopuštenog raspona.',
      'io': 'Datoteku nije bilo moguće pročitati ili zapisati.',
      'decode': 'Sliku nije bilo moguće pročitati.',
      'encode': 'Sliku nije bilo moguće zapisati.',
      'open_raster': 'Datoteka OpenRaster je oštećena.',
      'palette': 'Datoteka palete je oštećena.',
      'cancelled': 'Izračun je otkazan.',
      'other': 'Došlo je do pogreške.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage =>
      'Datoteku nije bilo moguće pročitati ili zapisati.';

  @override
  String get failureInvalidData => 'Podatke nije bilo moguće pročitati.';

  @override
  String get failureUnknown => 'Došlo je do neočekivane pogreške.';

  @override
  String get panelTools => 'Alati';

  @override
  String get panelHistory => 'Povijest';

  @override
  String get panelLayers => 'Slojevi';

  @override
  String get panelColors => 'Boje';

  @override
  String get panelHide => 'Sakrij';

  @override
  String get colorsPrimary => 'Primarna';

  @override
  String get colorsSecondary => 'Sekundarna';

  @override
  String get colorsPrimaryHint =>
      'Primarna boja: njome slika lijeva tipka miša';

  @override
  String get colorsSecondaryHint =>
      'Sekundarna boja: njome slika desna tipka miša';

  @override
  String get colorsSwap => 'Zamijeni boje (X)';

  @override
  String get colorsReset => 'Vrati na crnu i bijelu';

  @override
  String get colorsMore => 'Više';

  @override
  String get colorsLess => 'Manje';

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
      'Lijevi klik postavlja primarnu boju, desni klik sekundarnu';

  @override
  String get settingWidth => 'Širina';

  @override
  String get settingHardness => 'Tvrdoća';

  @override
  String get settingAntialias => 'Zaglađivanje rubova';

  @override
  String get settingAlphaBlending => 'Alfa stapanje';

  @override
  String get settingTolerance => 'Tolerancija';

  @override
  String get settingFloodMode => 'Način ispune';

  @override
  String get floodLocal => 'Povezano';

  @override
  String get floodGlobal => 'Globalno';

  @override
  String get settingSelectionMode => 'Način odabira';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Zamjena',
      'union': 'Unija',
      'exclude': 'Isključivanje',
      'xor': 'XOR',
      'intersect': 'Presjek',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Veličina odabira';

  @override
  String get drawNormal => 'Normalno';

  @override
  String get drawFixedRatio => 'Fiksni omjer';

  @override
  String get drawFixedSize => 'Fiksna veličina';

  @override
  String get settingResampling => 'Ponovno uzorkovanje';

  @override
  String get resamplingNearest => 'Najbliži susjed';

  @override
  String get resamplingBilinear => 'Bilinearno';

  @override
  String get settingGradient => 'Vrsta';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Linearni',
      'linearReflected': 'Linearni zrcaljeni',
      'diamond': 'Rombni',
      'radial': 'Radijalni',
      'conical': 'Konusni',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Boja';

  @override
  String get gradientTransparency => 'Prozirnost';

  @override
  String get settingShape => 'Stil oblika';

  @override
  String get shapeOutline => 'Obris';

  @override
  String get shapeInterior => 'Ispuna';

  @override
  String get shapeBoth => 'Obris i ispuna';

  @override
  String get settingAfterPick => 'Nakon uzimanja boje';

  @override
  String get pickStay => 'Zadrži ovaj alat';

  @override
  String get pickPrevious => 'Prijeđi na prethodni alat';

  @override
  String get pickPencil => 'Prijeđi na Olovku';

  @override
  String get settingNone => 'Ovaj alat nema postavki.';

  @override
  String toolUnavailable(String name) {
    return 'Alat „$name“ još nije dostupan';
  }

  @override
  String get historyFirst => 'Idi na prvi korak';

  @override
  String get historyUndo => 'Poništi';

  @override
  String get historyRedo => 'Ponovi';

  @override
  String get historyLast => 'Idi na zadnji korak';

  @override
  String get historyNewImage => 'Nova slika';

  @override
  String get historyOpenImage => 'Otvaranje slike';

  @override
  String get layerVisible => 'Prikaži ili sakrij sloj';

  @override
  String get layerBackground => 'Pozadina';

  @override
  String get layerName => 'Naziv';

  @override
  String get layerOpacity => 'Neprozirnost';

  @override
  String get layerBlendMode => 'Način stapanja';

  @override
  String get ok => 'U redu';

  @override
  String get cancel => 'Odustani';

  @override
  String get save => 'Spremi';

  @override
  String get dontSave => 'Nemoj spremiti';

  @override
  String get keepCanvas => 'Zadrži platno';

  @override
  String get expandCanvas => 'Proširi platno';

  @override
  String get width => 'Širina';

  @override
  String get height => 'Visina';

  @override
  String get pixels => 'piksela';

  @override
  String get newImageTitle => 'Nova slika';

  @override
  String get resizeTitle => 'Promjena veličine slike';

  @override
  String get canvasSizeTitle => 'Veličina platna';

  @override
  String get keepRatio => 'Zadrži omjer stranica';

  @override
  String get anchor => 'Sidro';

  @override
  String sizeTooLarge(int max) {
    return 'Slika je prevelika: ograničenje je $max megapiksela.';
  }

  @override
  String get unsavedTitle => 'Spremiti promjene?';

  @override
  String unsavedMessage(String name) {
    return '„$name“ ima nespremljene promjene.';
  }

  @override
  String get flattenTitle => 'Stopiti slojeve slike?';

  @override
  String flattenMessage(String format) {
    return 'Format $format ne čuva slojeve pa će slika biti stopljena u jedan sloj. To možete poništiti u prozoru Povijest.';
  }

  @override
  String get flatten => 'Stopi';

  @override
  String get jpegQualityTitle => 'Kvaliteta JPEG-a';

  @override
  String get quality => 'Kvaliteta';

  @override
  String get largerTitle => 'Slika je veća od platna';

  @override
  String get largerMessage => 'Proširiti platno kako bi slika stala?';

  @override
  String get reseed => 'Novo sjeme';

  @override
  String get rendering => 'Iscrtavanje…';

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
    return 'Otvaranje datoteke $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Spremanje datoteke $name…';
  }

  @override
  String savedTo(String name) {
    return 'Spremljeno: $name';
  }

  @override
  String get dropHere => 'Ispustite za otvaranje';

  @override
  String get dropHint => 'Svaka se datoteka otvara kao nova slika';

  @override
  String get imagesList => 'Otvorene slike';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Uređivač rasterskih slika sa slojevima. Alat birate pritiskom na njegovo slovo; ponovnim pritiskom na S, M ili O izmjenjuju se srodni alati. [ i ] mijenjaju širinu kista, X zamjenjuje boje, držanjem razmaknice pomiče se prikaz, Ctrl+kotačić miša zumira, a F5–F8 prikazuju ili skrivaju prozore.';

  @override
  String get aboutLegal =>
      '© 2026 autori Paintboxa. Paintbox je slobodan softver: možete ga dijeliti i mijenjati pod uvjetima licencije GNU General Public License, verzije 3 ili novije. Program se isporučuje bez ikakvog jamstva.';

  @override
  String get licenses => 'Licencije';

  @override
  String get settingLineStart => 'Početak';

  @override
  String get settingLineEnd => 'Kraj';

  @override
  String get settingDash => 'Crtkanje';

  @override
  String get settingSwapSize => 'Zamijeni širinu i visinu';

  @override
  String get settingLineStyle => 'Stil';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Ravni',
      'arrow': 'Strelica',
      'arrowFilled': 'Ispunjena strelica',
      'rounded': 'Zaobljeni',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Puna',
      'dash': 'Crtkana',
      'dashDot': 'Crta-točka',
      'dashDotDot': 'Crta-točka-točka',
      'dot': 'Točkasta',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Font';

  @override
  String get settingFontSize => 'Veličina';

  @override
  String get textBold => 'Podebljano';

  @override
  String get textItalic => 'Kurziv';

  @override
  String get textUnderline => 'Podcrtano';

  @override
  String get textStrikeout => 'Precrtano';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Lijevo',
      'center': 'Centrirano',
      'right': 'Desno',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Slike';
}
