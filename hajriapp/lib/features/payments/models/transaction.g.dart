// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      contractorId: json['contractor_id'] as String,
      workerId: json['worker_id'] as String,
      projectId: json['project_id'] as String?,
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String,
      referenceNumber: json['reference_number'] as String?,
      transactionDate: json['transaction_date'] as String,
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contractor_id': instance.contractorId,
      'worker_id': instance.workerId,
      'project_id': instance.projectId,
      'transaction_type': instance.transactionType,
      'amount': instance.amount,
      'payment_method': instance.paymentMethod,
      'reference_number': instance.referenceNumber,
      'transaction_date': instance.transactionDate,
      'remarks': instance.remarks,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
