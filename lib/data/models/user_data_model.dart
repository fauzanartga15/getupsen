class UserData {
  final int id;
  final String name;
  final String email;
  final String? foto;
  final String department;
  final String position;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.foto,
    required this.department,
    required this.position,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      foto: json['foto'],
      department: json['department'] ?? '',
      position: json['position'] ?? '',
    );
  }

  String get positionWithDepartment => '$position - $department';
}
