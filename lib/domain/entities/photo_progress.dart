class PhotoProgress {
  final int? id;
  final String userId;
  final DateTime date;
  final String? frontPhoto;
  final String? backPhoto;
  final String? leftSidePhoto;
  final String? rightSidePhoto;
  final DateTime createdAt;

  PhotoProgress({
    this.id,
    required this.userId,
    required this.date,
    this.frontPhoto,
    this.backPhoto,
    this.leftSidePhoto,
    this.rightSidePhoto,
    required this.createdAt,
  });

  bool get hasAllPhotos => 
      frontPhoto != null && 
      backPhoto != null && 
      leftSidePhoto != null && 
      rightSidePhoto != null;

  factory PhotoProgress.fromJson(Map<String, dynamic> json) {
    return PhotoProgress(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      frontPhoto: json['front_photo'] as String?,
      backPhoto: json['back_photo'] as String?,
      leftSidePhoto: json['left_side_photo'] as String?,
      rightSidePhoto: json['right_side_photo'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'front_photo': frontPhoto,
      'back_photo': backPhoto,
      'left_side_photo': leftSidePhoto,
      'right_side_photo': rightSidePhoto,
      'created_at': createdAt.toIso8601String(),
    };
  }
}