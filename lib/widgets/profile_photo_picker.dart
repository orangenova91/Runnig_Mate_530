import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'storage_image.dart';

class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.imageBytes,
    required this.onPick,
    this.imageUrl,
    this.isLoading = false,
  });

  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback onPick;
  final bool isLoading;

  bool get _hasImage =>
      imageBytes != null || (imageUrl != null && imageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: isLoading ? null : onPick,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.background,
              border: Border.all(
                color: _hasImage ? AppTheme.primary : AppTheme.border,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.textPrimary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImageContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(BuildContext context) {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, fit: BoxFit.cover);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return StorageImage(
        url: imageUrl!,
        fit: BoxFit.cover,
        errorWidget: _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isLoading ? Icons.hourglass_empty : Icons.camera_alt_outlined,
          size: 32,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          isLoading ? '업로드 중...' : '탭하여 선택',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}
