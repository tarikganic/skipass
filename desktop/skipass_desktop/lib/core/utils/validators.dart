/// Klijentska validacija unosa.
///
/// Server validira sve isto ponovo; ovo sluzi da korisnik dobije poruku odmah.
/// Poruke eksplicitno navode ocekivani format i ogranicenja.
class Validators {
  const Validators._();

  static final RegExp _email = RegExp(r'^[\w.!#$%&*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _phone = RegExp(r'^\+?[0-9\s/-]{6,20}$');
  static final RegExp _username = RegExp(r'^[a-zA-Z0-9._-]{3,50}$');

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezno polje.';
    }
    return null;
  }

  static String? name(String? value, String fieldName) {
    final empty = required(value, fieldName);
    if (empty != null) return empty;

    final trimmed = value!.trim();
    if (trimmed.length < 2 || trimmed.length > 100) {
      return '$fieldName mora imati izmedju 2 i 100 znakova.';
    }
    return null;
  }

  static String? username(String? value) {
    final empty = required(value, 'Korisnicko ime');
    if (empty != null) return empty;

    if (!_username.hasMatch(value!.trim())) {
      return 'Korisnicko ime moze sadrzavati slova, cifre, tacku, crticu i podvlaku (3-50 znakova).';
    }
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, 'E-mail adresa');
    if (empty != null) return empty;

    if (!_email.hasMatch(value!.trim())) {
      return 'Unesite validnu e-mail adresu u formatu: ime@domena.ba';
    }
    return null;
  }

  /// Telefon je opciono polje, ali ako je unesen mora biti ispravnog formata.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    if (!_phone.hasMatch(value.trim())) {
      return 'Unesite validan broj telefona u formatu: +387 61 123 456';
    }
    return null;
  }

  static String? password(String? value, {String fieldName = 'Lozinka'}) {
    final empty = required(value, fieldName);
    if (empty != null) return empty;

    if (value!.length < 4) {
      return '$fieldName mora imati najmanje 4 znaka.';
    }
    return null;
  }

  static String? passwordConfirmation(String? value, String original) {
    final empty = required(value, 'Potvrda lozinke');
    if (empty != null) return empty;

    if (value != original) {
      return 'Potvrda lozinke se ne podudara sa unesenom lozinkom.';
    }
    return null;
  }

  static String? lengthRange(
    String? value,
    String fieldName, {
    required int min,
    required int max,
    bool isRequired = true,
  }) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return isRequired ? '$fieldName je obavezno polje.' : null;
    }

    if (trimmed.length < min || trimmed.length > max) {
      return '$fieldName mora imati izmedju $min i $max znakova.';
    }
    return null;
  }
}
