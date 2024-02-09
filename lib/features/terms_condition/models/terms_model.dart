class TermsModel {
  final int id;
  final String value;
  final String createdAt;
  final String updatedAt;
  String translatedValue;

  TermsModel({
    required this.id,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
    this.translatedValue = '',
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json['id'],
      value: json['value'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      translatedValue: json['translatedValue'] ?? '',
    );
  }
}
