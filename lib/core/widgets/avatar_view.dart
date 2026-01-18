import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Unified avatar display widget that handles both avatar paths and avatar IDs
/// Maps avatar_1, avatar_2, avatar_3, avatar_4 to their corresponding asset images
class AvatarView extends StatelessWidget {
  final String? avatarPath; // Direct asset path (e.g., 'assets/images/avatars/boy_01.png')
  final String? avatarId; // Avatar ID (e.g., 'avatar_1', 'avatar_2')
  final double radius;
  final BoxFit fit;
  final Color? backgroundColor;
  final String fallbackAsset;

  // Avatar ID to asset path mapping
  static const Map<String, String> _avatarMap = {
    'avatar_1': 'assets/images/avatars/boy1.png',
    'avatar_2': 'assets/images/avatars/boy2.png',
    'avatar_3': 'assets/images/avatars/girl1.png',
    'avatar_4': 'assets/images/avatars/girl2.png',
    'avatar_neutral': 'assets/images/avatars/girl1.png',
  };

  static const Map<String, String> _legacyAvatarMap = {
    'assets/avatars/kids/boy_01.png': 'assets/images/avatars/boy1.png',
    'assets/avatars/kids/boy_02.png': 'assets/images/avatars/boy2.png',
    'assets/avatars/kids/girl_01.png': 'assets/images/avatars/girl1.png',
    'assets/avatars/kids/girl_02.png': 'assets/images/avatars/girl2.png',
    'assets/avatars/kids/neutral_01.png': 'assets/images/avatars/girl1.png',
  };

  const AvatarView({
    this.avatarPath,
    this.avatarId,
    this.radius = 24,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.fallbackAsset = 'assets/images/avatars/girl1.png',
    super.key,
  });

  /// Get asset path from either avatarPath or avatarId
  String? _resolvePath() {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      return _normalizeAssetPath(avatarPath!);
    }
    if (avatarId != null && _avatarMap.containsKey(avatarId)) {
      return _avatarMap[avatarId];
    }
    if (avatarId != null && avatarId!.isNotEmpty) {
      return _normalizeAssetPath(avatarId!);
    }
    return null;
  }

  String _normalizeAssetPath(String path) {
    return _legacyAvatarMap[path] ?? path;
  }

  bool _isNetworkImage(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && uri.hasAbsolutePath &&
        (path.startsWith('http://') || path.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPath = _resolvePath();

    final fallbackImage = _avatarMap['avatar_neutral'] ?? fallbackAsset;
    if (resolvedPath != null && _isNetworkImage(resolvedPath)) {
      return CachedNetworkImage(
        imageUrl: resolvedPath,
        imageBuilder: (context, provider) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.transparent,
          backgroundImage: provider,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.transparent,
          backgroundImage: AssetImage(fallbackImage),
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.transparent,
          backgroundImage: AssetImage(fallbackImage),
        ),
      );
    }

    final assetPath = resolvedPath ?? fallbackImage;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.transparent,
      backgroundImage: AssetImage(assetPath),
    );
  }
}
