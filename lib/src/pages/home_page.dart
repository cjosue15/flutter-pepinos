import 'package:flutter/material.dart';
import 'package:pepinos/src/pages/clientes_page.dart';
import 'package:pepinos/src/pages/ventas_page.dart';

/// This is the stateful widget that the main application instantiates.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

/// This is the private State class that goes with HomePage.
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    VentasPage(),
    ClientesPage(),
    Text(
      'Index 2: School',
    )
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('BottomNavigationBar Sample'),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Vnetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Invernaderos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
