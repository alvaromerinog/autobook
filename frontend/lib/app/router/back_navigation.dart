import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Pops the current route, falling back to the garage (`/`) when there is
/// nothing to pop.
///
/// Every back path must go through here — the AppBar button, the Android
/// predictive-back gesture, the hardware back button and the browser back
/// button. `GoRouter.pop()` throws on an empty stack, which is the state a cold
/// deep link (e.g. `/cars/1`) starts in.
void goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}
