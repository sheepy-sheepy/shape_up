class WaterEntry {
  final int? id;
  final String userId;
  final DateTime date;
  final int ml;
  final DateTime createdAt;

  WaterEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.ml,
    required this.createdAt,
  });

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      ml: json['ml'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'ml': ml,
      'created_at': createdAt.toIso8601String(),
    };
  }
}