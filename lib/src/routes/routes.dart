import 'package:flutter/material.dart';
import 'package:pepinos/src/pages/cliente_detail_page.dart';
import 'package:pepinos/src/pages/clientes_page.dart';
import 'package:pepinos/src/pages/ventas_form.dart';
import 'package:pepinos/src/pages/ventas_page.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => VentasPage(),
    'ventas/form': (BuildContext context) => VentasForm(),
    'clientes': (BuildContext context) => ClientesPage(),
    'clientes/form': (BuildContext context) => ClienteDetailPage(),
  };
}
