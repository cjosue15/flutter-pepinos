import 'package:flutter/material.dart';
import 'package:pepinos/src/pages/clientes/cliente_form_page.dart';
import 'package:pepinos/src/pages/clientes/clientes_list_page.dart';
import 'package:pepinos/src/pages/invernaderos/invernadero_form_page.dart';
import 'package:pepinos/src/pages/invernaderos/invernadero_list_page.dart';
import 'package:pepinos/src/pages/productos/productos_form_page.dart';
import 'package:pepinos/src/pages/productos/productos_list_page.dart';
import 'package:pepinos/src/pages/ventas/ventas_detail_page.dart';
import 'package:pepinos/src/pages/ventas/ventas_form_page.dart';
import 'package:pepinos/src/pages/ventas/ventas_list_page.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => VentasPage(),
    'ventas/form': (BuildContext context) => VentasForm(),
    'ventas/detail': (BuildContext context) => VentasDetailPage(),
    'clientes': (BuildContext context) => ClientesListPage(),
    'clientes/form': (BuildContext context) => ClienteFormPage(),
    'productos': (BuildContext context) => ProductosListPage(),
    'productos/form': (BuildContext context) => ProductsFormPage(),
    'invernaderos': (BuildContext context) => InvernaderoListPage(),
    'invernaderos/form': (BuildContext context) => InvernaderoPageForm(),
  };
}
