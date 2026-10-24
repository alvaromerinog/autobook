import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

void goBack(BuildContext context, {String fallbackLocation = '/'}) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(fallbackLocation);
}
