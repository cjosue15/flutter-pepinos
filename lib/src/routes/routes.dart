import 'package:flutter/material.dart';
import 'package:pepinos/src/pages/cliente_detail_page.dart';
import 'package:pepinos/src/pages/clientes_page.dart';
import 'package:pepinos/src/pages/invernaderos/invernadero_form_page.dart';
import 'package:pepinos/src/pages/invernaderos/invernadero_list_page.dart';
import 'package:pepinos/src/pages/productos/productos_form_page.dart';
import 'package:pepinos/src/pages/productos/productos_list_page.dart';
import 'package:pepinos/src/pages/ventas_form.dart';
import 'package:pepinos/src/pages/ventas_page.dart';

Map<String, WidgetBuilder> getAplicationRoutes() {
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => VentasPage(),
    'ventas/form': (BuildContext context) => VentasForm(),
    'clientes': (BuildContext context) => ClientesPage(),
    'clientes/form': (BuildContext context) => ClienteDetailPage(),
    'productos': (BuildContext context) => ProductosListPage(),
    'productos/form': (BuildContext context) => ProductsFormPage(),
    'invernaderos': (BuildContext context) => InvernaderoListPage(),
    'invernaderos/form': (BuildContext context) => InvernaderoPageForm(),
  };
}
