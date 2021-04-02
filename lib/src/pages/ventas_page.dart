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
      ),
      drawer: DrawerMenu(),
    );
  }
}