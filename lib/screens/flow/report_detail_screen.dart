import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';
import '../common/app_bottom_nav.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late Map<String, dynamic> report;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    report =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};
  }

  String get reportId => (report['id'] ?? '').toString();

  String _value(String key, String fallback) {
    return (report[key] ?? fallback).toString();
  }

  String _dateText(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate();
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return value?.toString() ?? 'Date not available';
  }

  List<String> _messageSentContacts(Map<String, dynamic> report) {
    final rawContacts =
        report['messageSentTo'] ??
        report['sentTo'] ??
        report['emergencyContacts'] ??
        report['contacts'];

    if (rawContacts is List) {
      final names = rawContacts
          .map((item) {
            if (item is Map && item['name'] != null) {
              return item['name'].toString();
            }
            return item.toString();
          })
          .where((name) => name.trim().isNotEmpty)
          .toSet()
          .toList();

      if (names.isNotEmpty) return names;
    }

    return ['Not available'];
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    final type = _value('emergencyType', _value('type', 'Accident'));
    final confidence = _value('confidence', '95');
    final severity = _value('severity', 'High');
    final timestamp = _dateText(report['createdAt'] ?? report['dateTime']);
    final location = _value('location', 'Location not available');
    final status = _value('status', 'AI detected');

    final summary = _value(
      'summary',
      'The AI analysis detected a possible $type emergency from the submitted image. The situation may require quick action and proper emergency response.',
    );

    final evidence = report['evidence'] is List
        ? (report['evidence'] as List).map((e) => e.toString()).toList()
        : <String>[
            'Possible vehicle impact or emergency scene detected',
            'Risk level estimated from image analysis',
          ];

    final responders = report['responders'] is List
        ? (report['responders'] as List).map((e) => e.toString()).toList()
        : <String>['Ambulance', 'Police'];

    final equipment = report['equipment'] is List
        ? (report['equipment'] as List).map((e) => e.toString()).toList()
        : <String>['First aid kit', 'Warning triangle', 'Torchlight'];

    final safetySteps = report['safetySteps'] is List
        ? (report['safetySteps'] as List).map((e) => e.toString()).toList()
        : <String>[
            'Stay away from danger if possible',
            'Call 999 if immediate help is needed',
            'Share your location with emergency contacts',
            'Do not move injured people unless there is immediate danger',
          ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            'Emergency AI Report Detail',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated emergency analysis report',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            '1. AI Prediction Summary',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _pdfRow('Emergency Type', type),
          _pdfRow('Confidence Level', '$confidence%'),
          _pdfRow('Severity', severity),
          _pdfRow('Timestamp', timestamp),
          _pdfRow('Location', location),
          _pdfRow('Status', status),
          pw.SizedBox(height: 18),
          pw.Text(
            '2. What AI Detected',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(summary, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 14),
          pw.Text(
            'Detected Evidence:',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...evidence.map((e) => pw.Bullet(text: e)),
          pw.SizedBox(height: 14),
          pw.Text(
            '3. Recommended Responders',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...responders.map((r) => pw.Bullet(text: r)),
          pw.SizedBox(height: 14),
          pw.Text(
            '4. Suggested Emergency Equipment',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...equipment.map((e) => pw.Bullet(text: e)),
          pw.SizedBox(height: 14),
          pw.Text(
            '5. Safety Guidance',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...safetySteps.map((s) => pw.Bullet(text: s)),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'Emergency reminder: If the situation is dangerous or life-threatening, call 999 immediately.',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'emergency_report_detail.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  Future<void> _markFalseAlarm() async {
    if (reportId.isEmpty) {
      _showSnack('Report ID not found.');
      return;
    }

    await FirebaseFirestore.instance
        .collection('emergency_reports')
        .doc(reportId)
        .set({
          'status': 'False Alarm',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    setState(() {
      report['status'] = 'False Alarm';
    });

    _showSnack('Marked as false alarm.');
  }

  Future<void> _deleteRecord() async {
    if (reportId.isEmpty) {
      _showSnack('Report ID not found.');
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Record?',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This emergency report will be deleted permanently.',
          style: TextStyle(color: textSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE12529),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('emergency_reports')
        .doc(reportId)
        .delete();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mainShell,
      (route) => false,
      arguments: 4,
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final type = _value('emergencyType', _value('type', l10n.accident));
    final dateTime = _dateText(report['createdAt'] ?? report['dateTime']);
    final status = _value('status', l10n.sent);
    final confidence = _value('confidence', '95');
    final severity = _value(
      'severity',
      _severityFromConfidence(confidence, l10n),
    );
    final location = _value('location', '3.1390° N, 101.6869° E');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final innerCardColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF5F8FD);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final placeholderIconColor = isDark
        ? Colors.white38
        : const Color(0xFF7E8DA7);

    final falseAlarmBg = isDark
        ? const Color(0xFF2A2112)
        : const Color(0xFFF3F4F6);

    final deleteBg = isDark ? const Color(0xFF2A1720) : const Color(0xFFFBECEE);

    const primaryBlue = Color(0xFF2F6FE4);

    final statusStyle = _statusStyle(context, status);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.reportDetailTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: innerCardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    _iconForType(type, l10n),
                    size: 52,
                    color: placeholderIconColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiPrediction,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PredictionRow(
                      icon: Icons.warning_amber_rounded,
                      label: l10n.type,
                      value: type,
                    ),
                    const SizedBox(height: 14),
                    _PredictionRow(
                      icon: Icons.check_circle_outline,
                      label: l10n.confidenceLevel,
                      value: confidence,
                    ),
                    const SizedBox(height: 14),
                    _SeverityRow(label: l10n.severity, value: severity),
                    const SizedBox(height: 14),
                    _PredictionRow(
                      icon: Icons.access_time,
                      label: l10n.timestamp,
                      value: dateTime,
                    ),
                    const SizedBox(height: 14),
                    _PredictionRow(
                      icon: Icons.location_on_outlined,
                      label: l10n.location,
                      value: location,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_outline, color: textDark, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.messageSentTo,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _messageSentContacts(report).map((name) {
                        return _ContactChip(name: name);
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.status,
                      style: TextStyle(
                        fontSize: 16,
                        color: textSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusStyle.$1,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: statusStyle.$2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _ActionButton(
                onPressed: _exportPdf,
                icon: Icons.download_outlined,
                label: l10n.exportPdf,
                foregroundColor: primaryBlue,
                backgroundColor: cardColor,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                onPressed: _markFalseAlarm,
                icon: Icons.outlined_flag_outlined,
                label: l10n.markFalseAlarm,
                foregroundColor: const Color(0xFFF59E0B),
                backgroundColor: falseAlarmBg,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                onPressed: _deleteRecord,
                icon: Icons.delete_outline,
                label: l10n.deleteRecord,
                foregroundColor: const Color(0xFFE53935),
                backgroundColor: deleteBg,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  static (Color, Color) _statusStyle(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (status == l10n.falseAlarm || status == 'False Alarm') {
      return (
        isDark ? const Color(0xFF2A2112) : const Color(0xFFFFF4E5),
        const Color(0xFFF59E0B),
      );
    }

    if (status == l10n.cancelled || status == 'Cancelled') {
      return (
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        isDark ? Colors.white60 : const Color(0xFF64748B),
      );
    }

    return (
      isDark ? const Color(0xFF123524) : const Color(0xFFE8F8EC),
      const Color(0xFF34A853),
    );
  }

  static IconData _iconForType(String type, AppLocalizations l10n) {
    final value = type.toLowerCase();

    if (value == l10n.fire.toLowerCase() || value == 'fire') {
      return Icons.local_fire_department_outlined;
    }
    if (value == l10n.medical.toLowerCase() || value == 'medical') {
      return Icons.favorite_border;
    }
    if (value == l10n.crime.toLowerCase() || value == 'crime') {
      return Icons.shield_outlined;
    }
    if (value == l10n.hazard.toLowerCase() || value == 'hazard') {
      return Icons.warning_amber_rounded;
    }
    return Icons.directions_car_outlined;
  }

  static String _severityFromConfidence(
    String confidence,
    AppLocalizations l10n,
  ) {
    final value = double.tryParse(confidence.replaceAll('%', '')) ?? 0;
    if (value >= 85) return l10n.high;
    if (value >= 60) return l10n.medium;
    return l10n.low;
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _PredictionRow extends StatelessWidget {
  const _PredictionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              color: textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.8,
              color: textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeverityRow extends StatelessWidget {
  const _SeverityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const dangerRed = Color(0xFFE12529);

    return Row(
      children: [
        const Icon(Icons.error_outline, color: dangerRed, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              color: textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.8,
            color: dangerRed,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chipBg = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
    );
  }
}
