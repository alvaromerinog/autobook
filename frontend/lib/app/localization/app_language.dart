enum AppLanguage {
  spanish('es', 'Español'),
  english('en', 'English');

  const AppLanguage(this.code, this.endonym);

  final String code;
  final String endonym;
}

AppLanguage? appLanguageFromCode(String? code) {
  for (final language in AppLanguage.values) {
    if (language.code == code) {
      return language;
    }
  }
  return null;
}
