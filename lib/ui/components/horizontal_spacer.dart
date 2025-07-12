import 'package:flutter/cupertino.dart';

class horizontalSpacer extends StatelessWidget {
  final double spacing;

  const horizontalSpacer({super.key, required this.spacing});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: spacing);
  }
}
