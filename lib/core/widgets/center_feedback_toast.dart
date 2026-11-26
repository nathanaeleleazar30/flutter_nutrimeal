import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum FeedbackToastType { success, error, info }

/// Notifikasi feedback ringkas berwarna putih agak samar (translucent)
/// yang menghilang perlahan tanpa mengganggu interaksi layar.
class CenterFeedbackToast {
  static OverlayEntry? _activeEntry;

  static void _removeActiveEntry() {
    final current = _activeEntry;
    _activeEntry = null;
    if (current != null && current.mounted) {
      try {
        current.remove();
      } catch (_) {}
    }
  }

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    FeedbackToastType type = FeedbackToastType.success,
    Duration displayDuration = const Duration(milliseconds: 1150),
    Duration fadeOutDuration = const Duration(milliseconds: 450),
  }) {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    _removeActiveEntry();

    final defaultIcon =
        icon ??
        (type == FeedbackToastType.success
            ? Icons.check_circle_rounded
            : (type == FeedbackToastType.error
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded));

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (ctx) => _CenterToastWidget(
        title: title,
        message: message,
        icon: defaultIcon,
        type: type,
        displayDuration: displayDuration,
        fadeOutDuration: fadeOutDuration,
        onDismissed: () {
          if (_activeEntry == overlayEntry) {
            _activeEntry = null;
          }
          if (overlayEntry.mounted) {
            try {
              overlayEntry.remove();
            } catch (_) {}
          }
        },
      ),
    );

    _activeEntry = overlayEntry;
    overlayState.insert(overlayEntry);
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
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
    String? title,
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
    String? title,
  }) {
    show(context, message: message, title: title, type: FeedbackToastType.info);
  }
}

class _CenterToastWidget extends StatefulWidget {
  final String? title;
  final String message;
  final IconData icon;
  final FeedbackToastType type;
  final Duration displayDuration;
  final Duration fadeOutDuration;
  final VoidCallback onDismissed;

  const _CenterToastWidget({
    this.title,
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
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _opacityAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    _dismissTimer = Timer(widget.displayDuration, () {
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
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Color get _iconColor {
    switch (widget.type) {
      case FeedbackToastType.success:
        return AppColors.primaryGreenHover;
      case FeedbackToastType.error:
        return AppColors.errorRed;
      case FeedbackToastType.info:
        return AppColors.textLinkTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trimmedTitle = widget.title?.trim();
    final hasTitle = trimmedTitle != null && trimmedTitle.isNotEmpty;
    final maxWidth = (MediaQuery.sizeOf(context).width - 48).clamp(
      180.0,
      300.0,
    );

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnim.value.clamp(0.0, 1.0),
                  child: Transform.scale(scale: _scaleAnim.value, child: child),
                );
              },
              child: Semantics(
                liveRegion: true,
                label: hasTitle
                    ? '$trimmedTitle. ${widget.message}'
                    : widget.message,
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.inputBorder.withValues(alpha: 0.9),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: _iconColor, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: hasTitle
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trimmedTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    widget.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                widget.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                  height: 1.3,
                                ),
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
