import 'package:flutter/widgets.dart';

/// Pixel width to pass as `cacheWidth` so an image shown at [logicalSize] is
/// decoded at display resolution instead of its full file resolution.
int decodePx(BuildContext context, double logicalSize) =>
    (logicalSize * MediaQuery.devicePixelRatioOf(context)).ceil();
