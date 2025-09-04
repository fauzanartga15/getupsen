// File: lib/data/models/employee_model.dart
class EmployeeModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String nik;
  final String nip;
  final String address;
  final double gajiPokok;
  final String statusKaryawan;
  final String attendanceType;
  final String? faceEmbedding;
  final String? imageUrl;
  final String joinDate;
  final CompanyInfo company;
  final DepartmentInfo? department;
  final PositionInfo? position;
  final ShiftInfo? shift;
  final CabangInfo? cabang;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nik,
    required this.nip,
    required this.address,
    required this.gajiPokok,
    required this.statusKaryawan,
    required this.attendanceType,
    this.faceEmbedding,
    this.imageUrl,
    required this.joinDate,
    required this.company,
    this.department,
    this.position,
    this.shift,
    this.cabang,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nik: json['nik'] ?? '',
      nip: json['nip'] ?? '',
      address: json['address'] ?? '',
      gajiPokok: (json['gaji_pokok'] ?? 0).toDouble(),
      statusKaryawan: json['status_karyawan'] ?? '',
      attendanceType: json['attandence_type'] ?? 'work_from_office',
      faceEmbedding: json['face_embedding'],
      imageUrl: json['image_url'],
      joinDate: json['join_date'] ?? '',
      company: CompanyInfo.fromJson(json['company'] ?? {}),
      department: json['department'] != null
          ? DepartmentInfo.fromJson(json['department'])
          : null,
      position: json['position'] != null
          ? PositionInfo.fromJson(json['position'])
          : null,
      shift: json['shift'] != null ? ShiftInfo.fromJson(json['shift']) : null,
      cabang: json['cabang'] != null
          ? CabangInfo.fromJson(json['cabang'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nik': nik,
      'nip': nip,
      'address': address,
      'gaji_pokok': gajiPokok,
      'status_karyawan': statusKaryawan,
      'attandence_type': attendanceType,
      'face_embedding': faceEmbedding,
      'image_url': imageUrl,
      'join_date': joinDate,
      'company': company.toJson(),
      'department': department?.toJson(),
      'position': position?.toJson(),
      'shift': shift?.toJson(),
      'cabang': cabang?.toJson(),
    };
  }

  // Helper methods
  bool get hasFaceEmbedding =>
      faceEmbedding != null && faceEmbedding!.isNotEmpty;

  List<double> get embeddingVector {
    if (!hasFaceEmbedding) return [];

    try {
      return faceEmbedding!
          .split(',')
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList();
    } catch (e) {
      print("Error parsing embedding for $name: $e");
      return [];
    }
  }

  String get departmentName => department?.name ?? 'Unknown Department';
  String get positionName => position?.name ?? 'Unknown Position';
  String get shiftName => shift?.name ?? 'No Shift';

  String get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    return 'https://dev.upsen.id/storage/$imageUrl';
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, name: $name, department: $departmentName, position: $positionName)';
  }
}

class CompanyInfo {
  final int id;
  final String name;

  CompanyInfo({required this.id, required this.name});

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class DepartmentInfo {
  final int id;
  final String name;

  DepartmentInfo({required this.id, required this.name});

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) {
    return DepartmentInfo(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class PositionInfo {
  final int id;
  final String name;

  PositionInfo({required this.id, required this.name});

  factory PositionInfo.fromJson(Map<String, dynamic> json) {
    return PositionInfo(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class ShiftInfo {
  final int id;
  final String name;
  final String masuk;
  final String pulang;

  ShiftInfo({
    required this.id,
    required this.name,
    required this.masuk,
    required this.pulang,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) {
    return ShiftInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      masuk: json['masuk'] ?? '',
      pulang: json['pulang'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'masuk': masuk, 'pulang': pulang};
  }

  String get workingHours => '$masuk-$pulang';
}

class CabangInfo {
  final int id;
  final String name;

  CabangInfo({required this.id, required this.name});

  factory CabangInfo.fromJson(Map<String, dynamic> json) {
    return CabangInfo(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
