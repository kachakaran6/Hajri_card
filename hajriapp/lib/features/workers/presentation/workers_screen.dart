import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';

import '../../projects/repositories/projects_repository.dart';

import '../../attendance/models/attendance.dart';
import '../../attendance/repositories/attendance_repository.dart';
import '../../payments/presentation/payment_sheet.dart';
import '../models/worker.dart';
import '../repositories/workers_repository.dart';
import 'package:intl/intl.dart';
import 'package:hajriapp/l10n/app_localizations.dart';

// Selection state for multi-select
final selectedWorkerIdsProvider = StateProvider<List<String>>((ref) => []);
final isMultiSelectModeProvider = StateProvider<bool>((ref) => false);

class WorkersScreen extends HookConsumerWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(workersStreamProvider);

    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final isMultiSelect = ref.watch(isMultiSelectModeProvider);
    final selectedIds = ref.watch(selectedWorkerIdsProvider);
    final activeProject = ref.watch(activeProjectProvider);
    final todaysAttendance = ref.watch(
      attendanceStreamProvider(activeProject?.id),
    );

    useEffect(() {
      searchController.addListener(() {
        searchQuery.value = searchController.text.toLowerCase();
      });
      return null;
    }, [searchController]);

    final filteredWorkers = workers.where((w) {
      if (searchQuery.value.isEmpty) return true;
      return w.fullName.toLowerCase().contains(searchQuery.value) ||
          (w.phone?.contains(searchQuery.value) ?? false) ||
          (w.village?.toLowerCase().contains(searchQuery.value) ?? false);
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    void showAddWorkerSheet([Worker? worker]) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddWorkerSheet(worker: worker),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            isMultiSelect
                ? '${selectedIds.length} ${AppLocalizations.of(context)!.selectedWorkers}'
                : AppLocalizations.of(context)!.allWorkers,
          ),
          actions: [
            if (isMultiSelect) ...[
              IconButton(
                icon: const Icon(Icons.select_all),
                onPressed: () {
                  final allIds = filteredWorkers.map((w) => w.id).toList();
                  ref.read(selectedWorkerIdsProvider.notifier).state = allIds;
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(isMultiSelectModeProvider.notifier).state = false;
                  ref.read(selectedWorkerIdsProvider.notifier).state = [];
                },
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  // Future QR Scanner integration
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.scanQrCode),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => showAddWorkerSheet(),
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            // Search & Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),

            // Bulk Actions Bar (when multi-select is active)
            if (isMultiSelect && selectedIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Card(
                  color: AppColors.primary.withAlpha(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.primary, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          icon: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.present,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            void handleBulkAction(String status) async {
                              if (selectedIds.isEmpty) return;
                              final activeProject = ref.read(
                                activeProjectProvider,
                              );
                              final futures = <Future<void>>[];

                              for (final workerId in selectedIds) {
                                final existingAtt = todaysAttendance
                                    .where((a) => a.workerId == workerId)
                                    .firstOrNull;
                                final attendance =
                                    existingAtt?.copyWith(
                                      status: status,
                                      projectId: activeProject?.id,
                                    ) ??
                                    Attendance(
                                      id: const Uuid().v4(),
                                      contractorId: '',
                                      workerId: workerId,
                                      projectId: activeProject?.id,
                                      date: DateTime.now()
                                          .toIso8601String()
                                          .substring(0, 10),
                                      status: status,
                                    );
                                futures.add(
                                  ref
                                      .read(attendanceRepositoryProvider)
                                      .saveAttendance(attendance),
                                );
                              }

                              await Future.wait(futures);

                              for (final workerId in selectedIds) {
                                ref.invalidate(workerBalanceProvider(workerId));
                              }
                              ref.invalidate(
                                attendanceStreamProvider(activeProject?.id),
                              );

                              ref
                                      .read(isMultiSelectModeProvider.notifier)
                                      .state =
                                  false;
                              ref
                                      .read(selectedWorkerIdsProvider.notifier)
                                      .state =
                                  [];
                            }

                            handleBulkAction('Present');
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: AppColors.error,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.absent,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            void handleBulkAction(String status) async {
                              if (selectedIds.isEmpty) return;
                              final activeProject = ref.read(
                                activeProjectProvider,
                              );
                              final futures = <Future<void>>[];

                              for (final workerId in selectedIds) {
                                final existingAtt = todaysAttendance
                                    .where((a) => a.workerId == workerId)
                                    .firstOrNull;
                                final attendance =
                                    existingAtt?.copyWith(
                                      status: status,
                                      projectId: activeProject?.id,
                                    ) ??
                                    Attendance(
                                      id: const Uuid().v4(),
                                      contractorId: '',
                                      workerId: workerId,
                                      projectId: activeProject?.id,
                                      date: DateTime.now()
                                          .toIso8601String()
                                          .substring(0, 10),
                                      status: status,
                                    );
                                futures.add(
                                  ref
                                      .read(attendanceRepositoryProvider)
                                      .saveAttendance(attendance),
                                );
                              }

                              await Future.wait(futures);

                              for (final workerId in selectedIds) {
                                ref.invalidate(workerBalanceProvider(workerId));
                              }
                              ref.invalidate(
                                attendanceStreamProvider(activeProject?.id),
                              );

                              ref
                                      .read(isMultiSelectModeProvider.notifier)
                                      .state =
                                  false;
                              ref
                                      .read(selectedWorkerIdsProvider.notifier)
                                      .state =
                                  [];
                            }

                            handleBulkAction('Absent');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Workers List
            Expanded(
              child: filteredWorkers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.emptyLabourList,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredWorkers.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final worker = filteredWorkers[index];
                        final isSelected = selectedIds.contains(worker.id);

                        // Check if already marked for today
                        final existingAtt = todaysAttendance
                            .where((a) => a.workerId == worker.id)
                            .firstOrNull;
                        bool isMarked = false;
                        bool isPresent = false;
                        String timeStr = '';

                        if (existingAtt != null) {
                          isMarked = true;
                          isPresent = existingAtt.status == 'Present';
                          if (existingAtt.createdAt != null) {
                            try {
                              final dt = DateTime.parse(
                                existingAtt.createdAt!,
                              ).toLocal();
                              timeStr = DateFormat('hh:mm a').format(dt);
                            } catch (e) {
                              timeStr = '';
                            }
                          }
                        }

                        return _WorkerCard(
                          worker: worker,
                          existingAtt: existingAtt,
                          isSelected: isSelected,
                          isMarked: isMarked,
                          isPresent: isPresent,
                          timeStr: timeStr,
                          onLongPress: () {
                            ref.read(isMultiSelectModeProvider.notifier).state =
                                true;
                            ref.read(selectedWorkerIdsProvider.notifier).state =
                                [...selectedIds, worker.id];
                          },
                          onTap: () {
                            if (isMultiSelect) {
                              final updated = List<String>.from(selectedIds);
                              if (isSelected) {
                                updated.remove(worker.id);
                              } else {
                                updated.add(worker.id);
                              }
                              ref
                                      .read(selectedWorkerIdsProvider.notifier)
                                      .state =
                                  updated;
                              if (updated.isEmpty) {
                                ref
                                        .read(
                                          isMultiSelectModeProvider.notifier,
                                        )
                                        .state =
                                    false;
                              }
                            } else {
                              context.push('/workers/${worker.id}');
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: isMultiSelect
            ? null
            : FloatingActionButton(
                onPressed: () => showAddWorkerSheet(),
                child: const Icon(Icons.add),
              ),
      );}
}

class AddWorkerSheet extends HookConsumerWidget {
  final Worker? worker;
  const AddWorkerSheet({super.key, this.worker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(
      text: worker?.fullName ?? '',
    );
    final wageController = useTextEditingController(
      text: worker != null ? worker!.dailyWage.toStringAsFixed(0) : '',
    );
    final isSubmitting = useState(false);

    void saveWorker() async {
      if (!formKey.currentState!.validate()) return;
      isSubmitting.value = true;
      try {
        final newWorker = Worker(
          id: worker?.id ?? const Uuid().v4(),
          contractorId: worker?.contractorId ?? '',
          fullName: nameController.text.trim(),
          dailyWage: double.tryParse(wageController.text) ?? 0,
          joiningDate: worker?.joiningDate ?? DateTime.now().toIso8601String(),
        );

        await ref.read(workersRepositoryProvider).saveWorker(newWorker);
        ref.invalidate(workersStreamProvider);
        if (context.mounted) Navigator.pop(context);
      } finally {
        isSubmitting.value = false;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              worker == null
                  ? AppLocalizations.of(context)!.addLabour
                  : AppLocalizations.of(context)!.edit,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fullName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: wageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.dailyWage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixText: '₹ ',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isSubmitting.value ? null : saveWorker,
              child: isSubmitting.value
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerCard extends HookConsumerWidget {
  final Worker worker;
  final Attendance? existingAtt;
  final bool isSelected;
  final bool isMarked;
  final bool isPresent;
  final String timeStr;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const _WorkerCard({
    required this.worker,
    this.existingAtt,
    required this.isSelected,
    required this.isMarked,
    required this.isPresent,
    required this.timeStr,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(workerBalanceProvider(worker.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFlashing = useState(false);

    void handleMarkPresent() {
      if (isMarked && isPresent) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already marked present today')),
        );
        return;
      }

      HapticFeedback.mediumImpact();
      isFlashing.value = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (context.mounted) isFlashing.value = false;
      });

      final activeProject = ref.read(activeProjectProvider);

      final attendance =
          existingAtt?.copyWith(
            status: 'Present',
            projectId: activeProject?.id,
          ) ??
          Attendance(
            id: const Uuid().v4(),
            contractorId: '',
            workerId: worker.id,
            projectId: activeProject?.id,
            date: DateTime.now().toIso8601String().substring(0, 10),
            status: 'Present',
          );

      ref.read(attendanceRepositoryProvider).saveAttendance(attendance).then((
        _,
      ) {
        // Manually invalidate providers to refresh data since realtime may be disabled
        ref.invalidate(attendanceStreamProvider(activeProject?.id));
        ref.invalidate(workerBalanceProvider(worker.id));
      });
    }

    return Slidable(
      key: ValueKey(worker.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {},
          closeOnCancel: true,
          dismissThreshold: 0.05,
          confirmDismiss: () async {
            handleMarkPresent();
            return false;
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) => handleMarkPresent(),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Present',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PaymentSheet(worker: worker),
              );
            },
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            icon: Icons.currency_rupee,
            label: 'પે (Pay)',
          ),
          SlidableAction(
            onPressed: (context) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddWorkerSheet(worker: worker),
              );
            },
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'એડિટ (Edit)',
          ),
        ],
      ),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isFlashing.value
                ? AppColors.success.withAlpha(80)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              child: Row(
                children: [
                  // Worker avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        worker.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Worker details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                worker.fullName,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isMarked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isPresent
                                      ? AppColors.success.withAlpha(30)
                                      : AppColors.error.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isPresent
                                        ? AppColors.success
                                        : AppColors.error,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPresent
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 10,
                                      color: isPresent
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPresent ? 'Present' : 'Absent',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isPresent
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '₹${worker.dailyWage.toStringAsFixed(0)}/day',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (isMarked && timeStr.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Balance indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${balance.abs().toStringAsFixed(0)}',
                        style: TextStyle(
                          color: balance > 0
                              ? AppColors.success
                              : (balance < 0 ? AppColors.error : Colors.grey),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        balance > 0
                            ? 'To Pay'
                            : (balance < 0 ? 'Advance' : 'Clear'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
