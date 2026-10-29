// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Sin título $number';
  }

  @override
  String get menuFile => 'Archivo';

  @override
  String get menuEdit => 'Edición';

  @override
  String get menuView => 'Ver';

  @override
  String get menuImage => 'Imagen';

  @override
  String get menuLayers => 'Capas';

  @override
  String get menuAdjustments => 'Ajustes';

  @override
  String get menuEffects => 'Efectos';

  @override
  String get menuOpenRecent => 'Abrir recientes';

  @override
  String get menuRecentEmpty => 'No hay archivos recientes';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Configuración';

  @override
  String get menuAccent => 'Color de énfasis';

  @override
  String get menuLanguage => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Azul',
      'green': 'Verde',
      'amber': 'Ámbar',
      'purple': 'Morado',
      'red': 'Rojo',
      'gray': 'Gris',
      'custom': 'Personalizado…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Color de énfasis personalizado';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Predeterminado del sistema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nuevo…',
      'open': 'Abrir…',
      'close': 'Cerrar',
      'save': 'Guardar',
      'save_as': 'Guardar como…',
      'exit': 'Salir',
      'undo': 'Deshacer',
      'redo': 'Rehacer',
      'cut': 'Cortar',
      'copy': 'Copiar',
      'paste': 'Pegar',
      'paste_into_new_layer': 'Pegar en una capa nueva',
      'paste_into_new_image': 'Pegar en una imagen nueva',
      'erase_selection': 'Borrar la selección',
      'fill_selection': 'Rellenar la selección',
      'invert_selection': 'Invertir la selección',
      'select_all': 'Seleccionar todo',
      'deselect': 'Deseleccionar',
      'zoom_in': 'Acercar',
      'zoom_out': 'Alejar',
      'zoom_to_window': 'Ajustar a la ventana',
      'zoom_to_selection': 'Ajustar a la selección',
      'actual_size': 'Tamaño real',
      'pixel_grid': 'Cuadrícula de píxeles',
      'rulers': 'Reglas',
      'crop_to_selection': 'Recortar a la selección',
      'resize': 'Cambiar tamaño de imagen…',
      'canvas_size': 'Tamaño del lienzo…',
      'flip_horizontal': 'Voltear horizontalmente',
      'flip_vertical': 'Voltear verticalmente',
      'rotate90_cw': 'Girar 90° en sentido horario',
      'rotate90_ccw': 'Girar 90° en sentido antihorario',
      'rotate180': 'Girar 180°',
      'flatten': 'Acoplar',
      'add_layer': 'Añadir capa nueva',
      'delete_layer': 'Eliminar capa',
      'duplicate_layer': 'Duplicar capa',
      'merge_layer_down': 'Combinar con la capa inferior',
      'import_from_file': 'Importar desde archivo…',
      'flip_layer_horizontal': 'Voltear capa horizontalmente',
      'flip_layer_vertical': 'Voltear capa verticalmente',
      'move_layer_up': 'Subir capa',
      'move_layer_down': 'Bajar capa',
      'layer_properties': 'Propiedades de capa…',
      'adjust_auto_level': 'Nivel automático',
      'adjust_black_and_white': 'Blanco y negro',
      'adjust_brightness_contrast': 'Brillo / Contraste…',
      'adjust_curves': 'Curvas…',
      'adjust_hue_saturation': 'Tono / Saturación…',
      'adjust_invert_colors': 'Invertir colores',
      'adjust_levels': 'Niveles…',
      'adjust_posterize': 'Posterizar…',
      'adjust_sepia': 'Sepia',
      'repeat_effect': 'Repetir efecto',
      'effect_oil_painting': 'Pintura al óleo…',
      'effect_gaussian_blur': 'Desenfoque gaussiano…',
      'effect_motion_blur': 'Desenfoque de movimiento…',
      'effect_pixelate': 'Pixelado…',
      'effect_add_noise': 'Añadir ruido…',
      'effect_median': 'Mediana…',
      'effect_sharpen': 'Enfocar…',
      'effect_edge_detect': 'Detección de bordes…',
      'effect_emboss': 'Repujado…',
      'effect_outline': 'Contorno…',
      'toggle_tools': 'Herramientas',
      'toggle_history': 'Historial',
      'toggle_layers': 'Capas',
      'toggle_colors': 'Colores',
      'next_image': 'Imagen siguiente',
      'previous_image': 'Imagen anterior',
      'help': 'Ayuda',
      'effect_ink_sketch': 'Boceto en tinta…',
      'effect_pencil_sketch': 'Boceto a lápiz…',
      'effect_fragment': 'Fragmentación…',
      'effect_radial_blur': 'Desenfoque radial…',
      'effect_surface_blur': 'Desenfoque de superficie…',
      'effect_unfocus': 'Desenfocar…',
      'effect_zoom_blur': 'Desenfoque de zoom…',
      'effect_bulge': 'Abultamiento…',
      'effect_dents': 'Abolladuras…',
      'effect_frosted_glass': 'Vidrio esmerilado…',
      'effect_polar_inversion': 'Inversión polar…',
      'effect_tile_reflection': 'Reflejo en mosaico…',
      'effect_twist': 'Torsión…',
      'effect_reduce_noise': 'Reducir ruido…',
      'effect_glow': 'Resplandor…',
      'effect_red_eye_removal': 'Eliminación de ojos rojos…',
      'effect_soften_portrait': 'Suavizar retrato…',
      'effect_clouds': 'Nubes…',
      'effect_julia_fractal': 'Fractal de Julia…',
      'effect_mandelbrot_fractal': 'Fractal de Mandelbrot…',
      'effect_relief': 'Relieve…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artísticos',
      'blurs': 'Desenfoques',
      'distort': 'Distorsionar',
      'noise': 'Ruido',
      'photo': 'Foto',
      'stylize': 'Estilizar',
      'render': 'Renderizar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Selección rectangular',
      'move_selected_pixels': 'Mover píxeles seleccionados',
      'lasso_select': 'Selección con lazo',
      'move_selection': 'Mover selección',
      'ellipse_select': 'Selección elíptica',
      'zoom': 'Zoom',
      'magic_wand': 'Varita mágica',
      'pan': 'Mano',
      'paint_bucket': 'Bote de pintura',
      'gradient': 'Degradado',
      'paintbrush': 'Pincel',
      'eraser': 'Borrador',
      'pencil': 'Lápiz',
      'color_picker': 'Cuentagotas',
      'clone_stamp': 'Tampón de clonar',
      'recolor': 'Recolorear',
      'text': 'Texto',
      'line_curve': 'Línea / curva',
      'rectangle': 'Rectángulo',
      'rounded_rectangle': 'Rectángulo redondeado',
      'ellipse': 'Elipse',
      'freeform_shape': 'Forma libre',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Arrastre para seleccionar un rectángulo. Mantenga pulsada la tecla Shift para obtener un cuadrado.',
      'move_selected_pixels': 'Arrastre la selección para moverla. Arrastre con el botón derecho para girarla o arrastre los tiradores para escalarla. Ctrl deja una copia; las teclas de flecha la desplazan ligeramente.',
      'lasso_select': 'Arrastre para dibujar el contorno de una selección.',
      'move_selection': 'Arrastre el contorno de la selección para moverlo. Los píxeles permanecen en su sitio.',
      'ellipse_select': 'Arrastre para seleccionar una elipse. Mantenga pulsada la tecla Shift para obtener un círculo.',
      'zoom': 'Haga clic con el botón izquierdo para acercar, con el derecho para alejar, o arrastre un recuadro para ampliar esa zona.',
      'magic_wand': 'Haga clic en un color para seleccionar el área que lo rodea. Mantenga pulsada la tecla Shift para seleccionarlo en toda la imagen.',
      'pan': 'Arrastre para mover la vista.',
      'paint_bucket': 'El clic izquierdo rellena con el color primario; el derecho, con el secundario.',
      'gradient': 'Arrastre para dibujar un degradado. Arrastre los tiradores para ajustarlo; pulse Enter para terminar.',
      'paintbrush': 'El botón izquierdo pinta con el color primario; el derecho, con el secundario.',
      'eraser': 'Arrastre para borrar hasta dejar transparencia.',
      'pencil': 'Dibuja líneas de un píxel sin suavizado.',
      'color_picker': 'El clic izquierdo toma el color primario; el derecho, el secundario.',
      'clone_stamp': 'Haga Ctrl+clic para fijar el origen y, después, arrastre para pintar a partir de él.',
      'recolor': 'Sustituye el color secundario por el primario allí donde pinta. Ctrl+clic toma un color.',
      'text': 'Haga clic para colocar el cursor y, después, escriba. Arrastre el tirador o arrastre con el botón derecho para mover el texto; pulse Esc para terminar.',
      'line_curve': 'Arrastre para dibujar una línea. Arrastre los tiradores para curvarla; pulse Enter para terminar.',
      'rectangle': 'Arrastre para dibujar un rectángulo. Mantenga pulsada la tecla Shift para obtener un cuadrado.',
      'rounded_rectangle': 'Arrastre para dibujar un rectángulo redondeado. Mantenga pulsada la tecla Shift para obtener un cuadrado.',
      'ellipse': 'Arrastre para dibujar una elipse. Mantenga pulsada la tecla Shift para obtener un círculo.',
      'freeform_shape': 'Arrastre para dibujar una forma libre cerrada.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Radio',
      'angle': 'Ángulo',
      'distance': 'Distancia',
      'centered': 'Centrado',
      'amount': 'Cantidad',
      'intensity': 'Intensidad',
      'saturation': 'Saturación',
      'coverage': 'Cobertura',
      'seed': 'Semilla',
      'percentile': 'Percentil',
      'cell_size': 'Tamaño de celda',
      'brush_size': 'Tamaño del pincel',
      'coarseness': 'Aspereza',
      'thickness': 'Grosor',
      'brightness': 'Brillo',
      'contrast': 'Contraste',
      'hue': 'Tono',
      'lightness': 'Luminosidad',
      'red': 'Rojo',
      'green': 'Verde',
      'blue': 'Azul',
      'input_low': 'Entrada mínima',
      'input_high': 'Entrada máxima',
      'output_low': 'Salida mínima',
      'output_high': 'Salida máxima',
      'gamma': 'Gamma',
      'ink_outline': 'Contorno de tinta',
      'coloring': 'Coloración',
      'tip_size': 'Tamaño de la punta',
      'color_range': 'Rango de colores',
      'fragments': 'Fragmentos',
      'rotation': 'Rotación',
      'offset_x': 'Desplazamiento X',
      'offset_y': 'Desplazamiento Y',
      'quality': 'Calidad',
      'threshold': 'Umbral',
      'scale': 'Escala',
      'refraction': 'Refracción',
      'roughness': 'Rugosidad',
      'tension': 'Tensión',
      'max_scatter': 'Dispersión máxima',
      'min_scatter': 'Dispersión mínima',
      'samples': 'Muestras',
      'edge_behavior': 'Comportamiento en los bordes',
      'tile_size': 'Tamaño del mosaico',
      'curvature': 'Curvatura',
      'size': 'Tamaño',
      'strength': 'Fuerza',
      'tolerance': 'Tolerancia',
      'softness': 'Suavidad',
      'lighting': 'Iluminación',
      'warmth': 'Calidez',
      'power': 'Potencia',
      'blend_mode': 'Modo de fusión',
      'factor': 'Factor',
      'zoom': 'Zoom',
      'invert_colors': 'Invertir colores',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Multiplicar',
      'additive': 'Aditivo',
      'colorBurn': 'Subexponer color',
      'colorDodge': 'Sobreexponer color',
      'reflect': 'Reflejar',
      'glow': 'Resplandor',
      'overlay': 'Superponer',
      'difference': 'Diferencia',
      'negation': 'Negación',
      'lighten': 'Aclarar',
      'darken': 'Oscurecer',
      'screen': 'Trama',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'No hay suficiente memoria para la imagen.',
      'invalid_size': 'El tamaño de la imagen no es válido.',
      'layer_index': 'Esa capa no existe.',
      'last_layer': 'No se puede eliminar la última capa.',
      'no_layer_below': 'No hay ninguna capa inferior con la que combinar.',
      'edit_in_progress': 'Termine primero la operación en curso.',
      'no_edit': 'No hay ninguna operación en curso que terminar.',
      'no_selection': 'No hay nada seleccionado.',
      'nothing_lifted': 'No hay píxeles levantados.',
      'invalid_parameter': 'El valor está fuera del intervalo permitido.',
      'io': 'No se pudo leer ni escribir el archivo.',
      'decode': 'No se pudo leer la imagen.',
      'encode': 'No se pudo escribir la imagen.',
      'open_raster': 'El archivo OpenRaster está dañado.',
      'palette': 'El archivo de paleta está dañado.',
      'cancelled': 'Se canceló el cálculo.',
      'other': 'Se ha producido un error.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'No se pudo leer ni escribir el archivo.';

  @override
  String get failureInvalidData => 'No se pudieron leer los datos.';

  @override
  String get failureUnknown => 'Se ha producido un error inesperado.';

  @override
  String get panelTools => 'Herramientas';

  @override
  String get panelHistory => 'Historial';

  @override
  String get panelLayers => 'Capas';

  @override
  String get panelColors => 'Colores';

  @override
  String get panelHide => 'Ocultar';

  @override
  String get colorsPrimary => 'Primario';

  @override
  String get colorsSecondary => 'Secundario';

  @override
  String get colorsPrimaryHint =>
      'Color primario: el botón izquierdo del ratón pinta con él';

  @override
  String get colorsSecondaryHint =>
      'Color secundario: el botón derecho del ratón pinta con él';

  @override
  String get colorsSwap => 'Intercambiar colores (X)';

  @override
  String get colorsReset => 'Restablecer a blanco y negro';

  @override
  String get colorsMore => 'Más';

  @override
  String get colorsLess => 'Menos';

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
      'El clic izquierdo establece el color primario; el derecho, el secundario';

  @override
  String get settingWidth => 'Ancho';

  @override
  String get settingHardness => 'Dureza';

  @override
  String get settingAntialias => 'Suavizado';

  @override
  String get settingAlphaBlending => 'Fusión alfa';

  @override
  String get settingTolerance => 'Tolerancia';

  @override
  String get settingFloodMode => 'Modo de relleno';

  @override
  String get floodLocal => 'Contiguo';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Modo de selección';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Reemplazar',
      'union': 'Unir',
      'exclude': 'Excluir',
      'xor': 'Xor',
      'intersect': 'Intersecar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Tamaño de la selección';

  @override
  String get drawNormal => 'Libre';

  @override
  String get drawFixedRatio => 'Proporción fija';

  @override
  String get drawFixedSize => 'Tamaño fijo';

  @override
  String get settingResampling => 'Remuestreo';

  @override
  String get resamplingNearest => 'Vecino más próximo';

  @override
  String get resamplingBilinear => 'Bilineal';

  @override
  String get settingGradient => 'Tipo';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Lineal',
      'linearReflected': 'Lineal reflejado',
      'diamond': 'Rombo',
      'radial': 'Radial',
      'conical': 'Cónico',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Color';

  @override
  String get gradientTransparency => 'Transparencia';

  @override
  String get settingShape => 'Estilo de forma';

  @override
  String get shapeOutline => 'Contorno';

  @override
  String get shapeInterior => 'Relleno';

  @override
  String get shapeBoth => 'Contorno y relleno';

  @override
  String get settingAfterPick => 'Después de tomar el color';

  @override
  String get pickStay => 'Mantener esta herramienta';

  @override
  String get pickPrevious => 'Volver a la herramienta anterior';

  @override
  String get pickPencil => 'Cambiar al Lápiz';

  @override
  String get settingNone => 'Esta herramienta no tiene opciones.';

  @override
  String toolUnavailable(String name) {
    return 'La herramienta «$name» aún no está disponible';
  }

  @override
  String get historyFirst => 'Ir al primer paso';

  @override
  String get historyUndo => 'Deshacer';

  @override
  String get historyRedo => 'Rehacer';

  @override
  String get historyLast => 'Ir al último paso';

  @override
  String get historyNewImage => 'Imagen nueva';

  @override
  String get historyOpenImage => 'Abrir imagen';

  @override
  String get layerVisible => 'Mostrar u ocultar la capa';

  @override
  String get layerBackground => 'Fondo';

  @override
  String get layerName => 'Nombre';

  @override
  String get layerOpacity => 'Opacidad';

  @override
  String get layerBlendMode => 'Modo de fusión';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get dontSave => 'No guardar';

  @override
  String get keepCanvas => 'Mantener el lienzo';

  @override
  String get expandCanvas => 'Ampliar el lienzo';

  @override
  String get width => 'Ancho';

  @override
  String get height => 'Alto';

  @override
  String get pixels => 'píxeles';

  @override
  String get newImageTitle => 'Imagen nueva';

  @override
  String get resizeTitle => 'Cambiar tamaño de imagen';

  @override
  String get canvasSizeTitle => 'Tamaño del lienzo';

  @override
  String get keepRatio => 'Mantener la relación de aspecto';

  @override
  String get anchor => 'Anclaje';

  @override
  String sizeTooLarge(int max) {
    return 'La imagen es demasiado grande: el límite es de $max megapíxeles.';
  }

  @override
  String get unsavedTitle => '¿Guardar los cambios?';

  @override
  String unsavedMessage(String name) {
    return '«$name» tiene cambios sin guardar.';
  }

  @override
  String get flattenTitle => '¿Acoplar la imagen?';

  @override
  String flattenMessage(String format) {
    return 'El formato $format no conserva las capas, por lo que la imagen se acoplará en una sola capa. Puede deshacerlo en la ventana Historial.';
  }

  @override
  String get flatten => 'Acoplar';

  @override
  String get jpegQualityTitle => 'Calidad de JPEG';

  @override
  String get quality => 'Calidad';

  @override
  String get largerTitle => 'La imagen es más grande que el lienzo';

  @override
  String get largerMessage => '¿Ampliar el lienzo para que quepa?';

  @override
  String get reseed => 'Nueva semilla';

  @override
  String get rendering => 'Renderizando…';

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
    return 'Abriendo $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Guardando $name…';
  }

  @override
  String savedTo(String name) {
    return 'Guardado: $name';
  }

  @override
  String get dropHere => 'Suelte para abrir';

  @override
  String get dropHint => 'Cada archivo se abre como una imagen nueva';

  @override
  String get imagesList => 'Imágenes abiertas';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Un editor de imágenes rasterizadas con capas. Pulse una letra para elegir una herramienta; al pulsar de nuevo S, M u O se recorren las herramientas relacionadas. [ y ] cambian el ancho del pincel, X intercambia los colores, mantener pulsada la barra espaciadora desplaza la vista, Ctrl+rueda del ratón cambia el zoom, y F5–F8 muestran u ocultan las ventanas.';

  @override
  String get settingLineStart => 'Inicio';

  @override
  String get settingLineEnd => 'Final';

  @override
  String get settingDash => 'Guiones';

  @override
  String get settingSwapSize => 'Intercambiar ancho y alto';

  @override
  String get settingLineStyle => 'Estilo';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plano',
      'arrow': 'Flecha',
      'arrowFilled': 'Flecha rellena',
      'rounded': 'Redondeado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Continuo',
      'dash': 'Guion',
      'dashDot': 'Guion y punto',
      'dashDotDot': 'Guion y dos puntos',
      'dot': 'Punteado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Fuente';

  @override
  String get settingFontSize => 'Tamaño';

  @override
  String get textBold => 'Negrita';

  @override
  String get textItalic => 'Cursiva';

  @override
  String get textUnderline => 'Subrayado';

  @override
  String get textStrikeout => 'Tachado';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Izquierda',
      'center': 'Centro',
      'right': 'Derecha',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Imágenes';
}
