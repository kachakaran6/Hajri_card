import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/localization_service.dart';
import '../../projects/repositories/projects_repository.dart';
import '../../workers/models/worker.dart';
import '../../workers/repositories/workers_repository.dart';
import '../models/attendance.dart';
import '../models/daily_wage.dart';
import '../repositories/attendance_repository.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

class AttendanceScreen extends HookConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProject = ref.watch(activeProjectProvider);
    final selectedDateStr = ref.watch(selectedAttendanceDateProvider);
    final selectedDate = DateTime.parse(selectedDateStr);

    final workers = ref.watch(workersStreamProvider);
    final attendanceList = ref.watch(attendanceStreamProvider(activeProject?.id));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Multi-selection state
    final selectedWorkers = useState<List<String>>([]);
    final isBulkMode = useState(false);

    // Keep track of last action for Undo
    final lastAction = useState<Map<String, dynamic>?>(null);

    void setAttendance(Worker worker, String status, {double workingHours = 8.0, double overtimeHours = 0.0, double bonus = 0.0, double deduction = 0.0, String? remarks}) async {
      final messenger = ScaffoldMessenger.of(context);
      final cancelText = AppLocalizations.of(context)!.cancel;
      
      final existing = attendanceList.firstWhere(
        (a) => a.workerId == worker.id,
        orElse: () => Attendance(
          id: const Uuid().v4(),
          contractorId: '',
          workerId: worker.id,
          projectId: activeProject?.id,
          date: selectedDateStr,
          status: 'Absent',
        ),
      );

      final oldStatus = existing.status;
      final oldOt = existing.overtimeHours;
      final wageData = await Supabase.instance.client.from('daily_wages').select().eq('attendance_id', existing.id).maybeSingle();
      final oldWage = wageData != null ? DailyWage.fromJson(wageData) : null;

      // Save undo state
      lastAction.value = {
        'worker': worker,
        'attendance': existing.copyWith(status: oldStatus, overtimeHours: oldOt),
        'bonus': oldWage?.bonus ?? 0.0,
        'deduction': oldWage?.deduction ?? 0.0,
      };

      HapticFeedback.lightImpact();

      final updated = existing.copyWith(
        status: status,
        projectId: activeProject?.id,
        workingHours: workingHours,
        overtimeHours: overtimeHours,
        remarks: remarks,
      );

      await ref.read(attendanceRepositoryProvider).saveAttendance(updated, bonus: bonus, deduction: deduction);

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${worker.fullName} is $status'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: cancelText.toUpperCase(), // Undo label
            textColor: AppColors.primaryLight,
            onPressed: () async {
              if (lastAction.value != null) {
                final undo = lastAction.value!['attendance'] as Attendance;
                final b = lastAction.value!['bonus'] as double;
                final d = lastAction.value!['deduction'] as double;
                await ref.read(attendanceRepositoryProvider).saveAttendance(undo, bonus: b, deduction: d);
              }
            },
          ),
        ),
      );
    }

    void handleBulkAttendance(String status) async {
      final messenger = ScaffoldMessenger.of(context);
      for (final workerId in selectedWorkers.value) {
        final workerList = workers.where((w) => w.id == workerId);
        if (workerList.isNotEmpty) {
          final worker = workerList.first;
          final existing = attendanceList.firstWhere(
            (a) => a.workerId == worker.id,
            orElse: () => Attendance(
              id: const Uuid().v4(),
              contractorId: '',
              workerId: worker.id,
              projectId: activeProject?.id,
              date: selectedDateStr,
              status: 'Absent',
            ),
          );
          final updated = existing.copyWith(
            status: status,
            projectId: activeProject?.id,
          );
          await ref.read(attendanceRepositoryProvider).saveAttendance(updated);
        }
      }
      
      messenger.showSnackBar(
        SnackBar(
          content: Text('Marked ${selectedWorkers.value.length} workers as $status'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      selectedWorkers.value = [];
      isBulkMode.value = false;
    }

    void changeDate(int days) {
      final newDate = selectedDate.add(Duration(days: days));
      ref.read(selectedAttendanceDateProvider.notifier).state =
          newDate.toIso8601String().substring(0, 10);
    }

    void showWageAdjustmentDialog(Worker worker, Attendance attendance) async {
      final wageData = await Supabase.instance.client.from('daily_wages').select().eq('attendance_id', attendance.id).maybeSingle();
      final existingWage = wageData != null ? DailyWage.fromJson(wageData) : null;
      
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => WageAdjustmentDialog(
          worker: worker,
          attendance: attendance,
          existingWage: existingWage,
          onSave: (status, otHours, bonus, deduction, remarks) {
            setAttendance(
              worker,
              status,
              overtimeHours: otHours,
              bonus: bonus,
              deduction: deduction,
              remarks: remarks,
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.todaysAttendance),
        actions: [
          if (isBulkMode.value)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                isBulkMode.value = false;
                selectedWorkers.value = [];
              },
            )
        ],
      ),
      body: Column(
        children: [
          // Date Selector Header
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 300) {
                changeDate(-1);
              } else if (details.primaryVelocity! < -300 && selectedDateStr != DateTime.now().toIso8601String().substring(0, 10)) {
                changeDate(1);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => changeDate(-1),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        ref.read(selectedAttendanceDateProvider.notifier).state =
                            picked.toIso8601String().substring(0, 10);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: selectedDateStr == DateTime.now().toIso8601String().substring(0, 10)
                        ? null
                        : () => changeDate(1),
                  ),
                ],
              ),
            ),
          ),

          // Project Selection Pill
          if (activeProject != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.business_center, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${AppLocalizations.of(context)!.projectName}: ${activeProject.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

          // Bulk Actions Buttons
          if (isBulkMode.value && selectedWorkers.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                color: AppColors.primary.withAlpha(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        onPressed: () => handleBulkAttendance('Present'),
                        child: Text(AppLocalizations.of(context)!.present),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                        onPressed: () => handleBulkAttendance('Absent'),
                        child: Text(AppLocalizations.of(context)!.absent),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Workers List with Quick Status Buttons
          Expanded(
            child: workers.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.emptyLabourList))
                : ListView.builder(
                    itemCount: workers.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, index) {
                      final worker = workers[index];
                      final attendance = attendanceList.firstWhere(
                        (a) => a.workerId == worker.id,
                        orElse: () => Attendance(
                          id: const Uuid().v4(),
                          contractorId: '',
                          workerId: worker.id,
                          projectId: activeProject?.id,
                          date: selectedDateStr,
                          status: 'Absent',
                        ),
                      );

                      final isSelected = selectedWorkers.value.contains(worker.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Slidable(
                          key: ValueKey(worker.id),
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => setAttendance(worker, 'Present'),
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                icon: Icons.check,
                                label: AppLocalizations.of(context)!.present,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => setAttendance(worker, 'Absent'),
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                icon: Icons.close,
                                label: AppLocalizations.of(context)!.absent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ],
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              onLongPress: () {
                                isBulkMode.value = true;
                                selectedWorkers.value = [...selectedWorkers.value, worker.id];
                              },
                              onTap: () {
                                if (isBulkMode.value) {
                                  final updated = List<String>.from(selectedWorkers.value);
                                  if (isSelected) {
                                    updated.remove(worker.id);
                                  } else {
                                    updated.add(worker.id);
                                  }
                                  selectedWorkers.value = updated;
                                  if (updated.isEmpty) {
                                    isBulkMode.value = false;
                                  }
                                } else {
                                  showWageAdjustmentDialog(worker, attendance);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        if (isBulkMode.value) ...[
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (val) {
                                              final updated = List<String>.from(selectedWorkers.value);
                                              if (val == true) {
                                                updated.add(worker.id);
                                              } else {
                                                updated.remove(worker.id);
                                              }
                                              selectedWorkers.value = updated;
                                              if (updated.isEmpty) {
                                                isBulkMode.value = false;
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        // Avatar placeholder
                                        CircleAvatar(
                                          backgroundColor: AppColors.primary.withAlpha(30),
                                          child: Text(
                                            worker.fullName.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                worker.fullName,
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Wage: ₹${worker.dailyWage.toStringAsFixed(0)}',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.getStatusBg(attendance.status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            context.translate(attendance.status.toLowerCase()),
                                            style: TextStyle(
                                              color: AppColors.getStatusColor(attendance.status),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!isBulkMode.value) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => setAttendance(worker, 'Present'),
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: attendance.status == 'Present' ? AppColors.success.withAlpha(40) : Colors.transparent,
                                                  border: Border.all(color: attendance.status == 'Present' ? AppColors.success : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text('P', style: TextStyle(color: attendance.status == 'Present' ? AppColors.success : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold, fontSize: 16)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => setAttendance(worker, 'Absent'),
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: attendance.status == 'Absent' ? AppColors.error.withAlpha(40) : Colors.transparent,
                                                  border: Border.all(color: attendance.status == 'Absent' ? AppColors.error : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text('A', style: TextStyle(color: attendance.status == 'Absent' ? AppColors.error : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold, fontSize: 16)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => setAttendance(worker, 'Half Day'),
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: attendance.status == 'Half Day' ? AppColors.warning.withAlpha(40) : Colors.transparent,
                                                  border: Border.all(color: attendance.status == 'Half Day' ? AppColors.warning : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text('½', style: TextStyle(color: attendance.status == 'Half Day' ? AppColors.warning : (isDark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.bold, fontSize: 16)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () => showWageAdjustmentDialog(worker, attendance),
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(Icons.more_horiz, color: isDark ? Colors.white70 : Colors.black87, size: 20),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class WageAdjustmentDialog extends HookWidget {
  final Worker worker;
  final Attendance attendance;
  final DailyWage? existingWage;
  final Function(String status, double otHours, double bonus, double deduction, String? remarks) onSave;

  const WageAdjustmentDialog({
    super.key,
    required this.worker,
    required this.attendance,
    required this.existingWage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final selectedStatus = useState(attendance.status);
    final otHoursController = useTextEditingController(text: attendance.overtimeHours.toString());
    final bonusController = useTextEditingController(text: existingWage?.bonus.toString() ?? '0.0');
    final deductionController = useTextEditingController(text: existingWage?.deduction.toString() ?? '0.0');
    final remarksController = useTextEditingController(text: attendance.remarks);

    final statusOptions = ['Present', 'Half Day', 'Absent', 'Leave', 'Holiday', 'Overtime'];

    return AlertDialog(
      title: Text(worker.fullName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedStatus.value,
              decoration: const InputDecoration(labelText: 'Attendance Status'),
              items: statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  selectedStatus.value = val;
                }
              },
            ),
            const SizedBox(height: 12),

            TextField(
              controller: otHoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Overtime Hours',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: bonusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Bonus (₹)',
                      prefixIcon: Icon(Icons.add),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: deductionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Deduction (₹)',
                      prefixIcon: Icon(Icons.remove),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.save),
          onPressed: () {
            onSave(
              selectedStatus.value,
              double.tryParse(otHoursController.text) ?? 0.0,
              double.tryParse(bonusController.text) ?? 0.0,
              double.tryParse(deductionController.text) ?? 0.0,
              remarksController.text.trim(),
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
