import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shape_up/data/repositories/app_repository_provider.dart';
import 'package:shape_up/domain/entities/photo_progress.dart';
import 'package:shape_up/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  File? _frontPhoto;
  File? _backPhoto;
  File? _leftPhoto;
  File? _rightPhoto;
  
  bool _isLoading = false;
  bool _hasTodayPhotos = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkTodayPhotos();
  }

  Future<void> _checkTodayPhotos() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.user == null) return;
    
    final hasPhotos = await AppRepositoryProvider.photo.hasPhotoProgressForDate(
      authState.user!.id,
      DateTime.now(),
    );
    
    setState(() {
      _hasTodayPhotos = hasPhotos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Фото прогресса',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Добавьте 4 фотографии (спереди, сзади, левый бок, правый бок)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            if (_hasTodayPhotos) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Вы уже добавляли фото сегодня. Следующее обновление доступно завтра.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Сетка для фото
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                _buildPhotoSquare('Спереди', _frontPhoto, () => _pickImage('front')),
                _buildPhotoSquare('Сзади', _backPhoto, () => _pickImage('back')),
                _buildPhotoSquare('Левый бок', _leftPhoto, () => _pickImage('left')),
                _buildPhotoSquare('Правый бок', _rightPhoto, () => _pickImage('right')),
              ],
            ),
            const SizedBox(height: 24),
            
            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _hasTodayPhotos || _isLoading ? null : _savePhotos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasTodayPhotos ? Colors.grey : null,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_hasTodayPhotos ? 'Уже добавлено сегодня' : 'Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSquare(String label, File? imageFile, VoidCallback onTap) {
    return GestureDetector(
      onTap: _hasTodayPhotos ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(String position) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (position) {
          case 'front':
            _frontPhoto = File(image.path);
            break;
          case 'back':
            _backPhoto = File(image.path);
            break;
          case 'left':
            _leftPhoto = File(image.path);
            break;
          case 'right':
            _rightPhoto = File(image.path);
            break;
        }
      });
    }
  }

  Future<void> _savePhotos() async {
    // Проверяем, все ли фото добавлены
    if (_frontPhoto == null || _backPhoto == null || _leftPhoto == null || _rightPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо добавить все 4 фотографии')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.user == null) throw Exception('User not found');
      
      final userId = authState.user!.id;
      final today = DateTime.now();
      
      // Сохраняем фото локально
      final frontPath = await AppRepositoryProvider.photo.savePhotoLocally(
        userId, _frontPhoto!, 'front',
      );
      final backPath = await AppRepositoryProvider.photo.savePhotoLocally(
        userId, _backPhoto!, 'back',
      );
      final leftPath = await AppRepositoryProvider.photo.savePhotoLocally(
        userId, _leftPhoto!, 'left',
      );
      final rightPath = await AppRepositoryProvider.photo.savePhotoLocally(
        userId, _rightPhoto!, 'right',
      );
      
      // Сохраняем запись в БД
      await AppRepositoryProvider.photo.addPhotoProgress(
        PhotoProgress(
          userId: userId,
          date: today,
          frontPhoto: frontPath,
          backPhoto: backPath,
          leftSidePhoto: leftPath,
          rightSidePhoto: rightPath,
          createdAt: DateTime.now(),
        ),
      );
      
      if (!mounted) return;
      
      // Показываем уведомление
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Внимание'),
          content: const Text(
            'Фото сохранены. Следующее обновление доступно завтра.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hasTodayPhotos = true;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}