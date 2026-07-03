import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';

import '../../projects/repositories/projects_repository.dart';

import '../../attendance/repositories/attendance_repository.dart';
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
    final todaysAttendance = ref.watch(attendanceStreamProvider(activeProject?.id));

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
        title: Text(isMultiSelect 
            ? '${selectedIds.length} ${AppLocalizations.of(context)!.selectedWorkers}' 
            : AppLocalizations.of(context)!.allWorkers),
        actions: [
          if (isMultiSelect)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(isMultiSelectModeProvider.notifier).state = false;
                ref.read(selectedWorkerIdsProvider.notifier).state = [];
              },
            )
          else ...[
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
          ]
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                        icon: const Icon(Icons.check_circle, color: AppColors.success),
                        label: Text(
                          AppLocalizations.of(context)!.present,
                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          // Phase 5: Bulk Present
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.remove_circle, color: AppColors.error),
                        label: Text(
                          AppLocalizations.of(context)!.absent,
                          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          // Phase 5: Bulk Absent
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
                      final existingAtt = todaysAttendance.where((a) => a.workerId == worker.id).firstOrNull;
                      final isMarked = existingAtt != null;
                      final isPresent = existingAtt?.status == 'Present' || existingAtt?.status == 'Half Day' || existingAtt?.status == 'Overtime';
                      
                      String timeStr = '';
                      if (existingAtt?.createdAt != null) {
                        try {
                          final dt = DateTime.parse(existingAtt!.createdAt!);
                          timeStr = DateFormat('hh:mm a').format(dt);
                        } catch (e) {
                          timeStr = '';
                        }
                      }

                      return _WorkerCard(
                        worker: worker,
                        isSelected: isSelected,
                        isMarked: isMarked,
                        isPresent: isPresent,
                        timeStr: timeStr,
                        onLongPress: () {
                          ref.read(isMultiSelectModeProvider.notifier).state = true;
                          ref.read(selectedWorkerIdsProvider.notifier).state = [...selectedIds, worker.id];
                        },
                        onTap: () {
                          if (isMultiSelect) {
                            final updated = List<String>.from(selectedIds);
                            if (isSelected) {
                              updated.remove(worker.id);
                            } else {
                              updated.add(worker.id);
                            }
                            ref.read(selectedWorkerIdsProvider.notifier).state = updated;
                            if (updated.isEmpty) {
                              ref.read(isMultiSelectModeProvider.notifier).state = false;
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
    );
  }
}

class AddWorkerSheet extends HookConsumerWidget {
  final Worker? worker;
  const AddWorkerSheet({super.key, this.worker});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: worker?.fullName ?? '');
    final wageController = useTextEditingController(text: worker != null ? worker!.dailyWage.toStringAsFixed(0) : '');
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
              worker == null ? AppLocalizations.of(context)!.addLabour : AppLocalizations.of(context)!.edit,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fullName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: wageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.dailyWage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: '₹ ',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _WorkerCard extends ConsumerWidget {
  final Worker worker;
  final bool isSelected;
  final bool isMarked;
  final bool isPresent;
  final String timeStr;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const _WorkerCard({
    required this.worker,
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

    return Slidable(
      key: ValueKey(worker.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Delete worker
              ref.read(workersRepositoryProvider).deleteWorker(worker.id);
            },
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: AppLocalizations.of(context)!.delete,
          ),
        ],
      ),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Card(
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                      Text(
                        worker.fullName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${worker.dailyWage.toStringAsFixed(0)}/day',
                        style: Theme.of(context).textTheme.bodyMedium,
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
                        color: balance > 0 ? AppColors.success : (balance < 0 ? AppColors.error : Colors.grey),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      balance > 0 ? 'To Pay' : (balance < 0 ? 'Advance' : 'Clear'),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

