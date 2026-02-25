import 'dart:io';
import 'package:shape_up/data/datasources/local/app_database.dart';
import 'package:shape_up/domain/entities/photo_progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoRepository {
  final AppDatabase database;

  PhotoRepository({
    required this.database,
  });

  Future<String> _getPhotoDirectory(String userId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(path.join(appDir.path, 'photos', userId));
    
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    
    return photoDir.path;
  }

  Future<String> savePhotoLocally(String userId, File photo, String type) async {
    final dir = await _getPhotoDirectory(userId);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$type.jpg';
    final filePath = path.join(dir, fileName);
    
    final savedFile = await photo.copy(filePath);
    return savedFile.path;
  }

  Future<void> deleteLocalPhoto(String photoPath) async {
    final file = File(photoPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<PhotoProgress>> getPhotoProgress(String userId) async {
    final db = await database.database;
    
    final result = await db.query(
      'photos',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    
    return result.map((json) => PhotoProgress.fromJson(json)).toList();
  }

  Future<PhotoProgress?> getPhotoProgressForDate(String userId, DateTime date) async {
    final db = await database.database;
    final dateStr = date.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'photos',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
    );
    
    if (result.isEmpty) return null;
    return PhotoProgress.fromJson(result.first);
  }

  Future<bool> hasPhotoProgressForDate(String userId, DateTime date) async {
    final progress = await getPhotoProgressForDate(userId, date);
    return progress != null;
  }

  Future<int> addPhotoProgress(PhotoProgress progress) async {
    final db = await database.database;
    
    return await db.insert('photos', progress.toJson());
  }

  Future<int> updatePhotoProgress(PhotoProgress progress) async {
    final db = await database.database;
    
    return await db.update(
      'photos',
      progress.toJson(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  Future<List<DateTime>> getAvailablePhotoDates(String userId) async {
    final progressList = await getPhotoProgress(userId);
    return progressList
        .where((p) => p.hasAllPhotos)
        .map((p) => p.date)
        .toList();
  }

  Future<Map<DateTime, PhotoProgress>> getPhotoProgressMap(String userId) async {
    final list = await getPhotoProgress(userId);
    return {for (var p in list) p.date: p};
  }
}