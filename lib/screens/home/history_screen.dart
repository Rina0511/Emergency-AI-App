import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
//import '../common/app_bottom_nav.dart';

import '../../l10n/app_localizations.dart';
import '../../routes.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Accident',
    'Fire',
    'Medical',
    'Crime',
    'Hazard',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFEAF1FB);

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final softBlue = isDark ? const Color(0xFF1E2A44) : const Color(0xFFEAF1FF);

    const primaryBlue = Color(0xFF2F6FE4);

    if (user == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(l10n.login, style: TextStyle(color: textDark)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('emergency_reports')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorState(error: snapshot.error.toString());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            final allReports = (snapshot.data?.docs ?? [])
                .map(
                  (doc) => {
                    'id': doc.id,
                    ...((doc.data() as Map<String, dynamic>?) ?? {}),
                  },
                )
                .toList();

            allReports.sort((a, b) {
              final aTime = a['createdAt'];
              final bTime = b['createdAt'];

              if (aTime is Timestamp && bTime is Timestamp) {
                return bTime.compareTo(aTime);
              }
              return 0;
            });

            final filteredReports = _selectedFilter == 'All'
                ? allReports
                : allReports.where((data) {
                    final type = (data['emergencyType'] ?? '')
                        .toString()
                        .toLowerCase();
                    return type == _selectedFilter.toLowerCase();
                  }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.mainShell,
                              (route) => false,
                              arguments: 0,
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Report History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: allReports.isEmpty
                            ? null
                            : () => _downloadAllReportsPdf(allReports),
                        icon: const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: primaryBlue,
                        ),
                        tooltip: 'Download PDF',
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _filters[index];
                      final selected = _selectedFilter == item;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = item);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? primaryBlue : cardColor,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.14 : 0.04,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: selected ? Colors.white : textDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: filteredReports.isEmpty
                      ? _EmptyState(
                          message: _selectedFilter == 'All'
                              ? l10n.noReportsYet
                              : 'No $_selectedFilter reports yet',
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
                          itemCount: filteredReports.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 13),
                          itemBuilder: (context, index) {
                            final data = filteredReports[index];
                            return _HistoryCard(
                              data: data,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.reportDetail,
                                  arguments: data,
                                );
                              },
                              onPdf: () => _downloadSingleReportPdf(data),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _downloadAllReportsPdf(
    List<Map<String, dynamic>> reports,
  ) async {
    final pdfBytes = await _buildReportsPdf(
      title: 'Emergency Report History',
      reports: reports,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'emergency_report_history.pdf',
    );
  }

  Future<void> _downloadSingleReportPdf(Map<String, dynamic> report) async {
    final pdfBytes = await _buildReportsPdf(
      title: 'Emergency Report',
      reports: [report],
    );

    final type = (report['emergencyType'] ?? 'emergency').toString();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${type.toLowerCase()}_report.pdf',
    );
  }

  Future<Uint8List> _buildReportsPdf({
    required String title,
    required List<Map<String, dynamic>> reports,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              'Generated by Emergency AI App',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 22),
            ...reports.map((data) {
              final type = (data['emergencyType'] ?? 'Emergency').toString();
              final severity = (data['severity'] ?? 'High').toString();
              final confidence =
                  (data['confidence'] ?? data['aiConfidence'] ?? '-')
                      .toString();
              final status = (data['status'] ?? 'Sent').toString();
              final location = (data['location'] ?? 'Location not available')
                  .toString();
              final responders = data['responders'] is List
                  ? (data['responders'] as List).join(', ')
                  : (data['responders'] ?? '-').toString();
              final createdAt = _formatDateTime(data['createdAt']);

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      type,
                      style: pw.TextStyle(
                        fontSize: 17,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _pdfRow('Date', createdAt),
                    _pdfRow('Status', status),
                    _pdfRow('Severity', severity),
                    _pdfRow('AI Confidence', '$confidence%'),
                    _pdfRow('Location', location),
                    _pdfRow('Recommended Responders', responders),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
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

  static String _formatDateTime(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    if (value is DateTime) {
      return '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')} '
          '${value.hour.toString().padLeft(2, '0')}:'
          '${value.minute.toString().padLeft(2, '0')}';
    }

    return 'Date not available';
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.data,
    required this.onTap,
    required this.onPdf,
  });

  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onPdf;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    final type = (data['emergencyType'] ?? 'Emergency').toString();
    final confidence = (data['confidence'] ?? data['aiConfidence'] ?? '-')
        .toString();
    final status = (data['status'] ?? 'Sent').toString();
    final createdAt = _HistoryScreenState._formatDateTime(data['createdAt']);

    final typeColor = _typeColor(type);
    final typeIcon = _typeIcon(type);
    final statusColor = _statusColor(status);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.035),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: isDark ? 0.20 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, color: typeColor, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createdAt,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: textSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: isDark ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$confidence%',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: textSoft),
              color: cardColor,
              onSelected: (value) {
                if (value == 'view') onTap();
                if (value == 'pdf') onPdf();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Text(
                    'View Details',
                    style: TextStyle(color: textDark),
                  ),
                ),
                PopupMenuItem(
                  value: 'pdf',
                  child: Text(
                    'Download PDF',
                    style: TextStyle(color: textDark),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static IconData _typeIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('fire')) return Icons.local_fire_department_outlined;
    if (value.contains('medical')) return Icons.monitor_heart_outlined;
    if (value.contains('crime')) return Icons.shield_outlined;
    if (value.contains('hazard')) return Icons.warning_amber_rounded;
    if (value.contains('accident')) return Icons.directions_car_outlined;

    return Icons.emergency_outlined;
  }

  static Color _typeColor(String type) {
    final value = type.toLowerCase();

    if (value.contains('fire')) return const Color(0xFFE12529);
    if (value.contains('medical')) return const Color(0xFF22C55E);
    if (value.contains('crime')) return const Color(0xFF2F6FE4);
    if (value.contains('hazard')) return const Color(0xFFF59E0B);
    if (value.contains('accident')) return const Color(0xFF2F6FE4);

    return const Color(0xFF71829E);
  }

  static Color _statusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('cancel')) return const Color(0xFF94A3B8);
    if (value.contains('false')) return const Color(0xFFF59E0B);
    if (value.contains('sent') || value.contains('submit')) {
      return const Color(0xFF22C55E);
    }

    return const Color(0xFF2F6FE4);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF162033) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);
    final textSoft = isDark ? Colors.white70 : const Color(0xFF71829E);

    const primaryBlue = Color(0xFF2F6FE4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: primaryBlue,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your submitted emergency reports will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: textSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textDark = isDark ? Colors.white : const Color(0xFF0B1B3A);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          'Failed to load history.\n\n$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
