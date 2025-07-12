import 'package:flutter/cupertino.dart';

class verticalSpacer extends StatelessWidget {
  final double spacing;
  const verticalSpacer({required this.spacing});
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: spacing);
  }
}
