// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Bez tytułu $number';
  }

  @override
  String get menuFile => 'Plik';

  @override
  String get menuEdit => 'Edycja';

  @override
  String get menuView => 'Widok';

  @override
  String get menuImage => 'Obraz';

  @override
  String get menuLayers => 'Warstwy';

  @override
  String get menuAdjustments => 'Korekty';

  @override
  String get menuEffects => 'Efekty';

  @override
  String get menuOpenRecent => 'Ostatnio otwierane';

  @override
  String get menuRecentEmpty => 'Brak ostatnio otwieranych plików';

  @override
  String get menuTheme => 'Motyw';

  @override
  String get menuSettings => 'Ustawienia';

  @override
  String get menuAccent => 'Kolor akcentu';

  @override
  String get menuLanguage => 'Język';

  @override
  String get languageSystem => 'Zgodnie z systemem';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Niebieski',
      'green': 'Zielony',
      'amber': 'Bursztynowy',
      'purple': 'Fioletowy',
      'red': 'Czerwony',
      'gray': 'Szary',
      'custom': 'Własny…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Własny kolor akcentu';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Zgodnie z systemem';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get themeLight => 'Jasny';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nowy…',
      'open': 'Otwórz…',
      'close': 'Zamknij',
      'save': 'Zapisz',
      'save_as': 'Zapisz jako…',
      'exit': 'Zakończ',
      'undo': 'Cofnij',
      'redo': 'Ponów',
      'cut': 'Wytnij',
      'copy': 'Kopiuj',
      'paste': 'Wklej',
      'paste_into_new_layer': 'Wklej do nowej warstwy',
      'paste_into_new_image': 'Wklej do nowego obrazu',
      'erase_selection': 'Wymaż zaznaczenie',
      'fill_selection': 'Wypełnij zaznaczenie',
      'invert_selection': 'Odwróć zaznaczenie',
      'select_all': 'Zaznacz wszystko',
      'deselect': 'Odznacz',
      'zoom_in': 'Powiększ',
      'zoom_out': 'Pomniejsz',
      'zoom_to_window': 'Dopasuj do okna',
      'zoom_to_selection': 'Dopasuj do zaznaczenia',
      'actual_size': 'Rzeczywisty rozmiar',
      'pixel_grid': 'Siatka pikseli',
      'rulers': 'Linijki',
      'crop_to_selection': 'Przytnij do zaznaczenia',
      'resize': 'Zmień rozmiar obrazu…',
      'canvas_size': 'Zmień rozmiar płótna…',
      'flip_horizontal': 'Odbij w poziomie',
      'flip_vertical': 'Odbij w pionie',
      'rotate90_cw': 'Obróć o 90° w prawo',
      'rotate90_ccw': 'Obróć o 90° w lewo',
      'rotate180': 'Obróć o 180°',
      'flatten': 'Spłaszcz obraz',
      'add_layer': 'Dodaj nową warstwę',
      'delete_layer': 'Usuń warstwę',
      'duplicate_layer': 'Powiel warstwę',
      'merge_layer_down': 'Scal warstwę w dół',
      'import_from_file': 'Importuj z pliku…',
      'flip_layer_horizontal': 'Odbij warstwę w poziomie',
      'flip_layer_vertical': 'Odbij warstwę w pionie',
      'move_layer_up': 'Przenieś warstwę w górę',
      'move_layer_down': 'Przenieś warstwę w dół',
      'layer_properties': 'Właściwości warstwy…',
      'adjust_auto_level': 'Automatyczne poziomy',
      'adjust_black_and_white': 'Czarno-białe',
      'adjust_brightness_contrast': 'Jasność / kontrast…',
      'adjust_curves': 'Krzywe…',
      'adjust_hue_saturation': 'Barwa / nasycenie…',
      'adjust_invert_colors': 'Odwróć kolory',
      'adjust_levels': 'Poziomy…',
      'adjust_posterize': 'Posteryzacja…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Powtórz efekt',
      'effect_oil_painting': 'Obraz olejny…',
      'effect_gaussian_blur': 'Rozmycie Gaussa…',
      'effect_motion_blur': 'Rozmycie ruchu…',
      'effect_pixelate': 'Pikselizacja…',
      'effect_add_noise': 'Dodaj szum…',
      'effect_median': 'Mediana…',
      'effect_sharpen': 'Wyostrzanie…',
      'effect_edge_detect': 'Wykrywanie krawędzi…',
      'effect_emboss': 'Wytłaczanie…',
      'effect_outline': 'Kontur…',
      'toggle_tools': 'Narzędzia',
      'toggle_history': 'Historia',
      'toggle_layers': 'Warstwy',
      'toggle_colors': 'Kolory',
      'next_image': 'Następny obraz',
      'previous_image': 'Poprzedni obraz',
      'help': 'Pomoc',
      'effect_ink_sketch': 'Szkic tuszem…',
      'effect_pencil_sketch': 'Szkic ołówkiem…',
      'effect_fragment': 'Fragmentacja…',
      'effect_radial_blur': 'Rozmycie radialne…',
      'effect_surface_blur': 'Rozmycie powierzchniowe…',
      'effect_unfocus': 'Rozogniskowanie…',
      'effect_zoom_blur': 'Rozmycie przez powiększenie…',
      'effect_bulge': 'Wybrzuszenie…',
      'effect_dents': 'Wgniecenia…',
      'effect_frosted_glass': 'Szkło matowe…',
      'effect_polar_inversion': 'Inwersja biegunowa…',
      'effect_tile_reflection': 'Odbicie w kafelkach…',
      'effect_twist': 'Skręcenie…',
      'effect_reduce_noise': 'Redukcja szumu…',
      'effect_glow': 'Poświata…',
      'effect_red_eye_removal': 'Usuwanie czerwonych oczu…',
      'effect_soften_portrait': 'Zmiękczanie portretu…',
      'effect_clouds': 'Chmury…',
      'effect_julia_fractal': 'Fraktal Julii…',
      'effect_mandelbrot_fractal': 'Fraktal Mandelbrota…',
      'effect_relief': 'Płaskorzeźba…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artystyczne',
      'blurs': 'Rozmycie',
      'distort': 'Zniekształcenie',
      'noise': 'Szum',
      'photo': 'Fotografia',
      'stylize': 'Stylizacja',
      'render': 'Renderowanie',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Zaznaczenie prostokątne',
      'move_selected_pixels': 'Przesuwanie zaznaczonych pikseli',
      'lasso_select': 'Lasso',
      'move_selection': 'Przesuwanie zaznaczenia',
      'ellipse_select': 'Zaznaczenie eliptyczne',
      'zoom': 'Powiększenie',
      'magic_wand': 'Różdżka',
      'pan': 'Rączka',
      'paint_bucket': 'Wiadro z farbą',
      'gradient': 'Gradient',
      'paintbrush': 'Pędzel',
      'eraser': 'Gumka',
      'pencil': 'Ołówek',
      'color_picker': 'Pipeta',
      'clone_stamp': 'Stempel',
      'recolor': 'Przemalowywanie',
      'text': 'Tekst',
      'line_curve': 'Linia / krzywa',
      'rectangle': 'Prostokąt',
      'rounded_rectangle': 'Zaokrąglony prostokąt',
      'ellipse': 'Elipsa',
      'freeform_shape': 'Kształt dowolny',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Przeciągnij, aby zaznaczyć prostokąt. Przytrzymaj Shift, aby uzyskać kwadrat.',
      'move_selected_pixels': 'Przeciągnij zaznaczenie, aby je przesunąć. Przeciągnij prawym przyciskiem, aby je obrócić, lub przeciągnij uchwyty, aby je przeskalować. Ctrl pozostawia kopię, a klawisze strzałek lekko je przesuwają.',
      'lasso_select': 'Przeciągnij, aby narysować obrys zaznaczenia.',
      'move_selection': 'Przeciągnij obrys zaznaczenia, aby go przesunąć. Piksele pozostają na miejscu.',
      'ellipse_select': 'Przeciągnij, aby zaznaczyć elipsę. Przytrzymaj Shift, aby uzyskać okrąg.',
      'zoom': 'Kliknij lewym przyciskiem, aby powiększyć, lub prawym, aby pomniejszyć. Przeciągnij prostokąt, aby powiększyć jego obszar.',
      'magic_wand': 'Kliknij kolor, aby zaznaczyć obszar wokół niego. Przytrzymaj Shift, aby zaznaczyć ten kolor w całym obrazie.',
      'pan': 'Przeciągnij, aby przesunąć widok.',
      'paint_bucket': 'Kliknięcie lewym przyciskiem wypełnia kolorem podstawowym, a prawym — dodatkowym.',
      'gradient': 'Przeciągnij, aby narysować gradient. Przeciągnij uchwyty, aby go dopasować, i naciśnij Enter, aby zakończyć.',
      'paintbrush':
          'Lewy przycisk maluje kolorem podstawowym, a prawy — dodatkowym.',
      'eraser': 'Przeciągnij, aby wymazać do przezroczystości.',
      'pencil': 'Rysuje linie o grubości jednego piksela bez wygładzania.',
      'color_picker': 'Kliknięcie lewym przyciskiem pobiera kolor podstawowy, a prawym — dodatkowy.',
      'clone_stamp': 'Ctrl+kliknięcie ustawia źródło; następnie przeciągnij, aby z niego malować.',
      'recolor': 'Zastępuje kolor dodatkowy podstawowym tam, gdzie malujesz. Ctrl+kliknięcie pobiera kolor.',
      'text': 'Kliknij, aby umieścić kursor, i zacznij pisać. Przeciągnij uchwyt lub przeciągnij prawym przyciskiem, aby przesunąć tekst; naciśnij Esc, aby zakończyć.',
      'line_curve': 'Przeciągnij, aby narysować linię. Przeciągnij uchwyty, aby ją wygiąć, i naciśnij Enter, aby zakończyć.',
      'rectangle': 'Przeciągnij, aby narysować prostokąt. Przytrzymaj Shift, aby uzyskać kwadrat.',
      'rounded_rectangle': 'Przeciągnij, aby narysować zaokrąglony prostokąt. Przytrzymaj Shift, aby uzyskać kwadrat.',
      'ellipse': 'Przeciągnij, aby narysować elipsę. Przytrzymaj Shift, aby uzyskać okrąg.',
      'freeform_shape': 'Przeciągnij, aby narysować zamknięty kształt dowolny.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Promień',
      'angle': 'Kąt',
      'distance': 'Odległość',
      'centered': 'Wyśrodkowany',
      'amount': 'Wartość',
      'intensity': 'Intensywność',
      'saturation': 'Nasycenie',
      'coverage': 'Pokrycie',
      'seed': 'Ziarno',
      'percentile': 'Percentyl',
      'cell_size': 'Rozmiar komórki',
      'brush_size': 'Rozmiar pędzla',
      'coarseness': 'Ziarnistość',
      'thickness': 'Grubość',
      'brightness': 'Jasność',
      'contrast': 'Kontrast',
      'hue': 'Barwa',
      'lightness': 'Jasność',
      'red': 'Czerwony',
      'green': 'Zielony',
      'blue': 'Niebieski',
      'input_low': 'Wejście: minimum',
      'input_high': 'Wejście: maksimum',
      'output_low': 'Wyjście: minimum',
      'output_high': 'Wyjście: maksimum',
      'gamma': 'Gamma',
      'ink_outline': 'Kontur tuszu',
      'coloring': 'Kolorowanie',
      'tip_size': 'Rozmiar grafitu',
      'color_range': 'Zakres kolorów',
      'fragments': 'Fragmenty',
      'rotation': 'Obrót',
      'offset_x': 'Przesunięcie X',
      'offset_y': 'Przesunięcie Y',
      'quality': 'Jakość',
      'threshold': 'Próg',
      'scale': 'Skala',
      'refraction': 'Załamanie',
      'roughness': 'Chropowatość',
      'tension': 'Napięcie',
      'max_scatter': 'Maksymalne rozproszenie',
      'min_scatter': 'Minimalne rozproszenie',
      'samples': 'Próbki',
      'edge_behavior': 'Zachowanie na krawędziach',
      'tile_size': 'Rozmiar kafelka',
      'curvature': 'Krzywizna',
      'size': 'Rozmiar',
      'strength': 'Siła',
      'tolerance': 'Tolerancja',
      'softness': 'Miękkość',
      'lighting': 'Oświetlenie',
      'warmth': 'Ciepło',
      'power': 'Moc',
      'blend_mode': 'Tryb mieszania',
      'factor': 'Współczynnik',
      'zoom': 'Powiększenie',
      'invert_colors': 'Odwróć kolory',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normalny',
      'multiply': 'Mnożenie',
      'additive': 'Dodawanie',
      'colorBurn': 'Ściemnianie koloru',
      'colorDodge': 'Rozjaśnianie koloru',
      'reflect': 'Odbicie',
      'glow': 'Poświata',
      'overlay': 'Nakładka',
      'difference': 'Różnica',
      'negation': 'Negacja',
      'lighten': 'Jaśniejszy',
      'darken': 'Ciemniejszy',
      'screen': 'Mnożenie odwrotne',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Za mało pamięci dla obrazu.',
      'invalid_size': 'Rozmiar obrazu jest nieprawidłowy.',
      'layer_index': 'Taka warstwa nie istnieje.',
      'last_layer': 'Nie można usunąć ostatniej warstwy.',
      'no_layer_below': 'Poniżej nie ma warstwy, z którą można scalić.',
      'edit_in_progress': 'Najpierw zakończ bieżącą operację.',
      'no_edit': 'Nie ma bieżącej operacji do zakończenia.',
      'no_selection': 'Nic nie jest zaznaczone.',
      'nothing_lifted': 'Brak podniesionych pikseli.',
      'invalid_parameter': 'Wartość jest poza zakresem.',
      'io': 'Nie można odczytać ani zapisać pliku.',
      'decode': 'Nie można odczytać obrazu.',
      'encode': 'Nie można zapisać obrazu.',
      'open_raster': 'Plik OpenRaster jest uszkodzony.',
      'palette': 'Plik palety jest uszkodzony.',
      'cancelled': 'Obliczenia zostały anulowane.',
      'other': 'Wystąpił błąd.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Nie można odczytać ani zapisać pliku.';

  @override
  String get failureInvalidData => 'Nie można odczytać danych.';

  @override
  String get failureUnknown => 'Wystąpił nieoczekiwany błąd.';

  @override
  String get panelTools => 'Narzędzia';

  @override
  String get panelHistory => 'Historia';

  @override
  String get panelLayers => 'Warstwy';

  @override
  String get panelColors => 'Kolory';

  @override
  String get panelHide => 'Ukryj';

  @override
  String get colorsPrimary => 'Podstawowy';

  @override
  String get colorsSecondary => 'Dodatkowy';

  @override
  String get colorsPrimaryHint =>
      'Kolor podstawowy: maluje nim lewy przycisk myszy';

  @override
  String get colorsSecondaryHint =>
      'Kolor dodatkowy: maluje nim prawy przycisk myszy';

  @override
  String get colorsSwap => 'Zamień kolory (X)';

  @override
  String get colorsReset => 'Przywróć czarny i biały';

  @override
  String get colorsMore => 'Więcej';

  @override
  String get colorsLess => 'Mniej';

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
      'Kliknięcie lewym przyciskiem ustawia kolor podstawowy, a prawym — dodatkowy';

  @override
  String get settingWidth => 'Szerokość';

  @override
  String get settingHardness => 'Twardość';

  @override
  String get settingAntialias => 'Wygładzanie';

  @override
  String get settingAlphaBlending => 'Mieszanie alfa';

  @override
  String get settingTolerance => 'Tolerancja';

  @override
  String get settingFloodMode => 'Tryb wypełniania';

  @override
  String get floodLocal => 'Ciągły';

  @override
  String get floodGlobal => 'Globalny';

  @override
  String get settingSelectionMode => 'Tryb zaznaczania';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Zastąp',
      'union': 'Dodaj',
      'exclude': 'Odejmij',
      'xor': 'XOR',
      'intersect': 'Przetnij',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Rozmiar zaznaczenia';

  @override
  String get drawNormal => 'Dowolny';

  @override
  String get drawFixedRatio => 'Stałe proporcje';

  @override
  String get drawFixedSize => 'Stały rozmiar';

  @override
  String get settingResampling => 'Ponowne próbkowanie';

  @override
  String get resamplingNearest => 'Najbliższy sąsiad';

  @override
  String get resamplingBilinear => 'Dwuliniowe';

  @override
  String get settingGradient => 'Typ';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Liniowy',
      'linearReflected': 'Liniowy lustrzany',
      'diamond': 'Rombowy',
      'radial': 'Radialny',
      'conical': 'Stożkowy',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Kolor';

  @override
  String get gradientTransparency => 'Przezroczystość';

  @override
  String get settingShape => 'Styl kształtu';

  @override
  String get shapeOutline => 'Kontur';

  @override
  String get shapeInterior => 'Wypełnienie';

  @override
  String get shapeBoth => 'Kontur i wypełnienie';

  @override
  String get settingAfterPick => 'Po pobraniu koloru';

  @override
  String get pickStay => 'Pozostań przy tym narzędziu';

  @override
  String get pickPrevious => 'Przełącz na poprzednie narzędzie';

  @override
  String get pickPencil => 'Przełącz na Ołówek';

  @override
  String get settingNone => 'To narzędzie nie ma ustawień.';

  @override
  String toolUnavailable(String name) {
    return 'Narzędzie „$name” nie jest jeszcze dostępne';
  }

  @override
  String get historyFirst => 'Przejdź do pierwszego kroku';

  @override
  String get historyUndo => 'Cofnij';

  @override
  String get historyRedo => 'Ponów';

  @override
  String get historyLast => 'Przejdź do ostatniego kroku';

  @override
  String get historyNewImage => 'Nowy obraz';

  @override
  String get historyOpenImage => 'Otwarcie obrazu';

  @override
  String get layerVisible => 'Pokaż lub ukryj warstwę';

  @override
  String get layerBackground => 'Tło';

  @override
  String get layerName => 'Nazwa';

  @override
  String get layerOpacity => 'Krycie';

  @override
  String get layerBlendMode => 'Tryb mieszania';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get dontSave => 'Nie zapisuj';

  @override
  String get keepCanvas => 'Zachowaj płótno';

  @override
  String get expandCanvas => 'Powiększ płótno';

  @override
  String get width => 'Szerokość';

  @override
  String get height => 'Wysokość';

  @override
  String get pixels => 'pikseli';

  @override
  String get newImageTitle => 'Nowy obraz';

  @override
  String get resizeTitle => 'Zmień rozmiar obrazu';

  @override
  String get canvasSizeTitle => 'Rozmiar płótna';

  @override
  String get keepRatio => 'Zachowaj proporcje';

  @override
  String get anchor => 'Zakotwiczenie';

  @override
  String sizeTooLarge(int max) {
    return 'Obraz jest zbyt duży: limit wynosi $max megapikseli.';
  }

  @override
  String get unsavedTitle => 'Zapisać zmiany?';

  @override
  String unsavedMessage(String name) {
    return '„$name” zawiera niezapisane zmiany.';
  }

  @override
  String get flattenTitle => 'Spłaszczyć obraz?';

  @override
  String flattenMessage(String format) {
    return 'Format $format nie obsługuje warstw, więc obraz zostanie spłaszczony do jednej warstwy. Można to cofnąć w oknie „Historia”.';
  }

  @override
  String get flatten => 'Spłaszcz';

  @override
  String get jpegQualityTitle => 'Jakość JPEG';

  @override
  String get quality => 'Jakość';

  @override
  String get largerTitle => 'Obraz jest większy niż płótno';

  @override
  String get largerMessage => 'Powiększyć płótno, aby go zmieścić?';

  @override
  String get reseed => 'Nowe ziarno';

  @override
  String get rendering => 'Renderowanie…';

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
    return 'Otwieranie $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Zapisywanie $name…';
  }

  @override
  String savedTo(String name) {
    return 'Zapisano: $name';
  }

  @override
  String get dropHere => 'Upuść, aby otworzyć';

  @override
  String get dropHint => 'Każdy plik zostanie otwarty jako nowy obraz';

  @override
  String get imagesList => 'Otwarte obrazy';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Edytor obrazów rastrowych z obsługą warstw. Naciśnij literę, aby wybrać narzędzie; ponowne naciśnięcie S, M lub O przełącza między powiązanymi narzędziami. [ i ] zmieniają szerokość pędzla, X zamienia kolory, przytrzymanie spacji przesuwa widok, Ctrl+kółko myszy zmienia powiększenie, a F5–F8 pokazują lub ukrywają okna.';

  @override
  String get settingLineStart => 'Początek';

  @override
  String get settingLineEnd => 'Koniec';

  @override
  String get settingDash => 'Kreskowanie';

  @override
  String get settingSwapSize => 'Zamień szerokość i wysokość';

  @override
  String get settingLineStyle => 'Styl';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Płaski',
      'arrow': 'Strzałka',
      'arrowFilled': 'Wypełniona strzałka',
      'rounded': 'Zaokrąglony',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Ciągła',
      'dash': 'Kreskowa',
      'dashDot': 'Kreska-kropka',
      'dashDotDot': 'Kreska-kropka-kropka',
      'dot': 'Kropkowa',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Czcionka';

  @override
  String get settingFontSize => 'Rozmiar';

  @override
  String get textBold => 'Pogrubienie';

  @override
  String get textItalic => 'Kursywa';

  @override
  String get textUnderline => 'Podkreślenie';

  @override
  String get textStrikeout => 'Przekreślenie';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Do lewej',
      'center': 'Do środka',
      'right': 'Do prawej',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Obrazy';
}
