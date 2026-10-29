/// The interface languages with their own names (autonyms), in the order
/// the settings list them. A language is named in itself, not translated:
/// whoever looks for it reads it in it.
abstract final class AppLanguages {
  static const Map<String, String> names = {
    'en': 'English',
    'uk': 'Українська',
    'be': 'Беларуская',
    'bg': 'Български',
    'cs': 'Čeština',
    'da': 'Dansk',
    'de': 'Deutsch',
    'el': 'Ελληνικά',
    'es': 'Español',
    'et': 'Eesti',
    'fi': 'Suomi',
    'fr': 'Français',
    'hr': 'Hrvatski',
    'hu': 'Magyar',
    'it': 'Italiano',
    'kk': 'Қазақ тілі',
    'lt': 'Lietuvių',
    'lv': 'Latviešu',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'pt': 'Português',
    'ro': 'Română',
    'sk': 'Slovenčina',
    'sv': 'Svenska',
    'tr': 'Türkçe',
  };
}
