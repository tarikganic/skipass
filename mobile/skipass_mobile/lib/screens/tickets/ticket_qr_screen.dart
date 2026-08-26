import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/ticket.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/status_chip.dart';

/// QR kod karte koji se pokazuje na ulazu na ski lift.
///
/// Ekran drzi maksimalnu svjetlinu i sprjecava gasenje ekrana dok je otvoren,
/// jer se kod cita sa displeja na hladnoci i jakom svjetlu.
class TicketQrScreen extends StatefulWidget {
  const TicketQrScreen({super.key, required this.ticket});

  final SkiPassTicket ticket;

  @override
  State<TicketQrScreen> createState() => _TicketQrScreenState();
}

class _TicketQrScreenState extends State<TicketQrScreen> {
  @override
  void initState() {
    super.initState();
    // Tamna statusna traka bi se slabo vidjela na svijetloj podlozi QR ekrana.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final ticket = widget.ticket;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        title: Text(t.ticketQrAppBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: t.copyCodeTooltip,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: ticket.qrCode));
              AppFeedback.info(context, t.codeCopiedMessage);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xxxl,
          ),
          children: [
            Center(child: StatusChip(style: StatusStyles.ticket(context, ticket.status))),
            const SizedBox(height: AppSpacing.xl),

            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: QrImageView(
                  data: ticket.qrCode,
                  version: QrVersions.auto,
                  size: 232,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.textPrimary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Center(
              child: Text(
                ticket.qrCode,
                style: theme.textTheme.titleMedium?.copyWith(
                  letterSpacing: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                t.showCodeInstruction,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            AppCard(
              backgroundColor: Colors.white,
              child: Column(
                children: [
                  LabeledValue(
                    label: t.ticketHolderLabelFull,
                    value: ticket.holderFullName,
                    icon: Icons.person_outline_rounded,
                  ),
                  LabeledValue(
                    label: t.ticketTypeLabel,
                    value: ticket.ticketTypeName,
                    icon: Icons.confirmation_number_outlined,
                  ),
                  LabeledValue(
                    label: t.ticketValidLabel,
                    value: Formatters.dateRange(ticket.validFrom, ticket.validTo),
                    icon: Icons.event_available_rounded,
                  ),
                  LabeledValue(
                    label: t.skiResortLabel,
                    value: ticket.skiResortName,
                    icon: Icons.terrain_rounded,
                  ),
                  LabeledValue(
                    label: t.scanCountLabel,
                    value: '${ticket.validationCount}',
                    icon: Icons.qr_code_scanner_rounded,
                  ),
                  if (ticket.lastValidatedAt != null)
                    LabeledValue(
                      label: t.lastScanLabel,
                      value: Formatters.dateTime(ticket.lastValidatedAt!),
                      icon: Icons.history_rounded,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
