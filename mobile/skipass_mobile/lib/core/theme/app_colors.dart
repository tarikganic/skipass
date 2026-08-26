import 'package:flutter/material.dart';

/// Paleta boja SkiPass sistema.
///
/// Boje su izvedene iz zimskog ambijenta skijalista: duboko plava kao osnovna,
/// ledeno plava kao akcent i topli tonovi za upozorenja. Ista paleta koristi se
/// i u desktop aplikaciji kako bi oba klijenta djelovala kao jedan proizvod.
class AppColors {
  const AppColors._();

  // --- Osnovna paleta ---
  static const Color primary = Color(0xFF1B6CA8);
  static const Color primaryDark = Color(0xFF12507E);
  static const Color primaryLight = Color(0xFF4A93C9);

  /// Blaga podloga za istaknute sekcije i chip elemente.
  static const Color primarySurface = Color(0xFFE8F2F9);

  static const Color accent = Color(0xFF3EBFDF);
  static const Color accentSurface = Color(0xFFE4F6FB);

  // --- Semanticke boje stanja ---
  static const Color success = Color(0xFF1E8E5A);
  static const Color successSurface = Color(0xFFE6F4ED);

  static const Color warning = Color(0xFFC77700);
  static const Color warningSurface = Color(0xFFFDF3E3);

  static const Color danger = Color(0xFFC62828);
  static const Color dangerSurface = Color(0xFFFBEAEA);

  static const Color info = Color(0xFF2F6FB5);
  static const Color infoSurface = Color(0xFFE9F1FA);

  // --- Svijetla tema ---
  static const Color background = Color(0xFFF4F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEEF3F8);
  static const Color border = Color(0xFFDCE5EE);
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF56697C);
  static const Color textDisabled = Color(0xFF93A3B3);

  // --- Tamna tema ---
  static const Color darkBackground = Color(0xFF0C141D);
  static const Color darkSurface = Color(0xFF151F2B);
  static const Color darkSurfaceAlt = Color(0xFF1D2A38);
  static const Color darkBorder = Color(0xFF2A3846);
  static const Color darkTextPrimary = Color(0xFFE8EEF4);
  static const Color darkTextSecondary = Color(0xFF9BADBF);

  /// Gradijent zaglavlja na pocetnoj stranici.
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF12507E), Color(0xFF1B6CA8), Color(0xFF2F87BE)],
  );

  /// Pretvara HEX oznaku iz baze (npr. tezina staze) u boju.
  /// Vraca [fallback] ako je vrijednost prazna ili neispravna.
  static Color fromHex(String? hex, {Color fallback = primary}) {
    if (hex == null || hex.isEmpty) return fallback;

    final normalized = hex.replaceFirst('#', '').trim();
    final expanded = normalized.length == 3
        ? normalized.split('').map((c) => '$c$c').join()
        : normalized;

    if (expanded.length != 6) return fallback;

    final value = int.tryParse(expanded, radix: 16);
    return value == null ? fallback : Color(0xFF000000 | value);
  }
}
