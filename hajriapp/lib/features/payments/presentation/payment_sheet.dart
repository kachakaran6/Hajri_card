import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/numpad.dart';
import '../../projects/repositories/projects_repository.dart';
import '../../workers/models/worker.dart';
import '../models/transaction.dart';
import '../repositories/transactions_repository.dart';
import '../../workers/repositories/workers_repository.dart';

class PaymentSheet extends HookConsumerWidget {
  final Worker worker;
  final String? initialType; // 'Salary' or 'Advance'

  const PaymentSheet({super.key, required this.worker, this.initialType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amountText = useState('');
    final activeProject = ref.watch(activeProjectProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionType = useState<String>(initialType ?? 'Salary');

    void handleSave() async {
      final amount = double.tryParse(amountText.value);
      if (amount == null || amount <= 0) return;

      final transaction = Transaction(
        id: const Uuid().v4(),
        contractorId: '',
        workerId: worker.id,
        projectId: activeProject?.id,
        transactionType: transactionType.value,
        amount: amount,
        paymentMethod: 'Cash',
        transactionDate: DateTime.now().toIso8601String().substring(0, 10),
      );

      final navigator = Navigator.of(context);
      await ref
          .read(transactionsRepositoryProvider)
          .saveTransaction(transaction);
      ref.invalidate(
        transactionsStreamProvider({'workerId': worker.id, 'projectId': null}),
      );
      ref.invalidate(workerBalanceProvider(worker.id));
      navigator.pop();
    }

    void onKeyTap(String key) {
      if (amountText.value.length < 7) {
        amountText.value += key;
      }
    }

    void onBackspace() {
      if (amountText.value.isNotEmpty) {
        amountText.value = amountText.value.substring(
          0,
          amountText.value.length - 1,
        );
      }
    }

    void onClear() {
      amountText.value = '';
    }

    Future<bool> handlePop() async {
      if (amountText.value.isNotEmpty) {
        final exit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text('Unsaved changes will be lost — Exit anyway?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('EXIT', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return exit ?? false;
      }
      return true;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await handlePop()) {
          navigator.pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'Salary',
                  label: Text('ચુકવણી (Payment)'), // Salary
                ),
                ButtonSegment<String>(
                  value: 'Advance',
                  label: Text('ઉધાર (Advance)'),
                ),
              ],
              selected: {transactionType.value},
              onSelectionChanged: (Set<String> newSelection) {
                transactionType.value = newSelection.first;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Worker: ${worker.fullName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Display Amount
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '₹ ${amountText.value.isEmpty ? "0" : amountText.value}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: transactionType.value == 'Salary'
                      ? AppColors.success
                      : AppColors.warning,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Custom Numpad
            Numpad(
              onKeyTap: onKeyTap,
              onBackspace: onBackspace,
              onClear: onClear,
              onSubmit: handleSave,
              submitLabel: 'SAVE ${transactionType.value.toUpperCase()}',
              submitColor: transactionType.value == 'Salary'
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}
