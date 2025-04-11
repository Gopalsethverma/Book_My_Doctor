import 'package:flutter/material.dart';

Widget fixTextScale(BuildContext context, Widget? child) {
  final MediaQueryData data = MediaQuery.of(context);
  return MediaQuery(
    data: data.copyWith(textScaler: TextScaler.linear(1.0)),
    child: child!,
  );
}
