import 'package:flutter/material.dart';
import 'package:pepinos/src/pages/cliente_detail_page.dart';
import 'package:pepinos/src/pages/home_page.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => HomePage(),
    'cliente': (BuildContext context) => ClienteDetailPage(),
  };
}
