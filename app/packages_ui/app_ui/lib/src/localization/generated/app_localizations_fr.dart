// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Paintbox';

  @override
  String untitledImage(int number) {
    return 'Sans titre $number';
  }

  @override
  String get menuFile => 'Fichier';

  @override
  String get menuEdit => 'Édition';

  @override
  String get menuView => 'Affichage';

  @override
  String get menuImage => 'Image';

  @override
  String get menuLayers => 'Calques';

  @override
  String get menuAdjustments => 'Réglages';

  @override
  String get menuEffects => 'Effets';

  @override
  String get menuOpenRecent => 'Ouvrir un fichier récent';

  @override
  String get menuRecentEmpty => 'Aucun fichier récent';

  @override
  String get menuTheme => 'Thème';

  @override
  String get menuSettings => 'Paramètres';

  @override
  String get menuAccent => 'Couleur d’accentuation';

  @override
  String get menuLanguage => 'Langue';

  @override
  String get languageSystem => 'Selon le système';

  @override
  String accentName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'blue': 'Bleu',
      'green': 'Vert',
      'amber': 'Ambre',
      'purple': 'Violet',
      'red': 'Rouge',
      'gray': 'Gris',
      'custom': 'Personnalisée…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get accentCustomTitle => 'Couleur d’accentuation personnalisée';

  @override
  String get unitsPixels => 'px';

  @override
  String get themeSystem => 'Selon le système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String commandLabel(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'new': 'Nouveau…',
      'open': 'Ouvrir…',
      'close': 'Fermer',
      'save': 'Enregistrer',
      'save_as': 'Enregistrer sous…',
      'exit': 'Quitter',
      'undo': 'Annuler',
      'redo': 'Rétablir',
      'cut': 'Couper',
      'copy': 'Copier',
      'paste': 'Coller',
      'paste_into_new_layer': 'Coller dans un nouveau calque',
      'paste_into_new_image': 'Coller dans une nouvelle image',
      'erase_selection': 'Effacer la sélection',
      'fill_selection': 'Remplir la sélection',
      'invert_selection': 'Inverser la sélection',
      'select_all': 'Tout sélectionner',
      'deselect': 'Désélectionner',
      'zoom_in': 'Zoom avant',
      'zoom_out': 'Zoom arrière',
      'zoom_to_window': 'Ajuster à la fenêtre',
      'zoom_to_selection': 'Zoom sur la sélection',
      'actual_size': 'Taille réelle',
      'pixel_grid': 'Grille de pixels',
      'rulers': 'Règles',
      'crop_to_selection': 'Rogner selon la sélection',
      'resize': 'Redimensionner l’image…',
      'canvas_size': 'Taille du canevas…',
      'flip_horizontal': 'Retourner horizontalement',
      'flip_vertical': 'Retourner verticalement',
      'rotate90_cw': 'Rotation de 90° dans le sens horaire',
      'rotate90_ccw': 'Rotation de 90° dans le sens antihoraire',
      'rotate180': 'Rotation de 180°',
      'flatten': 'Aplatir',
      'add_layer': 'Ajouter un nouveau calque',
      'delete_layer': 'Supprimer le calque',
      'duplicate_layer': 'Dupliquer le calque',
      'merge_layer_down': 'Fusionner avec le calque inférieur',
      'import_from_file': 'Importer depuis un fichier…',
      'flip_layer_horizontal': 'Retourner le calque horizontalement',
      'flip_layer_vertical': 'Retourner le calque verticalement',
      'move_layer_up': 'Monter le calque',
      'move_layer_down': 'Descendre le calque',
      'layer_properties': 'Propriétés du calque…',
      'adjust_auto_level': 'Niveau automatique',
      'adjust_black_and_white': 'Noir et blanc',
      'adjust_brightness_contrast': 'Luminosité / Contraste…',
      'adjust_curves': 'Courbes…',
      'adjust_hue_saturation': 'Teinte / Saturation…',
      'adjust_invert_colors': 'Inverser les couleurs',
      'adjust_levels': 'Niveaux…',
      'adjust_posterize': 'Postériser…',
      'adjust_sepia': 'Sépia',
      'repeat_effect': 'Répéter l’effet',
      'effect_oil_painting': 'Peinture à l’huile…',
      'effect_gaussian_blur': 'Flou gaussien…',
      'effect_motion_blur': 'Flou de mouvement…',
      'effect_pixelate': 'Pixellisation…',
      'effect_add_noise': 'Ajout de bruit…',
      'effect_median': 'Médiane…',
      'effect_sharpen': 'Netteté…',
      'effect_edge_detect': 'Détection des contours…',
      'effect_emboss': 'Estampage…',
      'effect_outline': 'Contour…',
      'toggle_tools': 'Outils',
      'toggle_history': 'Historique',
      'toggle_layers': 'Calques',
      'toggle_colors': 'Couleurs',
      'next_image': 'Image suivante',
      'previous_image': 'Image précédente',
      'help': 'Aide',
      'effect_ink_sketch': 'Croquis à l’encre…',
      'effect_pencil_sketch': 'Croquis au crayon…',
      'effect_fragment': 'Fragmentation…',
      'effect_radial_blur': 'Flou radial…',
      'effect_surface_blur': 'Flou de surface…',
      'effect_unfocus': 'Défocalisation…',
      'effect_zoom_blur': 'Flou de zoom…',
      'effect_bulge': 'Renflement…',
      'effect_dents': 'Bosselures…',
      'effect_frosted_glass': 'Verre dépoli…',
      'effect_polar_inversion': 'Inversion polaire…',
      'effect_tile_reflection': 'Réflexion en mosaïque…',
      'effect_twist': 'Torsion…',
      'effect_reduce_noise': 'Réduction du bruit…',
      'effect_glow': 'Lueur…',
      'effect_red_eye_removal': 'Suppression des yeux rouges…',
      'effect_soften_portrait': 'Adoucissement de portrait…',
      'effect_clouds': 'Nuages…',
      'effect_julia_fractal': 'Fractale de Julia…',
      'effect_mandelbrot_fractal': 'Fractale de Mandelbrot…',
      'effect_relief': 'Relief…',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String effectGroup(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'artistic': 'Artistiques',
      'blurs': 'Flous',
      'distort': 'Déformation',
      'noise': 'Bruit',
      'photo': 'Photo',
      'stylize': 'Stylisation',
      'render': 'Rendu',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolName(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Sélection rectangulaire',
      'move_selected_pixels': 'Déplacer les pixels sélectionnés',
      'lasso_select': 'Sélection au lasso',
      'move_selection': 'Déplacer la sélection',
      'ellipse_select': 'Sélection elliptique',
      'zoom': 'Zoom',
      'magic_wand': 'Baguette magique',
      'pan': 'Main',
      'paint_bucket': 'Pot de peinture',
      'gradient': 'Dégradé',
      'paintbrush': 'Pinceau',
      'eraser': 'Gomme',
      'pencil': 'Crayon',
      'color_picker': 'Pipette',
      'clone_stamp': 'Tampon de duplication',
      'recolor': 'Recoloration',
      'text': 'Texte',
      'line_curve': 'Ligne / courbe',
      'rectangle': 'Rectangle',
      'rounded_rectangle': 'Rectangle arrondi',
      'ellipse': 'Ellipse',
      'freeform_shape': 'Forme libre',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String toolHint(String id) {
    String _temp0 = intl.Intl.selectLogic(id, {
      'rectangle_select': 'Faites glisser pour sélectionner un rectangle. Maintenez la touche Maj enfoncée pour obtenir un carré.',
      'move_selected_pixels': 'Faites glisser la sélection pour la déplacer. Faites glisser avec le bouton droit pour la faire pivoter, ou faites glisser les poignées pour la redimensionner. Ctrl laisse une copie ; les touches fléchées la déplacent pas à pas.',
      'lasso_select': 'Faites glisser pour tracer le contour d’une sélection.',
      'move_selection': 'Faites glisser le contour de la sélection pour le déplacer. Les pixels restent en place.',
      'ellipse_select': 'Faites glisser pour sélectionner une ellipse. Maintenez la touche Maj enfoncée pour obtenir un cercle.',
      'zoom': 'Cliquez avec le bouton gauche pour zoomer, avec le bouton droit pour dézoomer, ou tracez un cadre pour zoomer sur cette zone.',
      'magic_wand': 'Cliquez sur une couleur pour sélectionner la zone qui l’entoure. Maintenez la touche Maj enfoncée pour la sélectionner dans toute l’image.',
      'pan': 'Faites glisser pour déplacer la vue.',
      'paint_bucket': 'Un clic gauche remplit avec la couleur principale, un clic droit avec la couleur secondaire.',
      'gradient': 'Faites glisser pour tracer un dégradé. Faites glisser les poignées pour l’ajuster ; appuyez sur Entrée pour terminer.',
      'paintbrush': 'Le bouton gauche peint avec la couleur principale, le bouton droit avec la couleur secondaire.',
      'eraser': 'Faites glisser pour effacer jusqu’à la transparence.',
      'pencil': 'Trace des lignes d’un pixel sans anticrénelage.',
      'color_picker': 'Un clic gauche prélève la couleur principale, un clic droit la couleur secondaire.',
      'clone_stamp': 'Faites Ctrl+clic pour définir la source, puis faites glisser pour peindre à partir de celle-ci.',
      'recolor': 'Remplace la couleur secondaire par la couleur principale là où vous peignez. Ctrl+clic prélève une couleur.',
      'text': 'Cliquez pour placer le curseur, puis saisissez le texte. Faites glisser la poignée ou faites glisser avec le bouton droit pour déplacer le texte ; appuyez sur Échap pour terminer.',
      'line_curve': 'Faites glisser pour tracer une ligne. Faites glisser les poignées pour la courber ; appuyez sur Entrée pour terminer.',
      'rectangle': 'Faites glisser pour tracer un rectangle. Maintenez la touche Maj enfoncée pour obtenir un carré.',
      'rounded_rectangle': 'Faites glisser pour tracer un rectangle arrondi. Maintenez la touche Maj enfoncée pour obtenir un carré.',
      'ellipse': 'Faites glisser pour tracer une ellipse. Maintenez la touche Maj enfoncée pour obtenir un cercle.',
      'freeform_shape': 'Faites glisser pour tracer une forme libre fermée.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String paramName(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'radius': 'Rayon',
      'angle': 'Angle',
      'distance': 'Distance',
      'centered': 'Centré',
      'amount': 'Quantité',
      'intensity': 'Intensité',
      'saturation': 'Saturation',
      'coverage': 'Couverture',
      'seed': 'Graine',
      'percentile': 'Centile',
      'cell_size': 'Taille des cellules',
      'brush_size': 'Taille du pinceau',
      'coarseness': 'Grossièreté',
      'thickness': 'Épaisseur',
      'brightness': 'Luminosité',
      'contrast': 'Contraste',
      'hue': 'Teinte',
      'lightness': 'Clarté',
      'red': 'Rouge',
      'green': 'Vert',
      'blue': 'Bleu',
      'input_low': 'Entrée basse',
      'input_high': 'Entrée haute',
      'output_low': 'Sortie basse',
      'output_high': 'Sortie haute',
      'gamma': 'Gamma',
      'ink_outline': 'Contour à l’encre',
      'coloring': 'Coloration',
      'tip_size': 'Taille de la mine',
      'color_range': 'Plage de couleurs',
      'fragments': 'Fragments',
      'rotation': 'Rotation',
      'offset_x': 'Décalage X',
      'offset_y': 'Décalage Y',
      'quality': 'Qualité',
      'threshold': 'Seuil',
      'scale': 'Échelle',
      'refraction': 'Réfraction',
      'roughness': 'Rugosité',
      'tension': 'Tension',
      'max_scatter': 'Dispersion maximale',
      'min_scatter': 'Dispersion minimale',
      'samples': 'Échantillons',
      'edge_behavior': 'Comportement aux bords',
      'tile_size': 'Taille des carreaux',
      'curvature': 'Courbure',
      'size': 'Taille',
      'strength': 'Force',
      'tolerance': 'Tolérance',
      'softness': 'Douceur',
      'lighting': 'Éclairage',
      'warmth': 'Chaleur',
      'power': 'Puissance',
      'blend_mode': 'Mode de fusion',
      'factor': 'Facteur',
      'zoom': 'Zoom',
      'invert_colors': 'Inverser les couleurs',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String blendModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'normal': 'Normal',
      'multiply': 'Produit',
      'additive': 'Addition',
      'colorBurn': 'Densité couleur +',
      'colorDodge': 'Densité couleur −',
      'reflect': 'Réflexion',
      'glow': 'Lueur',
      'overlay': 'Incrustation',
      'difference': 'Différence',
      'negation': 'Négation',
      'lighten': 'Éclaircir',
      'darken': 'Obscurcir',
      'screen': 'Écran',
      'xor': 'Xor',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String failureCode(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'out_of_memory': 'La mémoire est insuffisante pour cette image.',
      'invalid_size': 'La taille de l’image n’est pas valide.',
      'layer_index': 'Ce calque n’existe pas.',
      'last_layer': 'Le dernier calque ne peut pas être supprimé.',
      'no_layer_below':
          'Il n’y a aucun calque en dessous avec lequel fusionner.',
      'edit_in_progress': 'Terminez d’abord l’opération en cours.',
      'no_edit': 'Aucune opération en cours n’est à terminer.',
      'no_selection': 'Rien n’est sélectionné.',
      'nothing_lifted': 'Aucun pixel n’est soulevé.',
      'invalid_parameter': 'La valeur est hors limites.',
      'io': 'Le fichier n’a pas pu être lu ou écrit.',
      'decode': 'L’image n’a pas pu être lue.',
      'encode': 'L’image n’a pas pu être écrite.',
      'open_raster': 'Le fichier OpenRaster est endommagé.',
      'palette': 'Le fichier de palette est endommagé.',
      'cancelled': 'Le calcul a été annulé.',
      'other': 'Une erreur s’est produite.',
    });
    return '$_temp0';
  }

  @override
  String get failureStorage => 'Le fichier n’a pas pu être lu ou écrit.';

  @override
  String get failureInvalidData => 'Les données n’ont pas pu être lues.';

  @override
  String get failureUnknown => 'Une erreur inattendue s’est produite.';

  @override
  String get panelTools => 'Outils';

  @override
  String get panelHistory => 'Historique';

  @override
  String get panelLayers => 'Calques';

  @override
  String get panelColors => 'Couleurs';

  @override
  String get panelHide => 'Masquer';

  @override
  String get colorsPrimary => 'Principale';

  @override
  String get colorsSecondary => 'Secondaire';

  @override
  String get colorsPrimaryHint =>
      'Couleur principale : le bouton gauche de la souris peint avec elle';

  @override
  String get colorsSecondaryHint =>
      'Couleur secondaire : le bouton droit de la souris peint avec elle';

  @override
  String get colorsSwap => 'Permuter les couleurs (X)';

  @override
  String get colorsReset => 'Rétablir le noir et le blanc';

  @override
  String get colorsMore => 'Plus';

  @override
  String get colorsLess => 'Moins';

  @override
  String get colorsHex => 'Hex';

  @override
  String get colorsAlpha => 'Alpha';

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
      'Un clic gauche définit la couleur principale, un clic droit la couleur secondaire';

  @override
  String get settingWidth => 'Largeur';

  @override
  String get settingHardness => 'Dureté';

  @override
  String get settingAntialias => 'Anticrénelage';

  @override
  String get settingAlphaBlending => 'Fusion alpha';

  @override
  String get settingTolerance => 'Tolérance';

  @override
  String get settingFloodMode => 'Mode de remplissage';

  @override
  String get floodLocal => 'Contigu';

  @override
  String get floodGlobal => 'Global';

  @override
  String get settingSelectionMode => 'Mode de sélection';

  @override
  String combineMode(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'replace': 'Remplacer',
      'union': 'Unir',
      'exclude': 'Exclure',
      'xor': 'Xor',
      'intersect': 'Intersecter',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingDrawMode => 'Taille de la sélection';

  @override
  String get drawNormal => 'Libre';

  @override
  String get drawFixedRatio => 'Proportions fixes';

  @override
  String get drawFixedSize => 'Taille fixe';

  @override
  String get settingResampling => 'Rééchantillonnage';

  @override
  String get resamplingNearest => 'Plus proche voisin';

  @override
  String get resamplingBilinear => 'Bilinéaire';

  @override
  String get settingGradient => 'Type';

  @override
  String gradientKind(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'linear': 'Linéaire',
      'linearReflected': 'Linéaire réfléchi',
      'diamond': 'Losange',
      'radial': 'Radial',
      'conical': 'Conique',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get gradientColor => 'Couleur';

  @override
  String get gradientTransparency => 'Transparence';

  @override
  String get settingShape => 'Style de forme';

  @override
  String get shapeOutline => 'Contour';

  @override
  String get shapeInterior => 'Remplissage';

  @override
  String get shapeBoth => 'Contour et remplissage';

  @override
  String get settingAfterPick => 'Après le prélèvement';

  @override
  String get pickStay => 'Conserver cet outil';

  @override
  String get pickPrevious => 'Revenir à l’outil précédent';

  @override
  String get pickPencil => 'Passer au Crayon';

  @override
  String get settingNone => 'Cet outil n’a aucun paramètre.';

  @override
  String toolUnavailable(String name) {
    return 'L’outil « $name » n’est pas encore disponible';
  }

  @override
  String get historyFirst => 'Aller à la première étape';

  @override
  String get historyUndo => 'Annuler';

  @override
  String get historyRedo => 'Rétablir';

  @override
  String get historyLast => 'Aller à la dernière étape';

  @override
  String get historyNewImage => 'Nouvelle image';

  @override
  String get historyOpenImage => 'Ouverture de l’image';

  @override
  String get layerVisible => 'Afficher ou masquer le calque';

  @override
  String get layerBackground => 'Arrière-plan';

  @override
  String get layerName => 'Nom';

  @override
  String get layerOpacity => 'Opacité';

  @override
  String get layerBlendMode => 'Mode de fusion';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get dontSave => 'Ne pas enregistrer';

  @override
  String get keepCanvas => 'Conserver le canevas';

  @override
  String get expandCanvas => 'Agrandir le canevas';

  @override
  String get width => 'Largeur';

  @override
  String get height => 'Hauteur';

  @override
  String get pixels => 'pixels';

  @override
  String get newImageTitle => 'Nouvelle image';

  @override
  String get resizeTitle => 'Redimensionner l’image';

  @override
  String get canvasSizeTitle => 'Taille du canevas';

  @override
  String get keepRatio => 'Conserver les proportions';

  @override
  String get anchor => 'Ancrage';

  @override
  String sizeTooLarge(int max) {
    return 'L’image est trop grande : la limite est de $max mégapixels.';
  }

  @override
  String get unsavedTitle => 'Enregistrer les modifications ?';

  @override
  String unsavedMessage(String name) {
    return '« $name » contient des modifications non enregistrées.';
  }

  @override
  String get flattenTitle => 'Aplatir l’image ?';

  @override
  String flattenMessage(String format) {
    return 'Le format $format ne conserve pas les calques ; l’image sera donc aplatie en un seul calque. Vous pouvez annuler cette opération dans la fenêtre Historique.';
  }

  @override
  String get flatten => 'Aplatir';

  @override
  String get jpegQualityTitle => 'Qualité JPEG';

  @override
  String get quality => 'Qualité';

  @override
  String get largerTitle => 'L’image est plus grande que le canevas';

  @override
  String get largerMessage => 'Agrandir le canevas pour la contenir ?';

  @override
  String get reseed => 'Nouvelle graine';

  @override
  String get rendering => 'Rendu…';

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
    return '$percent %';
  }

  @override
  String statusOpening(String name) {
    return 'Ouverture de $name…';
  }

  @override
  String statusSaving(String name) {
    return 'Enregistrement de $name…';
  }

  @override
  String savedTo(String name) {
    return 'Enregistré : $name';
  }

  @override
  String get dropHere => 'Déposez pour ouvrir';

  @override
  String get dropHint => 'Chaque fichier s’ouvre dans une nouvelle image';

  @override
  String get imagesList => 'Images ouvertes';

  @override
  String get helpTitle => 'Paintbox';

  @override
  String get helpMessage =>
      'Un éditeur d’images matricielles avec calques. Appuyez sur une lettre pour choisir un outil ; appuyer de nouveau sur S, M ou O fait défiler les outils apparentés. [ et ] modifient la largeur du pinceau, X permute les couleurs, maintenir la barre d’espace enfoncée déplace la vue, Ctrl+molette de la souris zoome, et F5–F8 affichent ou masquent les fenêtres.';

  @override
  String get aboutLegal =>
      '© 2026 les auteurs de Paintbox. Paintbox est un logiciel libre : vous pouvez le redistribuer et le modifier selon les termes de la GNU General Public License, version 3 ou ultérieure. Il est fourni sans aucune garantie.';

  @override
  String get licenses => 'Licences';

  @override
  String get settingLineStart => 'Début';

  @override
  String get settingLineEnd => 'Fin';

  @override
  String get settingDash => 'Tirets';

  @override
  String get settingSwapSize => 'Permuter la largeur et la hauteur';

  @override
  String get settingLineStyle => 'Style';

  @override
  String lineCap(String cap) {
    String _temp0 = intl.Intl.selectLogic(cap, {
      'flat': 'Plat',
      'arrow': 'Flèche',
      'arrowFilled': 'Flèche pleine',
      'rounded': 'Arrondi',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String dashStyle(String dash) {
    String _temp0 = intl.Intl.selectLogic(dash, {
      'solid': 'Continu',
      'dash': 'Tiret',
      'dashDot': 'Tiret-point',
      'dashDotDot': 'Tiret-point-point',
      'dot': 'Pointillé',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingFont => 'Police';

  @override
  String get settingFontSize => 'Taille';

  @override
  String get textBold => 'Gras';

  @override
  String get textItalic => 'Italique';

  @override
  String get textUnderline => 'Souligné';

  @override
  String get textStrikeout => 'Barré';

  @override
  String textAlign(String align) {
    String _temp0 = intl.Intl.selectLogic(align, {
      'left': 'Gauche',
      'center': 'Centre',
      'right': 'Droite',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get fileTypeImages => 'Images';
}
