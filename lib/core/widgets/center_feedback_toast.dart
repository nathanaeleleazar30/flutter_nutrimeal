import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum FeedbackToastType { success, error, info }

/// Notifikasi feedback di tengah layar dengan tampilan agak samar (translucent frosted glass)
/// dan animasi fade out menghilang perlahan ("lama-lama hilang").
class CenterFeedbackToast {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    FeedbackToastType type = FeedbackToastType.success,
    Duration displayDuration = const Duration(milliseconds: 1400),
    Duration fadeOutDuration = const Duration(milliseconds: 650),
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    final defaultTitle =
        title ??
        (type == FeedbackToastType.success
            ? 'Berhasil!'
            : (type == FeedbackToastType.error ? 'Perhatian' : 'Informasi'));

    final defaultIcon =
        icon ??
        (type == FeedbackToastType.success
            ? Icons.check_circle_rounded
            : (type == FeedbackToastType.error
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded));

    overlayEntry = OverlayEntry(
      builder: (ctx) => _CenterToastWidget(
        title: defaultTitle,
        message: message,
        icon: defaultIcon,
        type: type,
        displayDuration: displayDuration,
        fadeOutDuration: fadeOutDuration,
        onDismissed: () {
          try {
            overlayEntry.remove();
          } catch (_) {}
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String title = 'Berhasil!',
  }) {
    show(
      context,
      message: message,
      title: title,
      type: FeedbackToastType.success,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String title = 'Perhatian',
  }) {
    show(
      context,
      message: message,
      title: title,
      type: FeedbackToastType.error,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String title = 'Informasi',
  }) {
    show(context, message: message, title: title, type: FeedbackToastType.info);
  }
}

class _CenterToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final FeedbackToastType type;
  final Duration displayDuration;
  final Duration fadeOutDuration;
  final VoidCallback onDismissed;

  const _CenterToastWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.type,
    required this.displayDuration,
    required this.fadeOutDuration,
    required this.onDismissed,
  });

  @override
  State<_CenterToastWidget> createState() => _CenterToastWidgetState();
}

class _CenterToastWidgetState extends State<_CenterToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _opacityAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    // 1. Fade in
    _animController.forward();

    // 2. Tunggu displayDuration, lalu fade out perlahan (lama-lama hilang)
    Future.delayed(widget.displayDuration, () {
      if (!mounted) return;
      _animController
          .animateTo(
            0.0,
            duration: widget.fadeOutDuration,
            curve: Curves.easeInOut,
          )
          .then((_) {
            if (mounted) {
              widget.onDismissed();
            }
          });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _iconColor {
    switch (widget.type) {
      case FeedbackToastType.success:
        return const Color(0xFF4ADE80);
      case FeedbackToastType.error:
        return const Color(0xFFF87171);
      case FeedbackToastType.info:
        return const Color(0xFF60A5FA);
    }
  }

  Color get _iconBgColor {
    switch (widget.type) {
      case FeedbackToastType.success:
        return const Color(0xFF0F8A50).withValues(alpha: 0.25);
      case FeedbackToastType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.22);
      case FeedbackToastType.info:
        return const Color(0xFF3B82F6).withValues(alpha: 0.22);
    }
  }

  Color get _iconBorderColor {
    switch (widget.type) {
      case FeedbackToastType.success:
        return const Color(0xFF22C55E).withValues(alpha: 0.6);
      case FeedbackToastType.error:
        return const Color(0xFFF87171).withValues(alpha: 0.6);
      case FeedbackToastType.info:
        return const Color(0xFF60A5FA).withValues(alpha: 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnim.value.clamp(0.0, 1.0),
                child: Transform.scale(scale: _scaleAnim.value, child: child),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 295),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    // Warna agak samar (translucent frosted glass)
                    color: const Color(0xCC0F172A), // 80% opacity dark slate
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lingkaran Ikon
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _iconBgColor,
                          border: Border.all(
                            color: _iconBorderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(widget.icon, color: _iconColor, size: 26),
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle / Detail Pesan
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFCBD5E1),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
