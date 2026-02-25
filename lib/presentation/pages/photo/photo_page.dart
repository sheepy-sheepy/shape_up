// lib/presentation/pages/photo/photo_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  String? _frontPhoto;
  String? _backPhoto;
  String? _leftPhoto;
  String? _rightPhoto;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

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
                onPressed: _isLoading ? null : _savePhotos,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSquare(String label, String? imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          image: imagePath != null
              ? DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: Colors.grey)),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> _pickImage(String position) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (position) {
          case 'front':
            _frontPhoto = image.path;
            break;
          case 'back':
            _backPhoto = image.path;
            break;
          case 'left':
            _leftPhoto = image.path;
            break;
          case 'right':
            _rightPhoto = image.path;
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
    
    // Имитация сохранения
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _isLoading = false);
    
    // Показываем уведомление
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Внимание'),
          content: const Text('Фото нельзя будет редактировать после сохранения. Продолжить?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Фото сохранены')),
                );
              },
              child: const Text('Подтвердить'),
            ),
          ],
        ),
      );
    }
  }
}