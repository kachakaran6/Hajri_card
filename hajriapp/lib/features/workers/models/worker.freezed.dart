// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Worker _$WorkerFromJson(Map<String, dynamic> json) {
  return _Worker.fromJson(json);
}

/// @nodoc
mixin _$Worker {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'contractor_id')
  String get contractorId => throw _privateConstructorUsedError;
  String? get photo => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_code')
  String? get workerCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'father_name')
  String? get fatherName => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get village => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  @JsonKey(name: 'joining_date')
  String get joiningDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'daily_wage')
  double get dailyWage => throw _privateConstructorUsedError;
  @JsonKey(name: 'overtime_rate')
  double get overtimeRate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'default_project')
  String? get defaultProject => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'emergency_contact')
  String? get emergencyContact => throw _privateConstructorUsedError;
  @JsonKey(name: 'bank_name')
  String? get bankName => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_number')
  String? get accountNumber => throw _privateConstructorUsedError;
  String? get ifsc => throw _privateConstructorUsedError;
  @JsonKey(name: 'upi_id')
  String? get upiId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkerCopyWith<Worker> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkerCopyWith<$Res> {
  factory $WorkerCopyWith(Worker value, $Res Function(Worker) then) =
      _$WorkerCopyWithImpl<$Res, Worker>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'contractor_id') String contractorId,
      String? photo,
      @JsonKey(name: 'worker_code') String? workerCode,
      @JsonKey(name: 'full_name') String fullName,
      String? phone,
      @JsonKey(name: 'father_name') String? fatherName,
      String? address,
      String? village,
      String? city,
      String? state,
      @JsonKey(name: 'joining_date') String joiningDate,
      @JsonKey(name: 'daily_wage') double dailyWage,
      @JsonKey(name: 'overtime_rate') double overtimeRate,
      String status,
      @JsonKey(name: 'default_project') String? defaultProject,
      String? notes,
      @JsonKey(name: 'emergency_contact') String? emergencyContact,
      @JsonKey(name: 'bank_name') String? bankName,
      @JsonKey(name: 'account_number') String? accountNumber,
      String? ifsc,
      @JsonKey(name: 'upi_id') String? upiId,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class _$WorkerCopyWithImpl<$Res, $Val extends Worker>
    implements $WorkerCopyWith<$Res> {
  _$WorkerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractorId = null,
    Object? photo = freezed,
    Object? workerCode = freezed,
    Object? fullName = null,
    Object? phone = freezed,
    Object? fatherName = freezed,
    Object? address = freezed,
    Object? village = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? joiningDate = null,
    Object? dailyWage = null,
    Object? overtimeRate = null,
    Object? status = null,
    Object? defaultProject = freezed,
    Object? notes = freezed,
    Object? emergencyContact = freezed,
    Object? bankName = freezed,
    Object? accountNumber = freezed,
    Object? ifsc = freezed,
    Object? upiId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contractorId: null == contractorId
          ? _value.contractorId
          : contractorId // ignore: cast_nullable_to_non_nullable
              as String,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      workerCode: freezed == workerCode
          ? _value.workerCode
          : workerCode // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      fatherName: freezed == fatherName
          ? _value.fatherName
          : fatherName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      village: freezed == village
          ? _value.village
          : village // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      joiningDate: null == joiningDate
          ? _value.joiningDate
          : joiningDate // ignore: cast_nullable_to_non_nullable
              as String,
      dailyWage: null == dailyWage
          ? _value.dailyWage
          : dailyWage // ignore: cast_nullable_to_non_nullable
              as double,
      overtimeRate: null == overtimeRate
          ? _value.overtimeRate
          : overtimeRate // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      defaultProject: freezed == defaultProject
          ? _value.defaultProject
          : defaultProject // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      ifsc: freezed == ifsc
          ? _value.ifsc
          : ifsc // ignore: cast_nullable_to_non_nullable
              as String?,
      upiId: freezed == upiId
          ? _value.upiId
          : upiId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkerImplCopyWith<$Res> implements $WorkerCopyWith<$Res> {
  factory _$$WorkerImplCopyWith(
          _$WorkerImpl value, $Res Function(_$WorkerImpl) then) =
      __$$WorkerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'contractor_id') String contractorId,
      String? photo,
      @JsonKey(name: 'worker_code') String? workerCode,
      @JsonKey(name: 'full_name') String fullName,
      String? phone,
      @JsonKey(name: 'father_name') String? fatherName,
      String? address,
      String? village,
      String? city,
      String? state,
      @JsonKey(name: 'joining_date') String joiningDate,
      @JsonKey(name: 'daily_wage') double dailyWage,
      @JsonKey(name: 'overtime_rate') double overtimeRate,
      String status,
      @JsonKey(name: 'default_project') String? defaultProject,
      String? notes,
      @JsonKey(name: 'emergency_contact') String? emergencyContact,
      @JsonKey(name: 'bank_name') String? bankName,
      @JsonKey(name: 'account_number') String? accountNumber,
      String? ifsc,
      @JsonKey(name: 'upi_id') String? upiId,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt});
}

