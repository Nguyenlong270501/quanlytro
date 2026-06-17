import 'package:flutter/material.dart';

class AppCircularIndicator extends StatelessWidget {
  final Color? color;
  const AppCircularIndicator({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: color));
  }
}
