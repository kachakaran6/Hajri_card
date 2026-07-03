// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contractor_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContractorProfileImpl _$$ContractorProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$ContractorProfileImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      companyName: json['company_name'] as String?,
      phone: json['phone'] as String?,
      language: json['language'] as String? ?? 'en',
      currency: json['currency'] as String? ?? 'INR',
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ContractorProfileImplToJson(
        _$ContractorProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'company_name': instance.companyName,
      'phone': instance.phone,
      'language': instance.language,
      'currency': instance.currency,
      'avatar': instance.avatar,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
