
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.size = 58,
    this.borderRadius = 16,
    this.fit = BoxFit.cover,
  });

  static const String _serverBaseUrl =
      'http://192.168.0.157:3000';

  String? _buildImageUrl() {
    final path = imagePath?.trim();

    if (path == null || path.isEmpty) {
      return null;
    }

    // Accept absolute URLs as well as paths from the backend.
    if (path.startsWith('https://') ||
        path.startsWith('http://')) {
      return path;
    }

    final normalizedPath =
        path.startsWith('/') ? path : '/$path';

    return '$_serverBaseUrl$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _buildImageUrl();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl == null
            ? _placeholder(context)
            : Image.network(
                imageUrl,
                fit: fit,
                width: size,
                height: size,
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return _placeholder(context);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _placeholder(context);
                },
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .primary
          .withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
