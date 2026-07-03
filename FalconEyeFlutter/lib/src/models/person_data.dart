class PersonData {
  PersonData({
    this.gender = '',
    this.ageRange = '',
    this.clothingColor = '',
    this.clothingType = '',
  });

  String gender;
  String ageRange;
  String clothingColor;
  String clothingType;

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'ageRange': ageRange,
        'clothingColor': clothingColor,
        'clothingType': clothingType,
      };

  factory PersonData.fromJson(Map<String, dynamic> json) => PersonData(
        gender: json['gender'] as String? ?? '',
        ageRange: json['ageRange'] as String? ?? '',
        clothingColor: json['clothingColor'] as String? ?? '',
        clothingType: json['clothingType'] as String? ?? '',
      );
}
