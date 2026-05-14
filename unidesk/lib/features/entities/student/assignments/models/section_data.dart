class SectionData {
  const SectionData({
    required this.id,
    required this.sectionNumber,
  });

  final String id;
  final int sectionNumber;

  factory SectionData.fromMap(Map<String, dynamic> map) {
    return SectionData(
      id: map['id']?.toString() ?? '',
      sectionNumber: _toInt(map['section_number']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_number': sectionNumber,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
