// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Sem título $number';
  }

  @override
  String get menuFile => 'Ficheiro';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuView => 'Ver';

  @override
  String get menuImage => 'Imagem';

  @override
  String get menuLayers => 'Camadas';

  @override
  String get menuAdjustments => 'Ajustes';

  @override
  String get menuEffects => 'Efeitos';

  @override
  String get menuOpenRecent => 'Abrir recentes';

  @override
  String get menuRecentEmpty => 'Sem ficheiros recentes';

  @override
  String get menuTheme => 'Tema';

  @override
  String get menuSettings => 'Definições';

  @override
  String get menuAccent => 'Cor de destaque';

  @override
  String get menuLanguage => 'Idioma';

  @override
  String get languageSystem => 'Predefinição do sistema';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Azul',
      'green': 'Verde',
      'amber': 'Âmbar',
      'purple': 'Roxo',
      'red': 'Vermelho',
      'gray': 'Cinzento',
      'custom': 'Personalizada…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Cor de destaque personalizada';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Predefinição do sistema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeLight => 'Claro';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Novo…',
      'open': 'Abrir…',
      'close': 'Fechar',
      'save': 'Guardar',
      'save_as': 'Guardar como…',
      'exit': 'Sair',
      'undo': 'Anular',
      'redo': 'Refazer',
      'cut': 'Cortar',
      'copy': 'Copiar',
      'paste': 'Colar',
      'paste_into_new_layer': 'Colar numa nova camada',
      'paste_into_new_image': 'Colar numa nova imagem',
      'erase_selection': 'Apagar seleção',
      'fill_selection': 'Preencher seleção',
      'invert_selection': 'Inverter seleção',
      'select_all': 'Selecionar tudo',
      'deselect': 'Desmarcar seleção',
      'zoom_in': 'Ampliar',
      'zoom_out': 'Reduzir',
      'zoom_to_window': 'Ajustar à janela',
      'zoom_to_selection': 'Ajustar à seleção',
      'actual_size': 'Tamanho real',
      'pixel_grid': 'Grelha de píxeis',
      'rulers': 'Réguas',
      'crop_to_selection': 'Recortar para a seleção',
      'resize': 'Redimensionar imagem…',
      'canvas_size': 'Tamanho da tela…',
      'flip_horizontal': 'Inverter horizontalmente',
      'flip_vertical': 'Inverter verticalmente',
      'rotate90_cw': 'Rodar 90° no sentido horário',
      'rotate90_ccw': 'Rodar 90° no sentido anti-horário',
      'rotate180': 'Rodar 180°',
      'flatten': 'Achatar',
      'add_layer': 'Adicionar nova camada',
      'delete_layer': 'Eliminar camada',
      'duplicate_layer': 'Duplicar camada',
      'merge_layer_down': 'Unir com a camada inferior',
      'import_from_file': 'Importar de ficheiro…',
      'flip_layer_horizontal': 'Inverter camada horizontalmente',
      'flip_layer_vertical': 'Inverter camada verticalmente',
      'move_layer_up': 'Mover camada para cima',
      'move_layer_down': 'Mover camada para baixo',
      'layer_properties': 'Propriedades da camada…',
      'adjust_auto_level': 'Níveis automáticos',
      'adjust_black_and_white': 'Preto e branco',
      'adjust_brightness_contrast': 'Brilho / Contraste…',
      'adjust_curves': 'Curvas…',
      'adjust_hue_saturation': 'Matiz / Saturação…',
      'adjust_invert_colors': 'Inverter cores',
      'adjust_levels': 'Níveis…',
      'adjust_posterize': 'Posterizar…',
      'adjust_sepia': 'Sépia',
      'repeat_effect': 'Repetir efeito',
      'effect_oil_painting': 'Pintura a óleo…',
      'effect_gaussian_blur': 'Desfocagem gaussiana…',
      'effect_motion_blur': 'Desfocagem de movimento…',
      'effect_pixelate': 'Pixelizar…',
      'effect_add_noise': 'Adicionar ruído…',
      'effect_median': 'Mediana…',
      'effect_sharpen': 'Nitidez…',
      'effect_edge_detect': 'Deteção de contornos…',
      'effect_emboss': 'Gravação em relevo…',
      'effect_outline': 'Contorno…',
      'toggle_tools': 'Ferramentas',
      'toggle_history': 'Histórico',
      'toggle_layers': 'Camadas',
      'toggle_colors': 'Cores',
      'next_image': 'Imagem seguinte',
      'previous_image': 'Imagem anterior',
      'help': 'Ajuda',
      'effect_ink_sketch': 'Esboço a tinta…',
      'effect_pencil_sketch': 'Esboço a lápis…',
      'effect_fragment': 'Fragmentação…',
      'effect_radial_blur': 'Desfocagem radial…',
      'effect_surface_blur': 'Desfocagem de superfície…',
      'effect_unfocus': 'Desfocar…',
      'effect_zoom_blur': 'Desfocagem de zoom…',
      'effect_bulge': 'Protuberância…',
      'effect_dents': 'Amolgadelas…',
      'effect_frosted_glass': 'Vidro fosco…',
      'effect_polar_inversion': 'Inversão polar…',
      'effect_tile_reflection': 'Reflexo em mosaico…',
      'effect_twist': 'Torção…',
      'effect_reduce_noise': 'Reduzir ruído…',
      'effect_glow': 'Resplendor…',
      'effect_red_eye_removal': 'Remoção de olhos vermelhos…',
      'effect_soften_portrait': 'Suavizar retrato…',
      'effect_clouds': 'Nuvens…',
      'effect_julia_fractal': 'Fractal de Julia…',
      'effect_mandelbrot_fractal': 'Fractal de Mandelbrot…',
      'effect_relief': 'Relevo…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artísticos',
      'blurs': 'Desfocagens',
      'distort': 'Distorcer',
      'noise': 'Ruído',
      'photo': 'Fotografia',
      'stylize': 'Estilizar',
      'render': 'Renderizar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Seleção retangular',
      'move_selected_pixels': 'Mover píxeis selecionados',
      'lasso_select': 'Seleção laço',
      'move_selection': 'Mover seleção',
      'ellipse_select': 'Seleção elíptica',
      'zoom': 'Zoom',
      'magic_wand': 'Varinha mágica',
      'pan': 'Mão',
      'paint_bucket': 'Balde de tinta',
      'gradient': 'Gradiente',
      'paintbrush': 'Pincel',
      'eraser': 'Borracha',
      'pencil': 'Lápis',
      'color_picker': 'Conta-gotas',
      'clone_stamp': 'Carimbo de clonagem',
      'recolor': 'Recolorir',
      'text': 'Texto',
      'line_curve': 'Linha / curva',
      'rectangle': 'Retângulo',
      'rounded_rectangle': 'Retângulo arredondado',
      'ellipse': 'Elipse',
      'freeform_shape': 'Forma livre',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Arraste para selecionar um retângulo. Mantenha a tecla Shift premida para obter um quadrado.',
      'move_selected_pixels': 'Arraste a seleção para a mover. Arraste com o botão direito para a rodar ou arraste as pegas para a redimensionar. Ctrl deixa uma cópia; as teclas de seta deslocam-na ligeiramente.',
      'lasso_select': 'Arraste para desenhar o contorno de uma seleção.',
      'move_selection': 'Arraste o contorno da seleção para o mover. Os píxeis permanecem no lugar.',
      'ellipse_select': 'Arraste para selecionar uma elipse. Mantenha a tecla Shift premida para obter um círculo.',
      'zoom': 'Clique com o botão esquerdo para ampliar, com o direito para reduzir, ou arraste um retângulo para ampliar essa área.',
      'magic_wand': 'Clique numa cor para selecionar a área à sua volta. Mantenha a tecla Shift premida para a selecionar em toda a imagem.',
      'pan': 'Arraste para mover a vista.',
      'paint_bucket': 'O clique esquerdo preenche com a cor primária; o direito, com a secundária.',
      'gradient': 'Arraste para desenhar um gradiente. Arraste as pegas para o ajustar; prima Enter para terminar.',
      'paintbrush': 'O botão esquerdo pinta com a cor primária; o direito, com a secundária.',
      'eraser': 'Arraste para apagar até à transparência.',
      'pencil': 'Desenha linhas de um píxel sem suavização.',
      'color_picker':
          'O clique esquerdo recolhe a cor primária; o direito, a secundária.',
      'clone_stamp': 'Faça Ctrl+clique para definir a origem e, depois, arraste para pintar a partir dela.',
      'recolor': 'Substitui a cor secundária pela primária onde pintar. Ctrl+clique recolhe uma cor.',
      'text': 'Clique para colocar o cursor e, depois, escreva. Arraste a pega ou arraste com o botão direito para mover o texto; prima Esc para terminar.',
      'line_curve': 'Arraste para desenhar uma linha. Arraste as pegas para a curvar; prima Enter para terminar.',
      'rectangle': 'Arraste para desenhar um retângulo. Mantenha a tecla Shift premida para obter um quadrado.',
      'rounded_rectangle': 'Arraste para desenhar um retângulo arredondado. Mantenha a tecla Shift premida para obter um quadrado.',
      'ellipse': 'Arraste para desenhar uma elipse. Mantenha a tecla Shift premida para obter um círculo.',
      'freeform_shape': 'Arraste para desenhar uma forma livre fechada.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Raio',
      'angle': 'Ângulo',
      'distance': 'Distância',
      'centered': 'Centrado',
      'amount': 'Quantidade',
      'intensity': 'Intensidade',
      'saturation': 'Saturação',
      'coverage': 'Cobertura',
      'seed': 'Semente',
      'percentile': 'Percentil',
      'cell_size': 'Tamanho da célula',
      'brush_size': 'Tamanho do pincel',
      'coarseness': 'Aspereza',
      'thickness': 'Espessura',
      'brightness': 'Brilho',
      'contrast': 'Contraste',
      'hue': 'Matiz',
      'lightness': 'Luminosidade',
      'red': 'Vermelho',
      'green': 'Verde',
      'blue': 'Azul',
      'input_low': 'Entrada mínima',
      'input_high': 'Entrada máxima',
      'output_low': 'Saída mínima',
      'output_high': 'Saída máxima',
      'gamma': 'Gama',
      'ink_outline': 'Contorno a tinta',
      'coloring': 'Coloração',
      'tip_size': 'Tamanho da ponta do lápis',
      'color_range': 'Intervalo de cores',
      'fragments': 'Fragmentos',
      'rotation': 'Rotação',
      'offset_x': 'Deslocamento X',
      'offset_y': 'Deslocamento Y',
      'quality': 'Qualidade',
      'threshold': 'Limiar',
      'scale': 'Escala',
      'refraction': 'Refração',
      'roughness': 'Rugosidade',
      'tension': 'Tensão',
      'max_scatter': 'Dispersão máxima',
      'min_scatter': 'Dispersão mínima',
      'samples': 'Amostras',
      'edge_behavior': 'Comportamento nas margens',
      'tile_size': 'Tamanho do mosaico',
      'curvature': 'Curvatura',
      'size': 'Tamanho',
      'strength': 'Força',
      'tolerance': 'Tolerância',
      'softness': 'Suavidade',
      'lighting': 'Iluminação',
      'warmth': 'Calor',
      'power': 'Potência',
      'blend_mode': 'Modo de mistura',
      'factor': 'Fator',
      'zoom': 'Zoom',
      'invert_colors': 'Inverter cores',
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
      'colorBurn': 'Sobre-exposição de cor',
      'colorDodge': 'Subexposição de cor',
      'reflect': 'Reflexo',
      'glow': 'Resplendor',
      'overlay': 'Sobrepor',
      'difference': 'Diferença',
      'negation': 'Negação',
      'lighten': 'Clarear',
      'darken': 'Escurecer',
      'screen': 'Ecrã',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'Não há memória suficiente para a imagem.',
      'invalid_size': 'O tamanho da imagem não é válido.',
      'layer_index': 'Essa camada não existe.',
      'last_layer': 'Não é possível eliminar a última camada.',
      'no_layer_below': 'Não existe nenhuma camada inferior com a qual unir.',
      'edit_in_progress': 'Termine primeiro a operação em curso.',
      'no_edit': 'Não há nenhuma operação em curso para terminar.',
      'no_selection': 'Não há nada selecionado.',
      'nothing_lifted': 'Não há píxeis levantados.',
      'invalid_parameter': 'O valor está fora do intervalo permitido.',
      'io': 'Não foi possível ler ou escrever o ficheiro.',
      'decode': 'Não foi possível ler a imagem.',
      'encode': 'Não foi possível escrever a imagem.',
      'open_raster': 'O ficheiro OpenRaster está danificado.',
      'palette': 'O ficheiro de paleta está danificado.',
      'cancelled': 'O cálculo foi cancelado.',
      'other': 'Ocorreu um erro.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Não foi possível ler ou escrever o ficheiro.';

  @override
  String get failureInvalidData => 'Não foi possível ler os dados.';

  @override
  String get failureUnknown => 'Ocorreu um erro inesperado.';

  @override
  String get panelTools => 'Ferramentas';

  @override
  String get panelHistory => 'Histórico';

  @override
  String get panelLayers => 'Camadas';

  @override
  String get panelColors => 'Cores';

  @override
  String get panelHide => 'Ocultar';

  @override
  String get colorsPrimary => 'Primária';

  @override
  String get colorsSecondary => 'Secundária';

  @override
  String get colorsPrimaryHint =>
      'Cor primária: o botão esquerdo do rato pinta com ela';

  @override
  String get colorsSecondaryHint =>
      'Cor secundária: o botão direito do rato pinta com ela';

  @override
  String get colorsSwap => 'Trocar cores (X)';

  @override
  String get colorsReset => 'Repor preto e branco';

  @override
  String get colorsMore => 'Mais';

  @override
  String get colorsLess => 'Menos';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Alfa';

  @override
  String get colorsHue => 'M';

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
      'O clique esquerdo define a cor primária; o direito, a secundária';

  @override
  String get settingWidth => 'Largura';

  @override
  String get settingHardness => 'Dureza';

  @override
  String get settingAntialias => 'Suavização';

  @override
  String get settingAlphaBlending => 'Mistura alfa';

  @override
  String get settingTolerance => 'Tolerância';

  @override
  String get settingFloodMode => 'Modo de preenchimento';

  @override
  String get floodLocal => 'Contíguo';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Modo de seleção';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Substituir',
      'union': 'Unir',
      'exclude': 'Excluir',
      'xor': 'Xor',
      'intersect': 'Intersetar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Tamanho da seleção';

  @override
  String get drawNormal => 'Livre';

  @override
  String get drawFixedRatio => 'Proporção fixa';

  @override
  String get drawFixedSize => 'Tamanho fixo';

  @override
  String get settingResampling => 'Reamostragem';

  @override
  String get resamplingNearest => 'Vizinho mais próximo';

  @override
  String get resamplingBilinear => 'Bilinear';

  @override
  String get settingGradient => 'Tipo';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Linear',
      'linearReflected': 'Linear refletido',
      'diamond': 'Losango',
      'radial': 'Radial',
      'conical': 'Cónico',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Cor';

  @override
  String get gradientTransparency => 'Transparência';

  @override
  String get settingShape => 'Estilo da forma';

  @override
  String get shapeOutline => 'Contorno';

  @override
  String get shapeInterior => 'Preenchimento';

  @override
  String get shapeBoth => 'Contorno e preenchimento';

  @override
  String get settingAfterPick => 'Depois de recolher a cor';

  @override
  String get pickStay => 'Manter esta ferramenta';

  @override
  String get pickPrevious => 'Voltar à ferramenta anterior';

  @override
  String get pickPencil => 'Mudar para o Lápis';

  @override
  String get settingNone => 'Esta ferramenta não tem definições.';

  @override
  String toolUnavailable(String name) {
    return 'A ferramenta «$name» ainda não está disponível';
  }

  @override
  String get historyFirst => 'Ir para o primeiro passo';

  @override
  String get historyUndo => 'Anular';

  @override
  String get historyRedo => 'Refazer';

  @override
  String get historyLast => 'Ir para o último passo';

  @override
  String get historyNewImage => 'Nova imagem';

  @override
  String get historyOpenImage => 'Abrir imagem';

  @override
  String get layerVisible => 'Mostrar ou ocultar a camada';

  @override
  String get layerBackground => 'Fundo';

  @override
  String get layerName => 'Nome';

  @override
  String get layerOpacity => 'Opacidade';

  @override
  String get layerBlendMode => 'Modo de mistura';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get dontSave => 'Não guardar';

  @override
  String get keepCanvas => 'Manter a tela';

  @override
  String get expandCanvas => 'Expandir a tela';

  @override
  String get width => 'Largura';

  @override
  String get height => 'Altura';

  @override
  String get pixels => 'píxeis';

  @override
  String get newImageTitle => 'Nova imagem';

  @override
  String get resizeTitle => 'Redimensionar imagem';

  @override
  String get canvasSizeTitle => 'Tamanho da tela';

  @override
  String get keepRatio => 'Manter a proporção';

  @override
  String get anchor => 'Âncora';

  @override
  String sizeTooLarge(int max) {
    return 'A imagem é demasiado grande: o limite é de $max megapíxeis.';
  }

  @override
  String get unsavedTitle => 'Guardar as alterações?';

  @override
  String unsavedMessage(String name) {
    return '«$name» tem alterações por guardar.';
  }

  @override
  String get flattenTitle => 'Achatar a imagem?';

  @override
  String flattenMessage(String format) {
    return 'O formato $format não preserva camadas, pelo que a imagem será achatada numa única camada. Pode anular esta operação na janela Histórico.';
  }

  @override
  String get flatten => 'Achatar';

  @override
  String get jpegQualityTitle => 'Qualidade JPEG';

  @override
  String get quality => 'Qualidade';

  @override
  String get largerTitle => 'A imagem é maior do que a tela';

  @override
  String get largerMessage => 'Expandir a tela para a conter?';

  @override
  String get reseed => 'Nova semente';

  @override
  String get rendering => 'A processar…';

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
    return 'A abrir $name…';
  }

  @override
  String statusSaving(String name) {
    return 'A guardar $name…';
  }

  @override
  String savedTo(String name) {
    return 'Guardado: $name';
  }

  @override
  String get dropHere => 'Largue para abrir';

  @override
  String get dropHint => 'Cada ficheiro abre como uma nova imagem';

  @override
  String get imagesList => 'Imagens abertas';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Um editor de imagens raster com camadas. Prima uma letra para escolher uma ferramenta; premir novamente S, M ou O percorre as ferramentas relacionadas. [ e ] alteram a largura do pincel, X troca as cores, manter a barra de espaço premida desloca a vista, Ctrl+roda do rato altera o zoom e F5–F8 mostram ou ocultam as janelas.';

  @override
  String get aboutLegal =>
      '© 2026 os autores do Paintbox. O Paintbox é software livre: pode redistribuí-lo e modificá-lo nos termos da GNU General Public License, versão 3 ou posterior. É fornecido sem qualquer garantia.';

  @override
  String get licenses => 'Licenças';

  @override
  String get settingLineStart => 'Início';

  @override
  String get settingLineEnd => 'Fim';

  @override
  String get settingDash => 'Tracejado';

  @override
  String get settingSwapSize => 'Trocar largura e altura';

  @override
  String get settingLineStyle => 'Estilo';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plano',
      'arrow': 'Seta',
      'arrowFilled': 'Seta preenchida',
      'rounded': 'Arredondado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Contínuo',
      'dash': 'Traço',
      'dashDot': 'Traço-ponto',
      'dashDotDot': 'Traço-ponto-ponto',
      'dot': 'Pontilhado',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Tipo de letra';

  @override
  String get settingFontSize => 'Tamanho';

  @override
  String get textBold => 'Negrito';

  @override
  String get textItalic => 'Itálico';

  @override
  String get textUnderline => 'Sublinhado';

  @override
  String get textStrikeout => 'Rasurado';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Esquerda',
      'center': 'Centro',
      'right': 'Direita',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Imagens';
}
