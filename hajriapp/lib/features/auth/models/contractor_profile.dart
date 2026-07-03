import 'package:freezed_annotation/freezed_annotation.dart';

part 'contractor_profile.freezed.dart';
part 'contractor_profile.g.dart';

@freezed
class ContractorProfile with _$ContractorProfile {
  const factory ContractorProfile({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'company_name') String? companyName,
    String? phone,
    @Default('en') String language,
    @Default('INR') String currency,
    String? avatar,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ContractorProfile;

  factory ContractorProfile.fromJson(Map<String, dynamic> json) =>
      _$ContractorProfileFromJson(json);
}
