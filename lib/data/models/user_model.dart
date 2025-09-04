// File: lib/data/models/user_model.dart
class UserModel {
  final int id;
  final int groupId;
  final int companyId;
  final int cabangId;
  final int parentCompany;
  final String name;
  final String address;
  final String email;
  final String? emailVerifiedAt;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String phone;
  final String nik;
  final String nip;
  final double gajiPokok;
  final String npwp;
  final String bank;
  final String rekening;
  final int cuti;
  final String statusKaryawan;
  final DateTime joinDate;
  final String role;
  final String? jabatan;
  final int? positionId;
  final int shiftId;
  final int departmentId;
  final String attendanceType;
  final String? departmentName;
  final String? faceEmbedding;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.groupId,
    required this.companyId,
    required this.cabangId,
    required this.parentCompany,
    required this.name,
    required this.address,
    required this.email,
    this.emailVerifiedAt,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
    required this.phone,
    required this.nik,
    required this.nip,
    required this.gajiPokok,
    required this.npwp,
    required this.bank,
    required this.rekening,
    required this.cuti,
    required this.statusKaryawan,
    required this.joinDate,
    required this.role,
    this.jabatan,
    this.positionId,
    required this.shiftId,
    required this.departmentId,
    required this.attendanceType,
    this.departmentName,
    this.faceEmbedding,
    this.imageUrl,
  });

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      cabangId: json['cabang_id'] ?? 0,
      parentCompany: json['parent_company'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      fcmToken: json['fcm_token'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      phone: json['phone'] ?? '',
      nik: json['nik'] ?? '',
      nip: json['nip'] ?? '',
      gajiPokok: (json['gaji_pokok'] ?? 0).toDouble(),
      npwp: json['npwp'] ?? '',
      bank: json['bank'] ?? '',
      rekening: json['rekening'] ?? '',
      cuti: json['cuti'] ?? 0,
      statusKaryawan: json['status_karyawan'] ?? '',
      joinDate: DateTime.tryParse(json['join_date'] ?? '') ?? DateTime.now(),
      role: json['role'] ?? '',
      jabatan: json['jabatan'],
      positionId: json['position_id'],
      shiftId: json['shift_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      attendanceType:
          json['attandence_type'] ?? 'work_from_office', // Note: API typo
      departmentName: json['department_name'],
      faceEmbedding: json['face_embedding'],
      imageUrl: json['image_url'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'company_id': companyId,
      'cabang_id': cabangId,
      'parent_company': parentCompany,
      'name': name,
      'address': address,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'phone': phone,
      'nik': nik,
      'nip': nip,
      'gaji_pokok': gajiPokok,
      'npwp': npwp,
      'bank': bank,
      'rekening': rekening,
      'cuti': cuti,
      'status_karyawan': statusKaryawan,
      'join_date': joinDate.toIso8601String().split('T')[0], // Date only
      'role': role,
      'jabatan': jabatan,
      'position_id': positionId,
      'shift_id': shiftId,
      'department_id': departmentId,
      'attandence_type': attendanceType,
      'department_name': departmentName,
      'face_embedding': faceEmbedding,
      'image_url': imageUrl,
    };
  }

  // Helper methods
  bool get isAdmin => role.contains('admin');

  bool get hasFaceEmbedding =>
      faceEmbedding != null && faceEmbedding!.isNotEmpty;

  String get displayName => name.isNotEmpty ? name : email;

  String get fullPosition {
    if (jabatan != null && jabatan!.isNotEmpty) {
      return jabatan!;
    }
    return 'Employee';
  }

  // Copy with method for updating user data
  UserModel copyWith({
    int? id,
    int? groupId,
    int? companyId,
    int? cabangId,
    int? parentCompany,
    String? name,
    String? address,
    String? email,
    String? emailVerifiedAt,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phone,
    String? nik,
    String? nip,
    double? gajiPokok,
    String? npwp,
    String? bank,
    String? rekening,
    int? cuti,
    String? statusKaryawan,
    DateTime? joinDate,
    String? role,
    String? jabatan,
    int? positionId,
    int? shiftId,
    int? departmentId,
    String? attendanceType,
    String? departmentName,
    String? faceEmbedding,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      companyId: companyId ?? this.companyId,
      cabangId: cabangId ?? this.cabangId,
      parentCompany: parentCompany ?? this.parentCompany,
      name: name ?? this.name,
      address: address ?? this.address,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phone: phone ?? this.phone,
      nik: nik ?? this.nik,
      nip: nip ?? this.nip,
      gajiPokok: gajiPokok ?? this.gajiPokok,
      npwp: npwp ?? this.npwp,
      bank: bank ?? this.bank,
      rekening: rekening ?? this.rekening,
      cuti: cuti ?? this.cuti,
      statusKaryawan: statusKaryawan ?? this.statusKaryawan,
      joinDate: joinDate ?? this.joinDate,
      role: role ?? this.role,
      jabatan: jabatan ?? this.jabatan,
      positionId: positionId ?? this.positionId,
      shiftId: shiftId ?? this.shiftId,
      departmentId: departmentId ?? this.departmentId,
      attendanceType: attendanceType ?? this.attendanceType,
      departmentName: departmentName ?? this.departmentName,
      faceEmbedding: faceEmbedding ?? this.faceEmbedding,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, companyId: $companyId, role: $role)';
  }
}
