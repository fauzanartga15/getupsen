class CompanyData {
  final String name;
  final String? logo;
  final String workingHours;

  CompanyData({required this.name, this.logo, required this.workingHours});

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      name: json['name'] ?? '',
      logo: json['logo'],
      workingHours: json['working_hours'] ?? '',
    );
  }
}
