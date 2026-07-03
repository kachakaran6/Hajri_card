import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/constants/app_colors.dart';

import '../../../core/utils/pdf_generator.dart';
import '../../projects/repositories/projects_repository.dart';
import '../../workers/models/worker.dart';
import '../../workers/repositories/workers_repository.dart';
import '../models/monthly_summary.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

class ReportsScreen extends HookConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final selectedMonth = useState(now.month);
    final selectedYear = useState(now.year);

    final activeProject = ref.watch(activeProjectProvider);

    final workers = ref.watch(workersStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeSummariesState = useState<List<MonthlySummary>>([]);

    useEffect(() {
      Future<void> fetchSummaries() async {
        try {
          final response = await supabase.Supabase.instance.client
              .from('monthly_summary')
              .select()
              .eq('month', selectedMonth.value)
              .eq('year', selectedYear.value);
          if (context.mounted) {
            activeSummariesState.value = response
                .map((e) => MonthlySummary.fromJson(e))
                .toList();
          }
        } catch (_) {}
      }

      fetchSummaries();
      return null;
    }, [selectedMonth.value, selectedYear.value]);
    final activeSummaries = activeSummariesState.value;

    void handleGeneratePdf() async {
      if (workers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No workers found to generate report')),
        );
        return;
      }

      final monthYearStr = DateFormat(
        'MMMM yyyy',
      ).format(DateTime(selectedYear.value, selectedMonth.value));
      final projectName = activeProject?.name ?? 'All Projects';

      final pdfBytes = await PdfGenerator.generateMonthlyReport(
        title: 'Hajri Card Monthly Report',
        projectName: projectName,
        monthYear: monthYearStr,
        summaries: activeSummaries,
        workers: workers,
      );

      // Display the printing/sharing overlay
      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
        name: 'Hajri_Report_${monthYearStr.replaceAll(' ', '_')}.pdf',
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.reports)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filters Section Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Report Period',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Month Dropdown
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedMonth.value,
                              decoration: const InputDecoration(
                                labelText: 'Month',
                              ),
                              items: List.generate(12, (index) => index + 1)
                                  .map((m) {
                                    return DropdownMenuItem(
                                      value: m,
                                      child: Text(
                                        DateFormat(
                                          'MMMM',
                                        ).format(DateTime(2026, m)),
                                      ),
                                    );
                                  })
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  selectedMonth.value = val;
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Year Dropdown
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedYear.value,
                              decoration: const InputDecoration(
                                labelText: 'Year',
                              ),
                              items: [2025, 2026, 2027].map((y) {
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text('$y'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  selectedYear.value = val;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Generate Button
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                        ),
                        label: const Text('Generate PDF Summary'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: handleGeneratePdf,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Summaries list
              Text(
                'Labour Summaries (${activeSummaries.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: activeSummaries.isEmpty
                    ? Center(
                        child: Text(
                          'No summaries generated for this period. Mark attendance or payments first!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: activeSummaries.length,
                        itemBuilder: (context, index) {
                          final summary = activeSummaries[index];
                          final worker = workers.firstWhere(
                            (w) => w.id == summary.workerId,
                            orElse: () => Worker(
                              id: '',
                              contractorId: '',
                              fullName: 'Unknown',
                              dailyWage: 0,
                              joiningDate: '',
                            ),
                          );

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                worker.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Present: ${summary.presentDays.toStringAsFixed(0)}d • OT: ${summary.overtimeHours.toStringAsFixed(0)}h',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Due: ₹${summary.balance.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: summary.balance >= 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                  Text(
                                    'Gross: ₹${summary.grossAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
