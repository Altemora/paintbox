// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Adsız $number';
  }

  @override
  String get menuFile => 'Dosya';

  @override
  String get menuEdit => 'Düzen';

  @override
  String get menuView => 'Görünüm';

  @override
  String get menuImage => 'Görüntü';

  @override
  String get menuLayers => 'Katmanlar';

  @override
  String get menuAdjustments => 'Ayarlamalar';

  @override
  String get menuEffects => 'Efektler';

  @override
  String get menuOpenRecent => 'Son Kullanılanlar';

  @override
  String get menuRecentEmpty => 'Son kullanılan dosya yok';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Ayarlar';

  @override
  String get menuAccent => 'Vurgu rengi';

  @override
  String get menuLanguage => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Mavi',
      'green': 'Yeşil',
      'amber': 'Kehribar',
      'purple': 'Mor',
      'red': 'Kırmızı',
      'gray': 'Gri',
      'custom': 'Özel…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Özel vurgu rengi';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Sistem varsayılanı';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeLight => 'Açık';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Yeni…',
      'open': 'Aç…',
      'close': 'Kapat',
      'save': 'Kaydet',
      'save_as': 'Farklı Kaydet…',
      'exit': 'Çıkış',
      'undo': 'Geri Al',
      'redo': 'Yinele',
      'cut': 'Kes',
      'copy': 'Kopyala',
      'paste': 'Yapıştır',
      'paste_into_new_layer': 'Yeni Katmana Yapıştır',
      'paste_into_new_image': 'Yeni Görüntüye Yapıştır',
      'erase_selection': 'Seçimi Sil',
      'fill_selection': 'Seçimi Doldur',
      'invert_selection': 'Seçimi Ters Çevir',
      'select_all': 'Tümünü Seç',
      'deselect': 'Seçimi Kaldır',
      'zoom_in': 'Yakınlaştır',
      'zoom_out': 'Uzaklaştır',
      'zoom_to_window': 'Pencereye Sığdır',
      'zoom_to_selection': 'Seçime Sığdır',
      'actual_size': 'Gerçek Boyut',
      'pixel_grid': 'Piksel Izgarası',
      'rulers': 'Cetveller',
      'crop_to_selection': 'Seçime Kırp',
      'resize': 'Yeniden Boyutlandır…',
      'canvas_size': 'Tuval Boyutu…',
      'flip_horizontal': 'Yatay Çevir',
      'flip_vertical': 'Dikey Çevir',
      'rotate90_cw': 'Saat Yönünde 90° Döndür',
      'rotate90_ccw': 'Saat Yönünün Tersine 90° Döndür',
      'rotate180': '180° Döndür',
      'flatten': 'Düzleştir',
      'add_layer': 'Yeni Katman Ekle',
      'delete_layer': 'Katmanı Sil',
      'duplicate_layer': 'Katmanı Çoğalt',
      'merge_layer_down': 'Alttaki Katmanla Birleştir',
      'import_from_file': 'Dosyadan İçe Aktar…',
      'flip_layer_horizontal': 'Katmanı Yatay Çevir',
      'flip_layer_vertical': 'Katmanı Dikey Çevir',
      'move_layer_up': 'Katmanı Yukarı Taşı',
      'move_layer_down': 'Katmanı Aşağı Taşı',
      'layer_properties': 'Katman Özellikleri…',
      'adjust_auto_level': 'Otomatik Düzey',
      'adjust_black_and_white': 'Siyah Beyaz',
      'adjust_brightness_contrast': 'Parlaklık / Kontrast…',
      'adjust_curves': 'Eğriler…',
      'adjust_hue_saturation': 'Ton / Doygunluk…',
      'adjust_invert_colors': 'Renkleri Ters Çevir',
      'adjust_levels': 'Düzeyler…',
      'adjust_posterize': 'Posterleştir…',
      'adjust_sepia': 'Sepya',
      'repeat_effect': 'Efekti Yinele',
      'effect_oil_painting': 'Yağlı Boya…',
      'effect_gaussian_blur': 'Gauss Bulanıklığı…',
      'effect_motion_blur': 'Hareket Bulanıklığı…',
      'effect_pixelate': 'Pikselleştir…',
      'effect_add_noise': 'Gürültü Ekle…',
      'effect_median': 'Medyan…',
      'effect_sharpen': 'Keskinleştir…',
      'effect_edge_detect': 'Kenar Algılama…',
      'effect_emboss': 'Kabartma…',
      'effect_outline': 'Anahat…',
      'toggle_tools': 'Araçlar',
      'toggle_history': 'Geçmiş',
      'toggle_layers': 'Katmanlar',
      'toggle_colors': 'Renkler',
      'next_image': 'Sonraki Görüntü',
      'previous_image': 'Önceki Görüntü',
      'help': 'Yardım',
      'effect_ink_sketch': 'Mürekkep Eskiz…',
      'effect_pencil_sketch': 'Kalem Eskiz…',
      'effect_fragment': 'Parçalama…',
      'effect_radial_blur': 'Radyal Bulanıklık…',
      'effect_surface_blur': 'Yüzey Bulanıklığı…',
      'effect_unfocus': 'Odak Dışı…',
      'effect_zoom_blur': 'Yakınlaştırma Bulanıklığı…',
      'effect_bulge': 'Şişirme…',
      'effect_dents': 'Göçükler…',
      'effect_frosted_glass': 'Buzlu Cam…',
      'effect_polar_inversion': 'Kutupsal Ters Çevirme…',
      'effect_tile_reflection': 'Karo Yansıması…',
      'effect_twist': 'Burgu…',
      'effect_reduce_noise': 'Gürültüyü Azalt…',
      'effect_glow': 'Parlama…',
      'effect_red_eye_removal': 'Kırmızı Göz Giderme…',
      'effect_soften_portrait': 'Portre Yumuşatma…',
      'effect_clouds': 'Bulutlar…',
      'effect_julia_fractal': 'Julia Fraktalı…',
      'effect_mandelbrot_fractal': 'Mandelbrot Fraktalı…',
      'effect_relief': 'Rölyef…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Sanatsal',
      'blurs': 'Bulanıklaştırma',
      'distort': 'Bozulma',
      'noise': 'Gürültü',
      'photo': 'Fotoğraf',
      'stylize': 'Stilize',
      'render': 'Oluşturma',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Dikdörtgen Seçim',
      'move_selected_pixels': 'Seçili Pikselleri Taşı',
      'lasso_select': 'Kement Seçim',
      'move_selection': 'Seçimi Taşı',
      'ellipse_select': 'Elips Seçim',
      'zoom': 'Yakınlaştırma',
      'magic_wand': 'Sihirli Değnek',
      'pan': 'Kaydırma',
      'paint_bucket': 'Boya Kovası',
      'gradient': 'Renk Geçişi',
      'paintbrush': 'Fırça',
      'eraser': 'Silgi',
      'pencil': 'Kalem',
      'color_picker': 'Renk Seçici',
      'clone_stamp': 'Klon Damgası',
      'recolor': 'Yeniden Renklendir',
      'text': 'Metin',
      'line_curve': 'Çizgi / Eğri',
      'rectangle': 'Dikdörtgen',
      'rounded_rectangle': 'Yuvarlatılmış Dikdörtgen',
      'ellipse': 'Elips',
      'freeform_shape': 'Serbest Şekil',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Dikdörtgen seçmek için sürükleyin. Kare için Shift tuşunu basılı tutun.',
      'move_selected_pixels': 'Seçimi taşımak için sürükleyin. Döndürmek için sağ düğmeyle sürükleyin, ölçeklemek için tutamaçları sürükleyin. Ctrl bir kopya bırakır; ok tuşları seçimi küçük adımlarla kaydırır.',
      'lasso_select': 'Seçimin dış hattını çizmek için sürükleyin.',
      'move_selection': 'Seçimin dış hattını taşımak için sürükleyin. Pikseller yerinde kalır.',
      'ellipse_select':
          'Elips seçmek için sürükleyin. Daire için Shift tuşunu basılı tutun.',
      'zoom': 'Sol tıklama yakınlaştırır, sağ tıklama uzaklaştırır; bir çerçeve sürüklerseniz o alana yakınlaştırılır.',
      'magic_wand': 'Çevresindeki alanı seçmek için bir renge tıklayın. Bu rengi tüm görüntüde seçmek için Shift tuşunu basılı tutun.',
      'pan': 'Görünümü kaydırmak için sürükleyin.',
      'paint_bucket':
          'Sol tıklama birincil renkle, sağ tıklama ikincil renkle doldurur.',
      'gradient': 'Renk geçişi çizmek için sürükleyin. Ayarlamak için tutamaçları sürükleyin; bitirmek için Enter tuşuna basın.',
      'paintbrush':
          'Sol düğme birincil renkle, sağ düğme ikincil renkle boyar.',
      'eraser': 'Pikselleri saydamlaştırarak silmek için sürükleyin.',
      'pencil':
          'Kenar yumuşatma olmadan bir piksel kalınlığında çizgiler çizer.',
      'color_picker':
          'Sol tıklama birincil rengi, sağ tıklama ikincil rengi alır.',
      'clone_stamp': 'Kaynağı belirlemek için Ctrl+tıklayın, ardından kaynaktan boyamak için sürükleyin.',
      'recolor': 'Boyadığınız yerlerde ikincil rengi birincil renkle değiştirir. Ctrl+tıklama bir renk alır.',
      'text': 'İmleci yerleştirmek için tıklayın, ardından yazın. Metni taşımak için tutamacı sürükleyin veya sağ düğmeyle sürükleyin; bitirmek için Esc tuşuna basın.',
      'line_curve': 'Çizgi çizmek için sürükleyin. Bükmek için tutamaçları sürükleyin; bitirmek için Enter tuşuna basın.',
      'rectangle': 'Dikdörtgen çizmek için sürükleyin. Kare için Shift tuşunu basılı tutun.',
      'rounded_rectangle': 'Yuvarlatılmış dikdörtgen çizmek için sürükleyin. Kare için Shift tuşunu basılı tutun.',
      'ellipse':
          'Elips çizmek için sürükleyin. Daire için Shift tuşunu basılı tutun.',
      'freeform_shape': 'Kapalı bir serbest şekil çizmek için sürükleyin.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Yarıçap',
      'angle': 'Açı',
      'distance': 'Uzaklık',
      'centered': 'Ortalanmış',
      'amount': 'Miktar',
      'intensity': 'Yoğunluk',
      'saturation': 'Doygunluk',
      'coverage': 'Kapsama',
      'seed': 'Tohum',
      'percentile': 'Yüzdebirlik',
      'cell_size': 'Hücre Boyutu',
      'brush_size': 'Fırça Boyutu',
      'coarseness': 'Kabalık',
      'thickness': 'Kalınlık',
      'brightness': 'Parlaklık',
      'contrast': 'Kontrast',
      'hue': 'Ton',
      'lightness': 'Açıklık',
      'red': 'Kırmızı',
      'green': 'Yeşil',
      'blue': 'Mavi',
      'input_low': 'En Düşük Giriş',
      'input_high': 'En Yüksek Giriş',
      'output_low': 'En Düşük Çıkış',
      'output_high': 'En Yüksek Çıkış',
      'gamma': 'Gama',
      'ink_outline': 'Mürekkep Anahattı',
      'coloring': 'Renklendirme',
      'tip_size': 'Kalem Ucu Boyutu',
      'color_range': 'Renk Aralığı',
      'fragments': 'Parçalar',
      'rotation': 'Döndürme',
      'offset_x': 'X Kayması',
      'offset_y': 'Y Kayması',
      'quality': 'Kalite',
      'threshold': 'Eşik',
      'scale': 'Ölçek',
      'refraction': 'Kırılma',
      'roughness': 'Pürüzlülük',
      'tension': 'Gerilim',
      'max_scatter': 'En Büyük Saçılma',
      'min_scatter': 'En Küçük Saçılma',
      'samples': 'Örnekler',
      'edge_behavior': 'Kenar Davranışı',
      'tile_size': 'Karo Boyutu',
      'curvature': 'Eğrilik',
      'size': 'Boyut',
      'strength': 'Şiddet',
      'tolerance': 'Tolerans',
      'softness': 'Yumuşaklık',
      'lighting': 'Aydınlatma',
      'warmth': 'Sıcaklık',
      'power': 'Üs',
      'blend_mode': 'Karışım Modu',
      'factor': 'Çarpan',
      'zoom': 'Yakınlaştırma',
      'invert_colors': 'Renkleri Ters Çevir',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Çarp',
      'additive': 'Ekle',
      'colorBurn': 'Renk Yanması',
      'colorDodge': 'Renk Soldurma',
      'reflect': 'Yansıt',
      'glow': 'Parlama',
      'overlay': 'Bindirme',
      'difference': 'Fark',
      'negation': 'Olumsuzlama',
      'lighten': 'Aydınlat',
      'darken': 'Koyulaştır',
      'screen': 'Ekran',
      'xor': 'XOR',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Görüntü için yeterli bellek yok.',
      'invalid_size': 'Görüntü boyutu geçerli değil.',
      'layer_index': 'Böyle bir katman yok.',
      'last_layer': 'Son katman silinemez.',
      'no_layer_below': 'Altta birleştirilecek bir katman yok.',
      'edit_in_progress': 'Önce devam eden işlemi bitirin.',
      'no_edit': 'Bitirilecek devam eden bir işlem yok.',
      'no_selection': 'Hiçbir şey seçili değil.',
      'nothing_lifted': 'Kaldırılmış piksel yok.',
      'invalid_parameter': 'Değer izin verilen aralığın dışında.',
      'io': 'Dosya okunamadı veya yazılamadı.',
      'decode': 'Görüntü okunamadı.',
      'encode': 'Görüntü yazılamadı.',
      'open_raster': 'OpenRaster dosyası bozuk.',
      'palette': 'Palet dosyası bozuk.',
      'cancelled': 'Hesaplama iptal edildi.',
      'other': 'Bir hata oluştu.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Dosya okunamadı veya yazılamadı.';

  @override
  String get failureInvalidData => 'Veriler okunamadı.';

  @override
  String get failureUnknown => 'Beklenmeyen bir hata oluştu.';

  @override
  String get panelTools => 'Araçlar';

  @override
  String get panelHistory => 'Geçmiş';

  @override
  String get panelLayers => 'Katmanlar';

  @override
  String get panelColors => 'Renkler';

  @override
  String get panelHide => 'Gizle';

  @override
  String get colorsPrimary => 'Birincil';

  @override
  String get colorsSecondary => 'İkincil';

  @override
  String get colorsPrimaryHint =>
      'Birincil renk: sol fare düğmesi bu renkle boyar';

  @override
  String get colorsSecondaryHint =>
      'İkincil renk: sağ fare düğmesi bu renkle boyar';

  @override
  String get colorsSwap => 'Renklerin yerini değiştir (X)';

  @override
  String get colorsReset => 'Siyah ve beyaza sıfırla';

  @override
  String get colorsMore => 'Daha fazla';

  @override
  String get colorsLess => 'Daha az';

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
      'Sol tıklama birincil rengi, sağ tıklama ikincil rengi ayarlar';

  @override
  String get settingWidth => 'Genişlik';

  @override
  String get settingHardness => 'Sertlik';

  @override
  String get settingAntialias => 'Kenar yumuşatma';

  @override
  String get settingAlphaBlending => 'Alfa karıştırma';

  @override
  String get settingTolerance => 'Tolerans';

  @override
  String get settingFloodMode => 'Doldurma modu';

  @override
  String get floodLocal => 'Bitişik';

  @override
  String get floodGlobal => 'Genel';

  @override
  String get settingSelectionMode => 'Seçim modu';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Değiştirme',
      'union': 'Birleşim',
      'exclude': 'Dışlama',
      'xor': 'XOR',
      'intersect': 'Kesişim',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Seçim boyutu';

  @override
  String get drawNormal => 'Normal';

  @override
  String get drawFixedRatio => 'Sabit Oran';

  @override
  String get drawFixedSize => 'Sabit Boyut';

  @override
  String get settingResampling => 'Yeniden örnekleme';

  @override
  String get resamplingNearest => 'En yakın komşu';

  @override
  String get resamplingBilinear => 'Çift doğrusal';

  @override
  String get settingGradient => 'Tür';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Doğrusal',
      'linearReflected': 'Doğrusal Yansımalı',
      'diamond': 'Elmas',
      'radial': 'Radyal',
      'conical': 'Konik',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Renk';

  @override
  String get gradientTransparency => 'Saydamlık';

  @override
  String get settingShape => 'Şekil stili';

  @override
  String get shapeOutline => 'Anahat';

  @override
  String get shapeInterior => 'Dolgu';

  @override
  String get shapeBoth => 'Anahat ve dolgu';

  @override
  String get settingAfterPick => 'Renk aldıktan sonra';

  @override
  String get pickStay => 'Bu araçta kal';

  @override
  String get pickPrevious => 'Önceki araca geç';

  @override
  String get pickPencil => 'Kaleme geç';

  @override
  String get settingNone => 'Bu aracın ayarı yok.';

  @override
  String toolUnavailable(String name) {
    return '“$name” henüz kullanılamıyor';
  }

  @override
  String get historyFirst => 'İlk adıma git';

  @override
  String get historyUndo => 'Geri al';

  @override
  String get historyRedo => 'Yinele';

  @override
  String get historyLast => 'Son adıma git';

  @override
  String get historyNewImage => 'Yeni Görüntü';

  @override
  String get historyOpenImage => 'Görüntü Açma';

  @override
  String get layerVisible => 'Katmanı göster veya gizle';

  @override
  String get layerBackground => 'Arka plan';

  @override
  String get layerName => 'Ad';

  @override
  String get layerOpacity => 'Opaklık';

  @override
  String get layerBlendMode => 'Karışım modu';

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get dontSave => 'Kaydetme';

  @override
  String get keepCanvas => 'Tuvali koru';

  @override
  String get expandCanvas => 'Tuvali genişlet';

  @override
  String get width => 'Genişlik';

  @override
  String get height => 'Yükseklik';

  @override
  String get pixels => 'piksel';

  @override
  String get newImageTitle => 'Yeni Görüntü';

  @override
  String get resizeTitle => 'Görüntüyü Yeniden Boyutlandır';

  @override
  String get canvasSizeTitle => 'Tuval Boyutu';

  @override
  String get keepRatio => 'En-boy oranını koru';

  @override
  String get anchor => 'Bağlantı noktası';

  @override
  String sizeTooLarge(int max) {
    return 'Görüntü çok büyük: üst sınır $max megapiksel.';
  }

  @override
  String get unsavedTitle => 'Değişiklikler kaydedilsin mi?';

  @override
  String unsavedMessage(String name) {
    return '“$name” kaydedilmemiş değişiklikler içeriyor.';
  }

  @override
  String get flattenTitle => 'Görüntü düzleştirilsin mi?';

  @override
  String flattenMessage(String format) {
    return '$format biçimi katmanları korumaz, bu nedenle görüntü tek bir katmana düzleştirilecek. Bu işlemi Geçmiş penceresinden geri alabilirsiniz.';
  }

  @override
  String get flatten => 'Düzleştir';

  @override
  String get jpegQualityTitle => 'JPEG Kalitesi';

  @override
  String get quality => 'Kalite';

  @override
  String get largerTitle => 'Görüntü tuvalden büyük';

  @override
  String get largerMessage =>
      'Görüntüyü sığdırmak için tuval genişletilsin mi?';

  @override
  String get reseed => 'Yeni tohum';

  @override
  String get rendering => 'Oluşturuluyor…';

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
    return '%$percent';
  }

  @override
  String statusOpening(String name) {
    return '$name açılıyor…';
  }

  @override
  String statusSaving(String name) {
    return '$name kaydediliyor…';
  }

  @override
  String savedTo(String name) {
    return 'Kaydedildi: $name';
  }

  @override
  String get dropHere => 'Açmak için bırakın';

  @override
  String get dropHint => 'Her dosya yeni bir görüntü olarak açılır';

  @override
  String get imagesList => 'Açık görüntüler';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Katman destekli bir raster görüntü düzenleyicisi. Bir aracı seçmek için harfine basın; S, M veya O tuşuna yeniden basıldığında ilgili araçlar arasında geçiş yapılır. [ ve ] fırça genişliğini değiştirir, X renklerin yerini değiştirir, Boşluk tuşunu basılı tutmak görünümü kaydırır, Ctrl+fare tekerleği yakınlaştırır ve F5–F8 pencereleri gösterir ya da gizler.';

  @override
  String get aboutLegal =>
      '© 2026 Paintbox yazarları. Paintbox özgür bir yazılımdır: GNU General Public License sürüm 3 veya sonrası koşulları altında dağıtabilir ve değiştirebilirsiniz. Program hiçbir garanti olmaksızın sunulur.';

  @override
  String get licenses => 'Lisanslar';

  @override
  String get settingLineStart => 'Başlangıç';

  @override
  String get settingLineEnd => 'Bitiş';

  @override
  String get settingDash => 'Kesik çizgi';

  @override
  String get settingSwapSize => 'Genişlik ile yüksekliği değiştir';

  @override
  String get settingLineStyle => 'Stil';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Düz',
      'arrow': 'Ok',
      'arrowFilled': 'Dolu ok',
      'rounded': 'Yuvarlak',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Kesintisiz',
      'dash': 'Kesik',
      'dashDot': 'Kesik nokta',
      'dashDotDot': 'Kesik nokta nokta',
      'dot': 'Noktalı',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Yazı tipi';

  @override
  String get settingFontSize => 'Boyut';

  @override
  String get textBold => 'Kalın';

  @override
  String get textItalic => 'İtalik';

  @override
  String get textUnderline => 'Altı çizili';

  @override
  String get textStrikeout => 'Üstü çizili';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Sol',
      'center': 'Orta',
      'right': 'Sağ',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Görüntüler';
}
