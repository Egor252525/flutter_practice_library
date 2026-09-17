import 'package:flutter/material.dart';
import 'adaptive_scaffold.dart';

class CenteredContent extends StatelessWidget {
  final Widget child;
  const CenteredContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Adaptive.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
