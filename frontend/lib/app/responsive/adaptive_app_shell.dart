import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdaptiveAppShell extends StatelessWidget {
  const AdaptiveAppShell({
    super.key,
    required this.state,
    required this.child,
  });

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sizeClass = windowSizeClassOf(context);
    if (sizeClass == WindowSizeClass.compact) return child;
    return child;
  }
}