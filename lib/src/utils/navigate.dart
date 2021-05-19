import 'package:flutter/material.dart';

void navigateWithNamedAndIdArgument(
    {@required BuildContext context, String id, @required String route}) {
  Navigator.pushNamed(context, route,
      arguments: id == null || id.isEmpty ? null : id);
}
