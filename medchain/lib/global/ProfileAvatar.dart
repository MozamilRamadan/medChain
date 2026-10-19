import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;

  // Backend server URL — defined once for all profile avatars.
  static const String serverBaseUrl = 'http://192.168.0.157:3000';

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.radius = 24,
  });

  String? _buildImageUrl() {
    final path = imagePath?.trim();

    if (path == null || path.isEmpty) {
      return null;
    }

    // Support full URLs stored in the database.
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    final normalizedBase =
        serverBaseUrl.replaceFirst(RegExp(r'/$'), '');

    final normalizedPath =
        path.replaceFirst(RegExp(r'^/'), '');

    return '$normalizedBase/$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _buildImageUrl();

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      backgroundImage:
          imageUrl == null ? null : NetworkImage(imageUrl),
      onBackgroundImageError: imageUrl == null
          ? null
          : (exception, stackTrace) {},
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: radius * 1.2,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}