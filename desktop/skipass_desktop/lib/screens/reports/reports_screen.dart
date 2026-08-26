import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../models/paged_result.dart';
import '../../models/report.dart';
import '../../services/pdf_report_service.dart';
import '../../services/reference_data_service.dart';
import '../../services/report_service.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/state_views.dart';

/// Izvjestaji - prodaja po danima (sa filterom perioda) i top 5 korisnika,
/// oboje dostupno za preuzimanje i stampu u PDF formatu.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 13));
  DateTime _dateTo = DateTime.now();
  int? _resortId;
  List<Lookup> _resorts = const [];

  SalesReport? _salesReport;
  TopUsersReport? _topUsersReport;
  String? _salesError;
  String? _topUsersError;
  bool _isLoadingSales = true;
  bool _isLoadingTopUsers = true;
  bool _isExportingSales = false;
  bool _isExportingTopUsers = false;

  @override
  void initState() {
    super.initState();
    _loadResorts();
    _loadSalesReport();
    _loadTopUsers();
  }

  Future<void> _loadResorts() async {
    final resorts = await context.read<ReferenceDataService>().lookup('SkiResorts');
    if (mounted) setState(() => _resorts = resorts);
  }

  Future<void> _loadSalesReport() async {
    setState(() {
      _isLoadingSales = true;
      _salesError = null;
    });

    try {
      final report = await context.read<ReportService>().getSalesByDay(dateFrom: _dateFrom, dateTo: _dateTo, skiResortId: _resortId);
      if (mounted) setState(() => _salesReport = report);
    } catch (error) {
      if (mounted) setState(() => _salesError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingSales = false);
    }
  }

  Future<void> _loadTopUsers() async {
    setState(() {
      _isLoadingTopUsers = true;
      _topUsersError = null;
    });

    try {
      final report = await context.read<ReportService>().getTopUsers(top: 5);
      if (mounted) setState(() => _topUsersReport = report);
    } catch (error) {
      if (mounted) setState(() => _topUsersError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingTopUsers = false);
    }
  }

  Future<void> _pickDateFrom() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateFrom,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: _dateTo,
      helpText: l10n.reportsScreenDateFromHelp,
      cancelText: l10n.commonDismiss,
      confirmText: l10n.commonConfirm,
    );
    if (selected != null) {
      setState(() => _dateFrom = selected);
      _loadSalesReport();
    }
  }

  Future<void> _pickDateTo() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateTo,
      firstDate: _dateFrom,
      lastDate: DateTime.now(),
      helpText: l10n.reportsScreenDateToHelp,
      cancelText: l10n.commonDismiss,
      confirmText: l10n.commonConfirm,
    );
    if (selected != null) {
      setState(() => _dateTo = selected);
      _loadSalesReport();
    }
  }

  String? get _resortLabel => _resortId == null ? null : _resorts.where((r) => r.id == _resortId).firstOrNull?.name;

  Future<void> _downloadSales() async {
    if (_salesReport == null) return;
    setState(() => _isExportingSales = true);
    try {
      final bytes = await PdfReportService.buildSalesReport(_salesReport!, resortLabel: _resortLabel);
      await _saveAndNotify(bytes, 'izvjestaj-prodaje.pdf');
    } finally {
      if (mounted) setState(() => _isExportingSales = false);
    }
  }

  Future<void> _printSales() async {
    if (_salesReport == null) return;
    final bytes = await PdfReportService.buildSalesReport(_salesReport!, resortLabel: _resortLabel);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _downloadTopUsers() async {
    if (_topUsersReport == null) return;
    setState(() => _isExportingTopUsers = true);
    try {
      final bytes = await PdfReportService.buildTopUsersReport(_topUsersReport!);
      await _saveAndNotify(bytes, 'top-korisnici.pdf');
    } finally {
      if (mounted) setState(() => _isExportingTopUsers = false);
    }
  }

  Future<void> _printTopUsers() async {
    if (_topUsersReport == null) return;
    final bytes = await PdfReportService.buildTopUsersReport(_topUsersReport!);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _saveAndNotify(List<int> bytes, String fileName) async {
    try {
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) AppFeedback.success(context, AppLocalizations.of(context)!.reportsScreenSaveSuccess(file.path));
      unawaited(Process.start('explorer.exe', [file.path]));
    } catch (error) {
      if (mounted) AppFeedback.error(context, AppLocalizations.of(context)!.reportsScreenSaveError(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.navReports, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xl),
          _SectionCard(
            title: l10n.reportsScreenSalesTitle,
            onDownload: _isLoadingSales ? null : _downloadSales,
            onPrint: _isLoadingSales ? null : _printSales,
            isExporting: _isExportingSales,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _DateChip(label: l10n.reportsScreenFromLabel, value: _dateFrom, onTap: _pickDateFrom),
                    _DateChip(label: l10n.reportsScreenToLabel, value: _dateTo, onTap: _pickDateTo),
                    DropdownButton<int?>(
                      value: _resortId,
                      hint: Text(l10n.reportsScreenAllResorts),
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem<int?>(child: Text(l10n.reportsScreenAllResorts)),
                        for (final resort in _resorts) DropdownMenuItem<int?>(value: resort.id, child: Text(resort.name)),
                      ],
                      onChanged: (value) {
                        setState(() => _resortId = value);
                        _loadSalesReport();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_isLoadingSales)
                  const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()))
                else if (_salesError != null)
                  SizedBox(height: 220, child: ErrorStateView(message: _salesError!, onRetry: _loadSalesReport))
                else if (_salesReport != null)
                  _SalesReportView(report: _salesReport!),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SectionCard(
            title: l10n.reportsScreenTopUsersTitle(5),
            onDownload: _isLoadingTopUsers ? null : _downloadTopUsers,
            onPrint: _isLoadingTopUsers ? null : _printTopUsers,
            isExporting: _isExportingTopUsers,
            child: _isLoadingTopUsers
                ? const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
                : _topUsersError != null
                    ? SizedBox(height: 180, child: ErrorStateView(message: _topUsersError!, onRetry: _loadTopUsers))
                    : _TopUsersTable(report: _topUsersReport!),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.onDownload,
    required this.onPrint,
    required this.isExporting,
  });

  final String title;
  final Widget child;
  final VoidCallback? onDownload;
  final VoidCallback? onPrint;
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              if (isExporting)
                const Padding(
                  padding: EdgeInsets.only(right: AppSpacing.md),
                  child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2)),
                ),
              OutlinedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded, size: AppSizes.iconSm),
                label: Text(l10n.reportsScreenDownloadPdf),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onPrint,
                icon: const Icon(Icons.print_outlined, size: AppSizes.iconSm),
                label: Text(l10n.reportsScreenPrint),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          child,
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.value, required this.onTap});

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.event_rounded, size: AppSizes.iconSm),
      label: Text('$label: ${Formatters.date(value)}'),
    );
  }
}

