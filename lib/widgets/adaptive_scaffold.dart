import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded, large }

class Adaptive {
  static ScreenSize of(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return ScreenSize.compact;
    if (w < 1024) return ScreenSize.medium;
    if (w < 1600) return ScreenSize.expanded;
    return ScreenSize.large;
  }

  static bool isCompact(BuildContext c) => of(c) == ScreenSize.compact;
  static bool isMedium(BuildContext c) => of(c) == ScreenSize.medium;
  static bool isExpanded(BuildContext c) =>
      of(c) == ScreenSize.expanded || of(c) == ScreenSize.large;

  static double maxContentWidth(BuildContext c) {
    switch (of(c)) {
      case ScreenSize.compact:
      case ScreenSize.medium:
        return double.infinity;
      case ScreenSize.expanded:
        return 1280;
      case ScreenSize.large:
        return 1440;
    }
  }
}
