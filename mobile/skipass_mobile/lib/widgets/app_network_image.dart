import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/theme/dimens.dart';

/// Deterministicka paleta boja za rezervni prikaz slike - isti "seed" (npr. naziv
/// ili kod entiteta) uvijek daje istu boju, umjesto nasumicne koja bi se
/// mijenjala pri svakom iscrtavanju.
class PlaceholderColors {
  const PlaceholderColors._();

  static const List<Color> palette = [
    Color(0xFF1B6CA8),
    Color(0xFF3EBFDF),
    Color(0xFF1E8E5A),
    Color(0xFFC77700),
    Color(0xFF8E44AD),
    Color(0xFFC62828),
    Color(0xFF2F6FB5),
    Color(0xFF00897B),
    Color(0xFF6D4C41),
    Color(0xFF5E35B1),
  ];

  static Color colorFor(String seed) {
    if (seed.isEmpty) return palette.first;

    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return palette[hash % palette.length];
  }
}

/// Prikaz mrezne slike entiteta (staza, pogodnost, obavijest, incident...) sa
/// rezervnim prikazom u boji izvedenoj iz [seed] kada slika nije postavljena
/// ili se ne moze ucitati - umjesto praznog sivog polja.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    required this.seed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.icon = Icons.image_outlined,
  });

  final String? imageUrl;
  final String seed;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final resolved = AppConfig.resolveImageUrl(imageUrl);
    final placeholder = _Placeholder(seed: seed, width: width, height: height, icon: icon);

    final child = resolved.isEmpty
        ? placeholder
        : Image.network(
            resolved,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => placeholder,
          );

    return borderRadius == null ? child : ClipRRect(borderRadius: borderRadius!, child: child);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.seed, this.width, this.height, required this.icon});

  final String seed;
  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = PlaceholderColors.colorFor(seed);

    return Container(
      width: width,
      height: height,
      color: color.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Icon(icon, size: AppSizes.iconLg, color: color),
    );
  }
}
