import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/announcement.dart';
import '../../providers/auth_provider.dart';
import '../../services/engagement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';

/// Prikaz i unos ocjena za stazu, pogodnost ili skijaliste.
///
/// Korisnik moze ostaviti jednu ocjenu po stavci; postojecu moze urediti ili obrisati.
class ReviewSection extends StatefulWidget {
  const ReviewSection({
    super.key,
    required this.title,
    required this.reviews,
    required this.targetType,
    required this.averageRating,
    required this.reviewCount,
    required this.onChanged,
    this.trailId,
    this.benefitId,
    this.skiResortId,
  });

  final String title;
  final List<Review> reviews;
  final String targetType;
  final double averageRating;
  final int reviewCount;
  final VoidCallback onChanged;
  final int? trailId;
  final int? benefitId;
  final int? skiResortId;

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  bool _isSubmitting = false;

  Review? get _myReview {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null) return null;

    for (final review in widget.reviews) {
      if (review.userId == userId) return review;
    }
    return null;
  }

  Future<void> _openEditor({Review? existing}) async {
    final t = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<_ReviewDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReviewEditorSheet(
        initialRating: existing?.rating ?? 5,
        initialComment: existing?.comment ?? '',
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final service = context.read<EngagementService>();

      if (existing == null) {
        await service.createReview(
          targetType: widget.targetType,
          rating: result.rating,
          comment: result.comment.isEmpty ? null : result.comment,
          trailId: widget.trailId,
          benefitId: widget.benefitId,
          skiResortId: widget.skiResortId,
        );
        if (mounted) AppFeedback.success(context, t.reviewThanksMessage);
      } else {
        await service.updateReview(
          existing.id,
          result.rating,
          result.comment.isEmpty ? null : result.comment,
        );
        if (mounted) AppFeedback.success(context, t.reviewUpdatedMessage);
      }

      widget.onChanged();
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _delete(Review review) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppFeedback.confirm(
      context,
      title: t.reviewDeleteTitle,
      message: t.reviewDeleteMessage,
      confirmLabel: t.commonDelete,
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await context.read<EngagementService>().deleteReview(review.id);
      if (mounted) AppFeedback.success(context, t.reviewDeleteSuccessMessage);
      widget.onChanged();
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final myReview = _myReview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: widget.title),
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.averageRating == 0
                            ? '--'
                            : widget.averageRating.toStringAsFixed(1),
                        style: theme.textTheme.displaySmall,
                      ),
                      RatingStars(rating: widget.averageRating, size: 15),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      widget.reviewCount == 0
                          ? t.reviewNoRatingsYet
                          : t.reviewsCountLabel(widget.reviewCount),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (myReview == null)
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : () => _openEditor(),
                  icon: const Icon(Icons.star_outline_rounded),
                  label: Text(t.leaveReviewButton),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _openEditor(existing: myReview),
                        icon: const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
                        label: Text(t.editReviewButton),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    IconButton.outlined(
                      onPressed: _isSubmitting ? null : () => _delete(myReview),
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: t.deleteReviewTooltip,
                      color: AppColors.danger,
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (widget.reviews.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ...widget.reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ReviewTile(review: review),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  review.userFullName.isEmpty
                      ? '?'
                      : review.userFullName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userFullName, style: theme.textTheme.titleSmall),
                    Text(
                      Formatters.relative(review.createdAt),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              RatingStars(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Prikaz ocjene zvjezdicama, sa podrskom za polovicne vrijednosti.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final position = index + 1;
        final icon = rating >= position
            ? Icons.star_rounded
            : (rating >= position - 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded);

        return Icon(icon, size: size, color: AppColors.warning);
      }),
    );
  }
}

class _ReviewDraft {
  const _ReviewDraft({required this.rating, required this.comment});

  final int rating;
  final String comment;
}

class _ReviewEditorSheet extends StatefulWidget {
  const _ReviewEditorSheet({required this.initialRating, required this.initialComment});

  final int initialRating;
  final String initialComment;

  @override
  State<_ReviewEditorSheet> createState() => _ReviewEditorSheetState();
}

class _ReviewEditorSheetState extends State<_ReviewEditorSheet> {
  late int _rating = widget.initialRating;
  late final TextEditingController _comment =
      TextEditingController(text: widget.initialComment);

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.yourReviewTitle, style: theme.textTheme.titleLarge),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: t.closeTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final position = index + 1;
                return IconButton(
                  iconSize: 36,
                  onPressed: () => setState(() => _rating = position),
                  icon: Icon(
                    _rating >= position ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.warning,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _comment,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: t.reviewCommentHint,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              _ReviewDraft(rating: _rating, comment: _comment.text.trim()),
            ),
            child: Text(t.saveReviewButton),
          ),
        ],
      ),
    );
  }
}
