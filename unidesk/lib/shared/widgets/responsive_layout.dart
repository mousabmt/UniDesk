import 'package:flutter/widgets.dart';

class ResponsiveLayout {
  static const double compactBreakpoint = 600;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compactBreakpoint;
  }

  static int columnsForWidth(
    double width, {
    int compact = 1,
    int medium = 2,
    int wide = 3,
  }) {
    if (width < compactBreakpoint) return compact;
    if (width < 960) return medium;
    return wide;
  }
}