/// @nodoc
class __$$WorkerImplCopyWithImpl<$Res>
    extends _$WorkerCopyWithImpl<$Res, _$WorkerImpl>
    implements _$$WorkerImplCopyWith<$Res> {
  __$$WorkerImplCopyWithImpl(
      _$WorkerImpl _value, $Res Function(_$WorkerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? contractorId = null,
    Object? photo = freezed,
    Object? workerCode = freezed,
    Object? fullName = null,
    Object? phone = freezed,
    Object? fatherName = freezed,
    Object? address = freezed,
    Object? village = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? joiningDate = null,
    Object? dailyWage = null,
    Object? overtimeRate = null,
    Object? status = null,
    Object? defaultProject = freezed,
    Object? notes = freezed,
    Object? emergencyContact = freezed,
    Object? bankName = freezed,
    Object? accountNumber = freezed,
    Object? ifsc = freezed,
    Object? upiId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$WorkerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      contractorId: null == contractorId
          ? _value.contractorId
          : contractorId // ignore: cast_nullable_to_non_nullable
              as String,
      photo: freezed == photo
          ? _value.photo
          : photo // ignore: cast_nullable_to_non_nullable
              as String?,
      workerCode: freezed == workerCode
          ? _value.workerCode
          : workerCode // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      fatherName: freezed == fatherName
          ? _value.fatherName
          : fatherName // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      village: freezed == village
          ? _value.village
          : village // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      joiningDate: null == joiningDate
          ? _value.joiningDate
          : joiningDate // ignore: cast_nullable_to_non_nullable
              as String,
      dailyWage: null == dailyWage
          ? _value.dailyWage
          : dailyWage // ignore: cast_nullable_to_non_nullable
              as double,
      overtimeRate: null == overtimeRate
          ? _value.overtimeRate
          : overtimeRate // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      defaultProject: freezed == defaultProject
          ? _value.defaultProject
          : defaultProject // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContact: freezed == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      ifsc: freezed == ifsc
          ? _value.ifsc
          : ifsc // ignore: cast_nullable_to_non_nullable
              as String?,
      upiId: freezed == upiId
          ? _value.upiId
          : upiId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkerImpl implements _Worker {
  const _$WorkerImpl(
      {required this.id,
      @JsonKey(name: 'contractor_id') required this.contractorId,
      this.photo,
      @JsonKey(name: 'worker_code') this.workerCode,
      @JsonKey(name: 'full_name') required this.fullName,
      this.phone,
      @JsonKey(name: 'father_name') this.fatherName,
      this.address,
      this.village,
      this.city,
      this.state,
      @JsonKey(name: 'joining_date') required this.joiningDate,
      @JsonKey(name: 'daily_wage') this.dailyWage = 0.0,
      @JsonKey(name: 'overtime_rate') this.overtimeRate = 0.0,
      this.status = 'Active',
      @JsonKey(name: 'default_project') this.defaultProject,
      this.notes,
      @JsonKey(name: 'emergency_contact') this.emergencyContact,
      @JsonKey(name: 'bank_name') this.bankName,
      @JsonKey(name: 'account_number') this.accountNumber,
      this.ifsc,
      @JsonKey(name: 'upi_id') this.upiId,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$WorkerImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkerImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'contractor_id')
  final String contractorId;
  @override
  final String? photo;
  @override
  @JsonKey(name: 'worker_code')
  final String? workerCode;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String? phone;
  @override
  @JsonKey(name: 'father_name')
  final String? fatherName;
  @override
  final String? address;
  @override
  final String? village;
  @override
  final String? city;
  @override
  final String? state;
  @override
  @JsonKey(name: 'joining_date')
  final String joiningDate;
  @override
  @JsonKey(name: 'daily_wage')
  final double dailyWage;
  @override
  @JsonKey(name: 'overtime_rate')
  final double overtimeRate;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'default_project')
  final String? defaultProject;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'emergency_contact')
  final String? emergencyContact;
  @override
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @override
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  @override
  final String? ifsc;
  @override
  @JsonKey(name: 'upi_id')
  final String? upiId;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'Worker(id: $id, contractorId: $contractorId, photo: $photo, workerCode: $workerCode, fullName: $fullName, phone: $phone, fatherName: $fatherName, address: $address, village: $village, city: $city, state: $state, joiningDate: $joiningDate, dailyWage: $dailyWage, overtimeRate: $overtimeRate, status: $status, defaultProject: $defaultProject, notes: $notes, emergencyContact: $emergencyContact, bankName: $bankName, accountNumber: $accountNumber, ifsc: $ifsc, upiId: $upiId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.contractorId, contractorId) ||
                other.contractorId == contractorId) &&
            (identical(other.photo, photo) || other.photo == photo) &&
            (identical(other.workerCode, workerCode) ||
                other.workerCode == workerCode) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.fatherName, fatherName) ||
                other.fatherName == fatherName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.village, village) || other.village == village) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.joiningDate, joiningDate) ||
                other.joiningDate == joiningDate) &&
            (identical(other.dailyWage, dailyWage) ||
                other.dailyWage == dailyWage) &&
            (identical(other.overtimeRate, overtimeRate) ||
                other.overtimeRate == overtimeRate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.defaultProject, defaultProject) ||
                other.defaultProject == defaultProject) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.ifsc, ifsc) || other.ifsc == ifsc) &&
            (identical(other.upiId, upiId) || other.upiId == upiId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        contractorId,
        photo,
        workerCode,
        fullName,
        phone,
        fatherName,
        address,
        village,
        city,
        state,
        joiningDate,
        dailyWage,
        overtimeRate,
        status,
        defaultProject,
        notes,
        emergencyContact,
        bankName,
        accountNumber,
        ifsc,
        upiId,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkerImplCopyWith<_$WorkerImpl> get copyWith =>
      __$$WorkerImplCopyWithImpl<_$WorkerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkerImplToJson(
      this,
    );
  }
}

