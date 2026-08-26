import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/validators.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../services/catalog_service.dart';
import '../../services/engagement_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/state_views.dart';

/// Prijava incidenta sa staze ili lifta.
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({
    super.key,
    this.preselectedTrailId,
    this.preselectedTrailName,
  });

  final int? preselectedTrailId;
  final String? preselectedTrailName;

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

enum _IncidentTarget { trail, lift }

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  List<Lookup> _incidentTypes = const [];
  List<Lookup> _trails = const [];
  List<Lookup> _lifts = const [];

  Lookup? _selectedType;
  Lookup? _selectedTrail;
  Lookup? _selectedLift;
  _IncidentTarget _target = _IncidentTarget.trail;

  File? _photo;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  @override
  void dispose() {
    _description.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final catalog = context.read<CatalogService>();
      final results = await Future.wait([
        catalog.lookup('IncidentTypes'),
        catalog.lookup('Trails'),
        catalog.lookup('SkiLifts'),
      ]);

      if (!mounted) return;

      final trails = results[1];

      setState(() {
        _incidentTypes = results[0];
        _trails = trails;
        _lifts = results[2];
        _selectedType = _incidentTypes.isEmpty ? null : _incidentTypes.first;

        // Kada se prijava pokrece sa detalja staze, staza je vec odabrana.
        if (widget.preselectedTrailId != null) {
          for (final trail in trails) {
            if (trail.id == widget.preselectedTrailId) {
              _selectedTrail = trail;
              break;
            }
          }
        }

        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 82,
      );

      if (picked == null || !mounted) return;
      setState(() => _photo = File(picked.path));
    } on Exception {
      if (mounted) {
        AppFeedback.error(context, AppLocalizations.of(context)!.imagePickFailedMessage);
      }
    }
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedType == null) {
      AppFeedback.error(context, t.selectIncidentTypeError);
      return;
    }

    final isTrail = _target == _IncidentTarget.trail;
    if (isTrail && _selectedTrail == null) {
      AppFeedback.error(context, t.selectTrailError);
      return;
    }
    if (!isTrail && _selectedLift == null) {
      AppFeedback.error(context, t.selectLiftError);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final engagement = context.read<EngagementService>();

      // Slika se prvo salje, pa se dobijena putanja veze uz prijavu.
      String? imageUrl;
      if (_photo != null) {
        imageUrl = await engagement.uploadIncidentImage(_photo!);
      }

      await engagement.reportIncident(
        incidentTypeId: _selectedType!.id,
        description: _description.text.trim(),
        latitude: double.parse(_latitude.text.trim().replaceAll(',', '.')),
        longitude: double.parse(_longitude.text.trim().replaceAll(',', '.')),
        trailId: isTrail ? _selectedTrail!.id : null,
        skiLiftId: isTrail ? null : _selectedLift!.id,
        imageUrl: imageUrl,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppFeedback.success(
        context,
        t.incidentReportSuccessMessage,
      );
    } on ApiException catch (error) {
      if (mounted) AppFeedback.error(context, error.message);
    } on FormatException {
      if (mounted) {
        AppFeedback.error(context, t.coordinatesInvalidFormatError);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.reportIncidentAppBarTitle)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final t = AppLocalizations.of(context)!;
    if (_isLoading) return const LoadingSkeleton(count: 4, height: 100);

    if (_loadError != null) {
      return ErrorStateView(message: _loadError!, onRetry: _loadReferenceData);
    }

    if (_incidentTypes.isEmpty) {
      return EmptyStateView(
        icon: Icons.report_gmailerrorred_outlined,
        title: t.incidentEmptyTitle,
        message: t.incidentEmptyMessage,
      );
    }

    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xl,
          AppSpacing.screen,
          AppSpacing.xxxl,
        ),
        children: [
          AppCard(
            backgroundColor: AppColors.infoSurface,
            borderColor: AppColors.info.withValues(alpha: 0.25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.info,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    t.incidentSafetyNotice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          AppDropdownField<Lookup>(
            label: t.incidentTypeLabel,
            items: _incidentTypes,
            value: _selectedType,
            isRequired: true,
            prefixIcon: Icons.category_outlined,
            itemLabel: (type) => type.name,
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(t.incidentLocationLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<_IncidentTarget>(
            segments: [
              ButtonSegment(
                value: _IncidentTarget.trail,
                label: Text(t.targetTrailLabel),
                icon: const Icon(Icons.downhill_skiing_rounded),
              ),
              ButtonSegment(
                value: _IncidentTarget.lift,
                label: Text(t.targetLiftLabel),
                icon: const Icon(Icons.cable_rounded),
              ),
            ],
            selected: {_target},
            onSelectionChanged: (selection) =>
                setState(() => _target = selection.first),
          ),
          const SizedBox(height: AppSpacing.xl),

          if (_target == _IncidentTarget.trail)
            AppDropdownField<Lookup>(
              label: t.targetTrailLabel,
              items: _trails,
              value: _selectedTrail,
              isRequired: true,
              prefixIcon: Icons.downhill_skiing_rounded,
              itemLabel: (trail) => trail.name,
              emptyHint: t.trailsUnavailableHint,
              onChanged: (value) => setState(() => _selectedTrail = value),
            )
          else
            AppDropdownField<Lookup>(
              label: t.targetLiftLabel,
              items: _lifts,
              value: _selectedLift,
              isRequired: true,
              prefixIcon: Icons.cable_rounded,
              itemLabel: (lift) => lift.name,
              emptyHint: t.liftsUnavailableHint,
              onChanged: (value) => setState(() => _selectedLift = value),
            ),
          const SizedBox(height: AppSpacing.xl),

          AppTextField(
            label: t.problemDescriptionLabel,
            controller: _description,
            hint: t.problemDescriptionHint,
            maxLines: 5,
            maxLength: 2000,
            isRequired: true,
            helperText: t.minTenCharsHelper,
            validator: (value) => Validators.lengthRange(
              value,
              'Opis problema',
              min: 10,
              max: 2000,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          _CoordinatesField(
            latitudeController: _latitude,
            longitudeController: _longitude,
          ),
          const SizedBox(height: AppSpacing.xl),

          _PhotoPicker(
            photo: _photo,
            onPick: _pickPhoto,
            onRemove: () => setState(() => _photo = null),
          ),
          const SizedBox(height: AppSpacing.xxl),

          BusyButton(
            label: t.submitReportButton,
            icon: Icons.send_rounded,
            isBusy: _isSubmitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text(t.commonDiscard),
          ),
        ],
      ),
    );
  }
}

/// Unos koordinata kroz pomocni izbornik sa poznatim tackama skijalista,
/// umjesto slobodnog kucanja brojeva.
class _CoordinatesField extends StatefulWidget {
  const _CoordinatesField({
    required this.latitudeController,
    required this.longitudeController,
  });

  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  @override
  State<_CoordinatesField> createState() => _CoordinatesFieldState();
}

class _CoordinatesFieldState extends State<_CoordinatesField> {
  /// Referentne tacke skijalista koje korisnik moze odabrati na terenu.
  Map<String, (double, double)> _knownSpots(AppLocalizations t) => <String, (double, double)>{
        t.knownSpotBase: (43.7107, 18.2686),
        t.knownSpotMiddle: (43.7112, 18.2691),
        t.knownSpotTop: (43.7121, 18.2702),
        t.knownSpotLiftStart: (43.7098, 18.2673),
      };

  String? _selectedSpot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.coordinatesFieldTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          t.coordinatesFieldSubtitle,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _knownSpots(t).entries.map((entry) {
            return ChoiceChip(
              label: Text(entry.key),
              selected: _selectedSpot == entry.key,
              showCheckmark: false,
              onSelected: (_) {
                setState(() => _selectedSpot = entry.key);
                widget.latitudeController.text = entry.value.$1.toStringAsFixed(4);
                widget.longitudeController.text = entry.value.$2.toStringAsFixed(4);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: t.geoLatitudeName,
                controller: widget.latitudeController,
                hint: '43.7107',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
                validator: (value) => _validateCoordinate(value, t.geoLatitudeName, 90),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                label: t.geoLongitudeName,
                controller: widget.longitudeController,
                hint: '18.2686',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
                validator: (value) => _validateCoordinate(value, t.geoLongitudeName, 180),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _validateCoordinate(String? value, String name, double limit) {
    final t = AppLocalizations.of(context)!;
    final trimmed = value?.trim().replaceAll(',', '.') ?? '';

    if (trimmed.isEmpty) {
      return t.coordinateRequiredError(name);
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return t.coordinateFormatError;
    }

    if (parsed < -limit || parsed > limit) {
      return t.coordinateRangeError(name, -limit.toInt(), limit.toInt());
    }

    return null;
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  final File? photo;
  final void Function(ImageSource source) onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.photoSectionTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        if (photo != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.file(
                  photo!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: t.removePhotoAction,
                    onPressed: onRemove,
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onPick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined, size: AppSizes.iconSm),
                  label: Text(t.cameraButton),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onPick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: AppSizes.iconSm),
                  label: Text(t.galleryButton),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
