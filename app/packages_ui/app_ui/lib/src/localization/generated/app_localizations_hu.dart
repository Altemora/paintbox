// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Névtelen $number';
  }

  @override
  String get menuFile => 'Fájl';

  @override
  String get menuEdit => 'Szerkesztés';

  @override
  String get menuView => 'Nézet';

  @override
  String get menuImage => 'Kép';

  @override
  String get menuLayers => 'Rétegek';

  @override
  String get menuAdjustments => 'Korrekciók';

  @override
  String get menuEffects => 'Effektusok';

  @override
  String get menuOpenRecent => 'Legutóbbi fájlok';

  @override
  String get menuRecentEmpty => 'Nincsenek legutóbbi fájlok';

  @override
  String get menuTheme => 'Téma';

  @override
  String get menuSettings => 'Beállítások';

  @override
  String get menuAccent => 'Kiemelőszín';

  @override
  String get menuLanguage => 'Nyelv';

  @override
  String get languageSystem => 'A rendszer alapértelmezése';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Kék',
      'green': 'Zöld',
      'amber': 'Borostyán',
      'purple': 'Lila',
      'red': 'Piros',
      'gray': 'Szürke',
      'custom': 'Egyéni…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Egyéni kiemelőszín';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'A rendszer alapértelmezése';

  @override
  String get themeDark => 'Sötét';

  @override
  String get themeLight => 'Világos';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Új…',
      'open': 'Megnyitás…',
      'close': 'Bezárás',
      'save': 'Mentés',
      'save_as': 'Mentés másként…',
      'exit': 'Kilépés',
      'undo': 'Visszavonás',
      'redo': 'Újra',
      'cut': 'Kivágás',
      'copy': 'Másolás',
      'paste': 'Beillesztés',
      'paste_into_new_layer': 'Beillesztés új rétegként',
      'paste_into_new_image': 'Beillesztés új képként',
      'erase_selection': 'Kijelölés törlése',
      'fill_selection': 'Kijelölés kitöltése',
      'invert_selection': 'Kijelölés megfordítása',
      'select_all': 'Összes kijelölése',
      'deselect': 'Kijelölés megszüntetése',
      'zoom_in': 'Nagyítás',
      'zoom_out': 'Kicsinyítés',
      'zoom_to_window': 'Igazítás az ablakhoz',
      'zoom_to_selection': 'Nagyítás a kijelölésre',
      'actual_size': 'Tényleges méret',
      'pixel_grid': 'Képpontrács',
      'rulers': 'Vonalzók',
      'crop_to_selection': 'Körülvágás a kijelölésre',
      'resize': 'Átméretezés…',
      'canvas_size': 'Vászonméret…',
      'flip_horizontal': 'Vízszintes tükrözés',
      'flip_vertical': 'Függőleges tükrözés',
      'rotate90_cw': 'Forgatás 90°-kal az óramutató járásával megegyezően',
      'rotate90_ccw': 'Forgatás 90°-kal az óramutató járásával ellentétesen',
      'rotate180': 'Forgatás 180°-kal',
      'flatten': 'Egybeolvasztás',
      'add_layer': 'Új réteg hozzáadása',
      'delete_layer': 'Réteg törlése',
      'duplicate_layer': 'Réteg kettőzése',
      'merge_layer_down': 'Egyesítés az alatta lévő réteggel',
      'import_from_file': 'Importálás fájlból…',
      'flip_layer_horizontal': 'Réteg vízszintes tükrözése',
      'flip_layer_vertical': 'Réteg függőleges tükrözése',
      'move_layer_up': 'Réteg feljebb mozgatása',
      'move_layer_down': 'Réteg lejjebb mozgatása',
      'layer_properties': 'Réteg tulajdonságai…',
      'adjust_auto_level': 'Automatikus szintek',
      'adjust_black_and_white': 'Fekete-fehér',
      'adjust_brightness_contrast': 'Fényerő / kontraszt…',
      'adjust_curves': 'Görbék…',
      'adjust_hue_saturation': 'Színárnyalat / telítettség…',
      'adjust_invert_colors': 'Színek invertálása',
      'adjust_levels': 'Szintek…',
      'adjust_posterize': 'Poszterizálás…',
      'adjust_sepia': 'Szépia',
      'repeat_effect': 'Effektus ismétlése',
      'effect_oil_painting': 'Olajfestmény…',
      'effect_gaussian_blur': 'Gauss-elmosás…',
      'effect_motion_blur': 'Mozgási elmosás…',
      'effect_pixelate': 'Pixelizálás…',
      'effect_add_noise': 'Zaj hozzáadása…',
      'effect_median': 'Medián…',
      'effect_sharpen': 'Élesítés…',
      'effect_edge_detect': 'Élkeresés…',
      'effect_emboss': 'Domborítás…',
      'effect_outline': 'Körvonal…',
      'toggle_tools': 'Eszközök',
      'toggle_history': 'Előzmények',
      'toggle_layers': 'Rétegek',
      'toggle_colors': 'Színek',
      'next_image': 'Következő kép',
      'previous_image': 'Előző kép',
      'help': 'Súgó',
      'effect_ink_sketch': 'Tintavázlat…',
      'effect_pencil_sketch': 'Ceruzavázlat…',
      'effect_fragment': 'Töredezés…',
      'effect_radial_blur': 'Sugárirányú elmosás…',
      'effect_surface_blur': 'Felületi elmosás…',
      'effect_unfocus': 'Életlenítés…',
      'effect_zoom_blur': 'Nagyítási elmosás…',
      'effect_bulge': 'Kidudorítás…',
      'effect_dents': 'Horpadások…',
      'effect_frosted_glass': 'Matt üveg…',
      'effect_polar_inversion': 'Poláris inverzió…',
      'effect_tile_reflection': 'Csempetükröződés…',
      'effect_twist': 'Csavarás…',
      'effect_reduce_noise': 'Zajcsökkentés…',
      'effect_glow': 'Ragyogás…',
      'effect_red_eye_removal': 'Vörösszem-eltávolítás…',
      'effect_soften_portrait': 'Portré lágyítása…',
      'effect_clouds': 'Felhők…',
      'effect_julia_fractal': 'Julia-fraktál…',
      'effect_mandelbrot_fractal': 'Mandelbrot-fraktál…',
      'effect_relief': 'Dombormű…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Művészi',
      'blurs': 'Elmosások',
      'distort': 'Torzítás',
      'noise': 'Zaj',
      'photo': 'Fénykép',
      'stylize': 'Stilizálás',
      'render': 'Megjelenítés',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Téglalap kijelölés',
      'move_selected_pixels': 'Kijelölt képpontok mozgatása',
      'lasso_select': 'Lasszó kijelölés',
      'move_selection': 'Kijelölés mozgatása',
      'ellipse_select': 'Ellipszis kijelölés',
      'zoom': 'Nagyító',
      'magic_wand': 'Varázspálca',
      'pan': 'Pásztázás',
      'paint_bucket': 'Festékesvödör',
      'gradient': 'Színátmenet',
      'paintbrush': 'Ecset',
      'eraser': 'Radír',
      'pencil': 'Ceruza',
      'color_picker': 'Színválasztó',
      'clone_stamp': 'Klónozó bélyegző',
      'recolor': 'Átszínezés',
      'text': 'Szöveg',
      'line_curve': 'Vonal / görbe',
      'rectangle': 'Téglalap',
      'rounded_rectangle': 'Lekerekített téglalap',
      'ellipse': 'Ellipszis',
      'freeform_shape': 'Szabadkézi alakzat',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Húzással jelöljön ki egy téglalapot. A Shift lenyomva tartásával négyzetet kap.',
      'move_selected_pixels': 'Húzza a kijelölést az áthelyezéshez. A jobb gombbal húzva elforgathatja, a fogantyúkat húzva átméretezheti. A Ctrl másolatot hagy a helyén, a nyílbillentyűk kis lépésekben tolják el.',
      'lasso_select': 'Húzással rajzolja meg a kijelölés körvonalát.',
      'move_selection': 'Húzza a kijelölés körvonalát az áthelyezéshez. A képpontok a helyükön maradnak.',
      'ellipse_select': 'Húzással jelöljön ki egy ellipszist. A Shift lenyomva tartásával kört kap.',
      'zoom': 'A bal kattintás nagyít, a jobb kattintás kicsinyít, egy keret húzásával pedig a keretezett területre nagyíthat.',
      'magic_wand': 'Kattintson egy színre a körülötte lévő terület kijelöléséhez. A Shift lenyomva tartásával a színt az egész képen kijelöli.',
      'pan': 'Húzással mozgathatja a nézetet.',
      'paint_bucket': 'A bal kattintás az elsődleges színnel tölt ki, a jobb kattintás a másodlagossal.',
      'gradient': 'Húzással rajzoljon színátmenetet. A fogantyúk húzásával módosíthatja, az Enter lenyomásával befejezheti.',
      'paintbrush':
          'A bal gomb az elsődleges színnel fest, a jobb gomb a másodlagossal.',
      'eraser': 'Húzással átlátszóvá törölheti a képpontokat.',
      'pencil': 'Egy képpont széles vonalakat rajzol élsimítás nélkül.',
      'color_picker': 'A bal kattintás az elsődleges színt veszi fel, a jobb kattintás a másodlagosat.',
      'clone_stamp': 'Ctrl+kattintással jelölje ki a forrást, majd húzással fessen belőle.',
      'recolor': 'Ahol fest, ott a másodlagos színt az elsődlegesre cseréli. A Ctrl+kattintás színt vesz fel.',
      'text': 'Kattintson a kurzor elhelyezéséhez, majd gépeljen. A szöveget a fogantyú húzásával vagy jobb gombos húzással mozgathatja, az Esc lenyomásával befejezheti.',
      'line_curve': 'Húzással rajzoljon vonalat. A fogantyúk húzásával meghajlíthatja, az Enter lenyomásával befejezheti.',
      'rectangle': 'Húzással rajzoljon téglalapot. A Shift lenyomva tartásával négyzetet kap.',
      'rounded_rectangle': 'Húzással rajzoljon lekerekített téglalapot. A Shift lenyomva tartásával négyzetet kap.',
      'ellipse': 'Húzással rajzoljon ellipszist. A Shift lenyomva tartásával kört kap.',
      'freeform_shape': 'Húzással rajzoljon zárt szabadkézi alakzatot.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Sugár',
      'angle': 'Szög',
      'distance': 'Távolság',
      'centered': 'Középre igazítva',
      'amount': 'Mérték',
      'intensity': 'Intenzitás',
      'saturation': 'Telítettség',
      'coverage': 'Lefedettség',
      'seed': 'Véletlenmag',
      'percentile': 'Percentilis',
      'cell_size': 'Cellaméret',
      'brush_size': 'Ecsetméret',
      'coarseness': 'Durvaság',
      'thickness': 'Vastagság',
      'brightness': 'Fényerő',
      'contrast': 'Kontraszt',
      'hue': 'Színárnyalat',
      'lightness': 'Világosság',
      'red': 'Vörös',
      'green': 'Zöld',
      'blue': 'Kék',
      'input_low': 'Bemenet minimuma',
      'input_high': 'Bemenet maximuma',
      'output_low': 'Kimenet minimuma',
      'output_high': 'Kimenet maximuma',
      'gamma': 'Gamma',
      'ink_outline': 'Tintakörvonal',
      'coloring': 'Színezés',
      'tip_size': 'Ceruzahegy mérete',
      'color_range': 'Színtartomány',
      'fragments': 'Töredékek',
      'rotation': 'Forgatás',
      'offset_x': 'X eltolás',
      'offset_y': 'Y eltolás',
      'quality': 'Minőség',
      'threshold': 'Küszöb',
      'scale': 'Méretarány',
      'refraction': 'Fénytörés',
      'roughness': 'Érdesség',
      'tension': 'Feszesség',
      'max_scatter': 'Legnagyobb szórás',
      'min_scatter': 'Legkisebb szórás',
      'samples': 'Minták',
      'edge_behavior': 'Szélek kezelése',
      'tile_size': 'Csempeméret',
      'curvature': 'Görbület',
      'size': 'Méret',
      'strength': 'Erősség',
      'tolerance': 'Tűrés',
      'softness': 'Lágyság',
      'lighting': 'Megvilágítás',
      'warmth': 'Melegség',
      'power': 'Hatvány',
      'blend_mode': 'Keverési mód',
      'factor': 'Tényező',
      'zoom': 'Nagyítás',
      'invert_colors': 'Színek invertálása',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normál',
      'multiply': 'Szorzás',
      'additive': 'Összeadás',
      'colorBurn': 'Színégetés',
      'colorDodge': 'Színkikerülés',
      'reflect': 'Tükrözés',
      'glow': 'Izzás',
      'overlay': 'Átfedés',
      'difference': 'Különbség',
      'negation': 'Negálás',
      'lighten': 'Világosítás',
      'darken': 'Sötétítés',
      'screen': 'Szita',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Nincs elég memória a képhez.',
      'invalid_size': 'A kép mérete érvénytelen.',
      'layer_index': 'Nincs ilyen réteg.',
      'last_layer': 'Az utolsó réteg nem törölhető.',
      'no_layer_below': 'Nincs alatta réteg, amellyel egyesíteni lehetne.',
      'edit_in_progress': 'Előbb fejezze be a folyamatban lévő műveletet.',
      'no_edit': 'Nincs befejezendő folyamatban lévő művelet.',
      'no_selection': 'Nincs kijelölés.',
      'nothing_lifted': 'Nincsenek felemelt képpontok.',
      'invalid_parameter': 'Az érték kívül esik a megengedett tartományon.',
      'io': 'A fájlt nem sikerült beolvasni vagy kiírni.',
      'decode': 'A képet nem sikerült beolvasni.',
      'encode': 'A képet nem sikerült kiírni.',
      'open_raster': 'Az OpenRaster-fájl sérült.',
      'palette': 'A palettafájl sérült.',
      'cancelled': 'A számítás megszakadt.',
      'other': 'Hiba történt.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'A fájlt nem sikerült beolvasni vagy kiírni.';

  @override
  String get failureInvalidData => 'Az adatokat nem sikerült beolvasni.';

  @override
  String get failureUnknown => 'Váratlan hiba történt.';

  @override
  String get panelTools => 'Eszközök';

  @override
  String get panelHistory => 'Előzmények';

  @override
  String get panelLayers => 'Rétegek';

  @override
  String get panelColors => 'Színek';

  @override
  String get panelHide => 'Elrejtés';

  @override
  String get colorsPrimary => 'Elsődleges';

  @override
  String get colorsSecondary => 'Másodlagos';

  @override
  String get colorsPrimaryHint => 'Elsődleges szín: ezzel fest a bal egérgomb';

  @override
  String get colorsSecondaryHint =>
      'Másodlagos szín: ezzel fest a jobb egérgomb';

  @override
  String get colorsSwap => 'Színek felcserélése (X)';

  @override
  String get colorsReset => 'Visszaállítás feketére és fehérre';

  @override
  String get colorsMore => 'Több';

  @override
  String get colorsLess => 'Kevesebb';

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
      'A bal kattintás az elsődleges színt állítja be, a jobb kattintás a másodlagosat';

  @override
  String get settingWidth => 'Szélesség';

  @override
  String get settingHardness => 'Keménység';

  @override
  String get settingAntialias => 'Élsimítás';

  @override
  String get settingAlphaBlending => 'Alfa-keverés';

  @override
  String get settingTolerance => 'Tűrés';

  @override
  String get settingFloodMode => 'Kitöltési mód';

  @override
  String get floodLocal => 'Összefüggő';

  @override
  String get floodGlobal => 'Globális';

  @override
  String get settingSelectionMode => 'Kijelölési mód';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Csere',
      'union': 'Egyesítés',
      'exclude': 'Kivonás',
      'xor': 'XOR',
      'intersect': 'Metszet',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Kijelölés mérete';

  @override
  String get drawNormal => 'Normál';

  @override
  String get drawFixedRatio => 'Rögzített arány';

  @override
  String get drawFixedSize => 'Rögzített méret';

  @override
  String get settingResampling => 'Újramintavételezés';

  @override
  String get resamplingNearest => 'Legközelebbi szomszéd';

  @override
  String get resamplingBilinear => 'Bilineáris';

  @override
  String get settingGradient => 'Típus';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineáris',
      'linearReflected': 'Lineáris tükrözött',
      'diamond': 'Rombusz',
      'radial': 'Sugaras',
      'conical': 'Kúpos',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Szín';

  @override
  String get gradientTransparency => 'Átlátszóság';

  @override
  String get settingShape => 'Alakzatstílus';

  @override
  String get shapeOutline => 'Körvonal';

  @override
  String get shapeInterior => 'Kitöltés';

  @override
  String get shapeBoth => 'Körvonal és kitöltés';

  @override
  String get settingAfterPick => 'Színfelvétel után';

  @override
  String get pickStay => 'Maradjon ez az eszköz';

  @override
  String get pickPrevious => 'Váltás az előző eszközre';

  @override
  String get pickPencil => 'Váltás a Ceruzára';

  @override
  String get settingNone => 'Ennek az eszköznek nincsenek beállításai.';

  @override
  String toolUnavailable(String name) {
    return '„$name” még nem érhető el';
  }

  @override
  String get historyFirst => 'Ugrás az első lépésre';

  @override
  String get historyUndo => 'Visszavonás';

  @override
  String get historyRedo => 'Újra';

  @override
  String get historyLast => 'Ugrás az utolsó lépésre';

  @override
  String get historyNewImage => 'Új kép';

  @override
  String get historyOpenImage => 'Kép megnyitása';

  @override
  String get layerVisible => 'Réteg megjelenítése vagy elrejtése';

  @override
  String get layerBackground => 'Háttér';

  @override
  String get layerName => 'Név';

  @override
  String get layerOpacity => 'Átlátszatlanság';

  @override
  String get layerBlendMode => 'Keverési mód';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Mégse';

  @override
  String get save => 'Mentés';

  @override
  String get dontSave => 'Ne mentse';

  @override
  String get keepCanvas => 'Vászon megtartása';

  @override
  String get expandCanvas => 'Vászon bővítése';

  @override
  String get width => 'Szélesség';

  @override
  String get height => 'Magasság';

  @override
  String get pixels => 'képpont';

  @override
  String get newImageTitle => 'Új kép';

  @override
  String get resizeTitle => 'Kép átméretezése';

  @override
  String get canvasSizeTitle => 'Vászonméret';

  @override
  String get keepRatio => 'Méretarány megtartása';

  @override
  String get anchor => 'Horgony';

  @override
  String sizeTooLarge(int max) {
    return 'A kép túl nagy: a felső korlát $max megapixel.';
  }

  @override
  String get unsavedTitle => 'Menti a módosításokat?';

  @override
  String unsavedMessage(String name) {
    return '„$name” nem mentett módosításokat tartalmaz.';
  }

  @override
  String get flattenTitle => 'Egybeolvasztja a képet?';

  @override
  String flattenMessage(String format) {
    return 'A(z) $format formátum nem őrzi meg a rétegeket, ezért a kép egyetlen rétegbe lesz olvasztva. Ezt az Előzmények ablakban visszavonhatja.';
  }

  @override
  String get flatten => 'Egybeolvasztás';

  @override
  String get jpegQualityTitle => 'JPEG-minőség';

  @override
  String get quality => 'Minőség';

  @override
  String get largerTitle => 'A kép nagyobb a vászonnál';

  @override
  String get largerMessage => 'Bővíti a vásznat, hogy a kép elférjen rajta?';

  @override
  String get reseed => 'Új véletlenmag';

  @override
  String get rendering => 'Renderelés…';

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
    return '$name megnyitása…';
  }

  @override
  String statusSaving(String name) {
    return '$name mentése…';
  }

  @override
  String savedTo(String name) {
    return 'Mentve: $name';
  }

  @override
  String get dropHere => 'Engedje el a megnyitáshoz';

  @override
  String get dropHint => 'Minden fájl új képként nyílik meg';

  @override
  String get imagesList => 'Megnyitott képek';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Rétegeket kezelő raszteres képszerkesztő. Egy eszközt a betűjének lenyomásával választhat ki; az S, M vagy O ismételt lenyomása végiglépked a rokon eszközökön. A [ és a ] módosítja az ecset szélességét, az X felcseréli a színeket, a Szóköz lenyomva tartásával a nézet mozgatható, a Ctrl+egérgörgő nagyít, az F5–F8 pedig megjeleníti vagy elrejti az ablakokat.';

  @override
  String get aboutLegal =>
      '© 2026 a Paintbox szerzői. A Paintbox szabad szoftver: a GNU General Public License 3. vagy későbbi változatának feltételei szerint terjeszthető és módosítható. A programhoz semmilyen garancia nem tartozik.';

  @override
  String get licenses => 'Licencek';

  @override
  String get settingLineStart => 'Kezdet';

  @override
  String get settingLineEnd => 'Vég';

  @override
  String get settingDash => 'Szaggatás';

  @override
  String get settingSwapSize => 'Szélesség és magasság felcserélése';

  @override
  String get settingLineStyle => 'Stílus';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Lapos',
      'arrow': 'Nyíl',
      'arrowFilled': 'Kitöltött nyíl',
      'rounded': 'Lekerekített',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Folytonos',
      'dash': 'Szaggatott',
      'dashDot': 'Vonal-pont',
      'dashDotDot': 'Vonal-pont-pont',
      'dot': 'Pontozott',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Betűtípus';

  @override
  String get settingFontSize => 'Méret';

  @override
  String get textBold => 'Félkövér';

  @override
  String get textItalic => 'Dőlt';

  @override
  String get textUnderline => 'Aláhúzott';

  @override
  String get textStrikeout => 'Áthúzott';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Balra',
      'center': 'Középre',
      'right': 'Jobbra',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Képek';
}
