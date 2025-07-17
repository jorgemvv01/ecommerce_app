import 'package:flutter/material.dart';
import 'package:villa_design/villa_design.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VillaColors(Theme.of(context).brightness);
    return CircularProgressIndicator(
      backgroundColor: colors.outline,
      color: colors.primary,
    );
  }
}