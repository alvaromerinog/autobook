import 'package:autobook/app/responsive/app_sidebar.dart';
import 'package:autobook/app/responsive/breakpoints.dart';
import 'package:autobook/features/vehicles/presentation/widgets/garage_list_content.dart';
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
    if (sizeClass == WindowSizeClass.medium) {
      if (state.uri.path == '/') {
        return const Scaffold(
          body: Row(
            children: [
              AppSidebar(extended: false),
              Expanded(child: GarageListContent()),
            ],
          ),
        );
      }
      return child;
    }
    return child;
  }
}