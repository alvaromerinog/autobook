import 'package:flutter/widgets.dart';

enum WindowSizeClass { compact, medium, expanded }

WindowSizeClass windowSizeClassFromWidth(double width) {
  if (width < 600) return WindowSizeClass.compact;
  if (width < 840) return WindowSizeClass.medium;
  return WindowSizeClass.expanded;
}

WindowSizeClass windowSizeClassOf(BuildContext context) =>
    windowSizeClassFromWidth(MediaQuery.sizeOf(context).width);