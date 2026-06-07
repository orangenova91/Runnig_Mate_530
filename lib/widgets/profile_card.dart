import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'storage_image.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.user});

  final UserProfile user;

  static const _runStyleLabels = {
    'scenic': '풍경 러닝',
    'speed': '스피드 러닝',
    'social': '소셜 러닝',
    'interval': '인터벌 러닝',
  };

  static const _timeLabels = {
    'morning': '🌅 아침',
    'afternoon': '☀️ 오후',
    'night': '🌙 밤',
  };

  @override
  Widget build(BuildContext context) {
    final runStyle =
        _runStyleLabels[user.runStyle] ?? user.runStyle;

    return Container(
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: user.photoUrl.isNotEmpty
                ? StorageImage(
                    url: user.photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: _photoPlaceholder(),
                  )
                : _photoPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name}, ${user.age}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.speed,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.avgPace,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        runStyle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF2A9D8F),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                if (user.preferredTime.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: user.preferredTime.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          _timeLabels[t] ?? t,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textPrimary,
                                  ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                if (user.courseName.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.courseName,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: AppTheme.background,
      child: const Center(
        child: Icon(
          Icons.person_outline,
          size: 64,
          color: AppTheme.border,
        ),
      ),
    );
  }
}