abstract class _Worker implements Worker {
  const factory _Worker(
      {required final String id,
      @JsonKey(name: 'contractor_id') required final String contractorId,
      final String? photo,
      @JsonKey(name: 'worker_code') final String? workerCode,
      @JsonKey(name: 'full_name') required final String fullName,
      final String? phone,
      @JsonKey(name: 'father_name') final String? fatherName,
      final String? address,
      final String? village,
      final String? city,
      final String? state,
      @JsonKey(name: 'joining_date') required final String joiningDate,
      @JsonKey(name: 'daily_wage') final double dailyWage,
      @JsonKey(name: 'overtime_rate') final double overtimeRate,
      final String status,
      @JsonKey(name: 'default_project') final String? defaultProject,
      final String? notes,
      @JsonKey(name: 'emergency_contact') final String? emergencyContact,
      @JsonKey(name: 'bank_name') final String? bankName,
      @JsonKey(name: 'account_number') final String? accountNumber,
      final String? ifsc,
      @JsonKey(name: 'upi_id') final String? upiId,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt}) = _$WorkerImpl;

  factory _Worker.fromJson(Map<String, dynamic> json) = _$WorkerImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'contractor_id')
  String get contractorId;
  @override
  String? get photo;
  @override
  @JsonKey(name: 'worker_code')
  String? get workerCode;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String? get phone;
  @override
  @JsonKey(name: 'father_name')
  String? get fatherName;
  @override
  String? get address;
  @override
  String? get village;
  @override
  String? get city;
  @override
  String? get state;
  @override
  @JsonKey(name: 'joining_date')
  String get joiningDate;
  @override
  @JsonKey(name: 'daily_wage')
  double get dailyWage;
  @override
  @JsonKey(name: 'overtime_rate')
  double get overtimeRate;
  @override
  String get status;
  @override
  @JsonKey(name: 'default_project')
  String? get defaultProject;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'emergency_contact')
  String? get emergencyContact;
  @override
  @JsonKey(name: 'bank_name')
  String? get bankName;
  @override
  @JsonKey(name: 'account_number')
  String? get accountNumber;
  @override
  String? get ifsc;
  @override
  @JsonKey(name: 'upi_id')
  String? get upiId;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$WorkerImplCopyWith<_$WorkerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
