import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../attendance/repositories/attendance_repository.dart';
import '../../attendance/models/attendance.dart';
import '../../attendance/models/daily_wage.dart';

import '../../payments/presentation/payment_sheet.dart';
import '../../payments/repositories/transactions_repository.dart';
import '../../projects/repositories/projects_repository.dart';
import '../../reports/models/monthly_summary.dart';

import '../repositories/workers_repository.dart';
import 'package:hajriapp/l10n/app_localizations.dart';
import 'package:printing/printing.dart';
import '../../../core/utils/pdf_generator.dart';

class WorkerDetailsScreen extends HookConsumerWidget {
  final String workerId;

  const WorkerDetailsScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(workersStreamProvider);
    final activeProject = ref.watch(activeProjectProvider);
    final workerList = workers.where((w) => w.id == workerId);

    if (workerList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Labour not found')),
      );
    }

    final worker = workerList.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch transactions
    final transactions = ref.watch(
      transactionsStreamProvider({'workerId': workerId}),
    );

    final now = DateTime.now();
    final selectedMonth = useState(now.month);
    final selectedYear = useState(now.year);

    // Watch worker attendance stream
    final workerAttendance = ref.watch(
      workerAttendanceStreamProvider(workerId),
    );

    final summaryState = useState<MonthlySummary?>(null);

    useEffect(() {
      Future<void> fetchSummary() async {
        try {
          final response = await Supabase.instance.client
              .from('monthly_summary')
              .select()
              .eq('worker_id', workerId)
              .eq('month', selectedMonth.value)
              .eq('year', selectedYear.value)
              .maybeSingle();
          if (context.mounted) {
            summaryState.value = response != null
                ? MonthlySummary.fromJson(response)
                : null;
          }
        } catch (_) {}
      }

      fetchSummary();
      return null;
    }, [selectedMonth.value, selectedYear.value]);
    final summary = summaryState.value;

    void openPaymentSheet(String type) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PaymentSheet(worker: worker, initialType: type),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(worker.fullName),
        actions: [
          if (summary != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                final pdfBytes = await PdfGenerator.generatePayslip(
                  projectName: activeProject?.name ?? 'Unknown',
                  monthYear: '${selectedMonth.value}/${selectedYear.value}',
                  summary: summary,
                  worker: worker,
                );
                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename:
                      '${worker.fullName}_Payslip_${selectedMonth.value}_${selectedYear.value}.pdf',
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Worker Profile Header Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            worker.fullName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.fullName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${worker.phone ?? "No phone"} • ${worker.village ?? "No village"}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Wage Rate: ₹${worker.dailyWage.toStringAsFixed(0)}/day',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Summary stats overview
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      label: 'Gross Wages',
                      value:
                          '₹${(summary?.grossAmount ?? 0.0).toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      label: 'Advance Taken',
                      value: '₹${(summary?.advance ?? 0.0).toStringAsFixed(0)}',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      label: 'Salary Paid',
                      value: '₹${(summary?.paid ?? 0.0).toStringAsFixed(0)}',
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context: context,
                      label: 'Balance Due',
                      value: '₹${(summary?.balance ?? 0.0).toStringAsFixed(0)}',
                      color: (summary?.balance ?? 0.0) >= 0
                          ? AppColors.success
                          : AppColors.error,
                      isBold: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Quick Cash Book Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.currency_rupee,
                        color: Colors.white,
                      ),
                      label: const Text('Pay Salary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => openPaymentSheet('Salary'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      label: const Text('Give Advance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => openPaymentSheet('Advance'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hajri Card Calendar Grid
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Hajri Card (Attendance)',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                          // Month Selector
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {
                                  if (selectedMonth.value == 1) {
                                    selectedMonth.value = 12;
                                    selectedYear.value -= 1;
                                  } else {
                                    selectedMonth.value -= 1;
                                  }
                                },
                              ),
                              Text(
                                DateFormat('MMM yyyy').format(
                                  DateTime(
                                    selectedYear.value,
                                    selectedMonth.value,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {
                                  final nowMonth = DateTime.now();
                                  if (selectedYear.value == nowMonth.year &&
                                      selectedMonth.value == nowMonth.month) {
                                    // Don't go to future months
                                    return;
                                  }
                                  if (selectedMonth.value == 12) {
                                    selectedMonth.value = 1;
                                    selectedYear.value += 1;
                                  } else {
                                    selectedMonth.value += 1;
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Weekday Headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map(
                          (day) {
                            return SizedBox(
                              width: 32,
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(height: 8),

                      // Days Grid
                      Builder(
                        builder: (context) {
                          final firstDayOffset =
                              DateTime(
                                selectedYear.value,
                                selectedMonth.value,
                                1,
                              ).weekday -
                              1;
                          final daysInMonth = DateTime(
                            selectedYear.value,
                            selectedMonth.value + 1,
                            0,
                          ).day;
                          final totalCells = firstDayOffset + daysInMonth;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: totalCells,
                            itemBuilder: (context, index) {
                              if (index < firstDayOffset) {
                                return const SizedBox.shrink();
                              }

                              final day = index - firstDayOffset + 1;
                              final dateStr =
                                  '${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

                              final dayAtt = workerAttendance.firstWhere(
                                (a) => a.date == dateStr,
                                orElse: () => Attendance(
                                  id: const Uuid().v4(),
                                  contractorId: '',
                                  workerId: workerId,
                                  projectId: activeProject?.id,
                                  date: dateStr,
                                  status: 'Absent',
                                ),
                              );

                              final hasLogged = workerAttendance.any(
                                (a) => a.date == dateStr,
                              );
                              final status = hasLogged ? dayAtt.status : 'None';

                              return InkWell(
                                onTap: () async {
                                  // Open Wage Adjustment Dialog to edit this day's attendance
                                  final wageData = await Supabase
                                      .instance
                                      .client
                                      .from('daily_wages')
                                      .select()
                                      .eq('attendance_id', dayAtt.id)
                                      .maybeSingle();
                                  final existingWage = wageData != null
                                      ? DailyWage.fromJson(wageData)
                                      : null;

                                  if (!context.mounted) return;
                                  showDialog(
                                    context: context,
                                    builder: (context) => WageAdjustmentDialog(
                                      worker: worker,
                                      attendance: dayAtt,
                                      existingWage: existingWage,
                                      onSave:
                                          (
                                            newStatus,
                                            otHours,
                                            bonus,
                                            deduction,
                                            remarks,
                                          ) async {
                                            final updated = dayAtt.copyWith(
                                              status: newStatus,
                                              projectId: activeProject?.id,
                                              overtimeHours: otHours,
                                              remarks: remarks,
                                            );
                                            await ref
                                                .read(
                                                  attendanceRepositoryProvider,
                                                )
                                                .saveAttendance(
                                                  updated,
                                                  bonus: bonus,
                                                  deduction: deduction,
                                                );
                                          },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: status == 'None'
                                        ? Colors.transparent
                                        : AppColors.getStatusBg(
                                            status,
                                          ).withAlpha(40),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: status == 'None'
                                          ? (isDark
                                                ? Colors.white12
                                                : Colors.black12)
                                          : AppColors.getStatusColor(status),
                                      width: status == 'None' ? 1 : 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$day',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: status == 'None'
                                                ? (isDark
                                                      ? Colors.white70
                                                      : Colors.black87)
                                                : AppColors.getStatusColor(
                                                    status,
                                                  ),
                                          ),
                                        ),
                                        if (status != 'None' &&
                                            status != 'Absent' &&
                                            status != 'Leave')
                                          Text(
                                            status == 'Half Day' ? '½' : 'P',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.getStatusColor(
                                                status,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Khata Ledger View
              Text(
                'Khata (Account Book)',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Builder(
                builder: (context) {
                  // Combine attendance and transactions for the selected month
                  final String monthStr =
                      '${selectedYear.value}-${selectedMonth.value.toString().padLeft(2, '0')}';

                  final monthAttendances = workerAttendance
                      .where((a) => a.date.startsWith(monthStr))
                      .toList();
                  final monthTransactions = transactions
                      .where((t) => t.transactionDate.startsWith(monthStr))
                      .toList();

                  // Create unified ledger entries
                  final List<Map<String, dynamic>> ledger = [];

                  for (final a in monthAttendances) {
                    if (a.status == 'None' ||
                        a.status == 'Absent' ||
                        a.status == 'Leave')
                      continue;
                    double earned = 0;
                    if (a.status == 'Present') earned = worker.dailyWage;
                    if (a.status == 'Half Day') earned = worker.dailyWage / 2;
                    // Add overtime if applicable
                    earned += (a.overtimeHours * worker.overtimeRate);

                    ledger.add({
                      'date': a.date,
                      'title': 'Wages (${a.status})',
                      'amount': earned,
                      'type': 'earned',
                      'icon': Icons.work,
                      'color': AppColors.primary,
                    });
                  }

                  for (final t in monthTransactions) {
                    ledger.add({
                      'date': t.transactionDate,
                      'title': t.transactionType == 'Salary'
                          ? 'Salary Paid'
                          : 'Advance Given',
                      'amount': t.amount,
                      'type': t.transactionType == 'Salary'
                          ? 'paid'
                          : 'advance',
                      'icon': t.transactionType == 'Salary'
                          ? Icons.currency_rupee
                          : Icons.arrow_upward,
                      'color': t.transactionType == 'Salary'
                          ? AppColors.success
                          : AppColors.warning,
                      'id': t.id,
                    });
                  }

                  ledger.sort(
                    (a, b) => b['date'].compareTo(a['date']),
                  ); // Newest first

                  if (ledger.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No khata entries for this month',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ledger.length,
                    itemBuilder: (context, index) {
                      final item = ledger[index];
                      final isEarned = item['type'] == 'earned';
                      final isAdvance = item['type'] == 'advance';
                      final amountColor = isEarned
                          ? AppColors.primary
                          : (isAdvance ? AppColors.warning : AppColors.success);
                      final sign = isEarned ? '+' : '-';

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
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item['color'].withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'],
                              color: item['color'],
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(DateTime.parse(item['date'])),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$sign ₹${(item['amount'] as double).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: amountColor,
                                ),
                              ),
                              if (!isEarned) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Transaction'),
                                        content: const Text(
                                          'Are you sure you want to delete this payment?',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.cancel,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                          ),
                                          TextButton(
                                            child: const Text('Delete'),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref
                                          .read(transactionsRepositoryProvider)
                                          .deleteTransaction(item['id']);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