class _SalesReportView extends StatelessWidget {
  const _SalesReportView({required this.report});

  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final days = report.days;
    final maxTickets = days.fold<int>(0, (max, d) => d.ticketCount > max ? d.ticketCount : max);
    final maxRevenue = days.fold<double>(0, (max, d) => d.revenue > max ? d.revenue : max);
    final revenueScale = maxRevenue == 0 ? 1.0 : (maxTickets == 0 ? 1.0 : maxTickets / maxRevenue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _StatTile(label: l10n.reportsScreenTotalTickets, value: '${report.totalTicketCount}', color: AppColors.primary),
            const SizedBox(width: AppSpacing.lg),
            _StatTile(label: l10n.reportsScreenTotalRevenue, value: Formatters.money(report.totalRevenue), color: AppColors.success),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (days.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text(l10n.reportsScreenNoDataForPeriod, style: theme.textTheme.bodySmall),
          )
        else
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: days.length > 10 ? (days.length / 6).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= days.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(Formatters.dayMonth(days[index].date), style: theme.textTheme.labelSmall),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    spots: [for (var i = 0; i < days.length; i++) FlSpot(i.toDouble(), days[i].ticketCount.toDouble())],
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    spots: [for (var i = 0; i < days.length; i++) FlSpot(i.toDouble(), days[i].revenue * revenueScale)],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _LegendDot(color: AppColors.primary, label: l10n.reportsScreenTicketCountLegend),
            const SizedBox(width: AppSpacing.lg),
            _LegendDot(color: AppColors.success, label: l10n.reportsScreenRevenueLegend),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _TopUsersTable extends StatelessWidget {
  const _TopUsersTable({required this.report});

  final TopUsersReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (report.users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Text(AppLocalizations.of(context)!.reportsScreenNoPurchaseData, style: theme.textTheme.bodySmall),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < report.users.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: i == 0 ? AppColors.warning.withValues(alpha: 0.18) : AppColors.surfaceAlt,
                  child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.w700, color: i == 0 ? AppColors.warning : AppColors.textSecondary)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.users[i].fullName, style: theme.textTheme.titleSmall),
                      Text(report.users[i].email, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Expanded(child: Text(Formatters.tickets(report.users[i].ticketCount), style: theme.textTheme.bodyMedium)),
                Text(Formatters.money(report.users[i].totalSpent), style: theme.textTheme.titleSmall?.copyWith(color: AppColors.success)),
              ],
            ),
          ),
      ],
    );
  }
}
