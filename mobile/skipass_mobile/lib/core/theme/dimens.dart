/// Skala razmaka. Sve margine i paddinzi izvedeni su iz osnovne jedinice od 4 px
/// kako bi razmaci kroz aplikaciju bili dosljedni.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontalni padding ekrana.
  static const double screen = 16;
}

/// Radijusi zaobljenja.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

/// Visine i dimenzije koje se ponavljaju kroz vise ekrana.
class AppSizes {
  const AppSizes._();

  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double avatar = 56;
  static const double cardImage = 148;
}
