import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../../config/server_config.dart';
import '../app_colors.dart';

/// Returns a loadable image URL from the API (rewrites localhost when needed).
String? resolveAppImageUrl(String? value) =>
    ServerConfig.resolveAppImageUrl(value);

/// [ImageProvider] for [CircleAvatar] on mobile/desktop.
/// On Flutter Web prefer [AppCircleAvatar] — [NetworkImage] is blocked by CORS.
ImageProvider? appNetworkImageProvider(String? url) {
  if (kIsWeb) return null;
  final resolved = resolveAppImageUrl(url);
  if (resolved == null) return null;
  return NetworkImage(resolved);
}

/// Shared network image widget — uses the backend URL directly.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? loadingColor;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveAppImageUrl(url);
    if (resolved == null) {
      return _constrain(placeholder ?? const SizedBox.shrink());
    }

    Widget image = Image.network(
      resolved,
      width: width,
      height: height,
      fit: fit,
      // Web: use <img> so cross-origin storage URLs render without CORS fetch.
      webHtmlElementStrategy:
          kIsWeb ? WebHtmlElementStrategy.prefer : WebHtmlElementStrategy.never,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _constrain(
          ColoredBox(
            color: loadingColor ?? const Color(0xFFF0F0F0),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        debugPrint('[AppNetworkImage] failed to load: $resolved');
        return _constrain(errorWidget ?? placeholder ?? const SizedBox.shrink());
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _constrain(Widget child) {
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return child;
  }
}

/// Circular avatar — works on Flutter Web (unlike [CircleAvatar] + [NetworkImage]).
class AppCircleAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final Color? backgroundColor;
  final Widget? child;
  final IconData fallbackIcon;

  const AppCircleAvatar({
    super.key,
    required this.url,
    required this.radius,
    this.backgroundColor,
    this.child,
    this.fallbackIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final bg = backgroundColor ?? AppColors.primary.withValues(alpha: 0.15);

    if (resolveAppImageUrl(url) == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: child ??
            Icon(fallbackIcon, size: radius * 1.1, color: AppColors.primary),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: AppNetworkImage(
          url: url,
          width: size,
          height: size,
          errorWidget: CircleAvatar(
            radius: radius,
            backgroundColor: bg,
            child: child ??
                Icon(fallbackIcon, size: radius * 1.1, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
