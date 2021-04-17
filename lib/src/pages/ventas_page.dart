import 'package:flutter/material.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class VentasPage extends StatefulWidget {
  @override
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    print('Holis');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add), onPressed: () => _goVenta(context, null))
        ],
      ),
      drawer: DrawerMenu(),
    );
  }

  void _goVenta(BuildContext context, param1) {
    // Navigator.pushNamed(context, 'clientes/formulario',
    //   arguments: idCliente == null || idCliente.isEmpty ? null : idCliente);
    Navigator.pushNamed(context, 'ventas/form');
  }
}
