import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    @JsonKey(name: 'contractor_id') required String contractorId,
    @JsonKey(name: 'worker_id') required String workerId,
    @JsonKey(name: 'project_id') String? projectId,
    @JsonKey(name: 'transaction_type') required String transactionType, // 'Salary', 'Advance', 'Bonus', 'Deduction', 'Adjustment'
    @Default(0.0) double amount,
    @JsonKey(name: 'payment_method') required String paymentMethod, // 'Cash', 'UPI', 'Bank', 'Cheque'
    @JsonKey(name: 'reference_number') String? referenceNumber,
    @JsonKey(name: 'transaction_date') required String transactionDate,
    String? remarks,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
