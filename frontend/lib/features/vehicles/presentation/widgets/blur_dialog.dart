import 'dart:ui';

import 'package:flutter/material.dart';

Future<T?> showBlurDialog<T>({
  required BuildContext context,
  required WidgetBuilder pageBuilder,
  bool barrierDismissible = true,
  String barrierLabel = 'Cerrar',
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    pageBuilder: (_, __, ___) => pageBuilder(context),
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6 * animation.value,
          sigmaY: 6 * animation.value,
        ),
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}
