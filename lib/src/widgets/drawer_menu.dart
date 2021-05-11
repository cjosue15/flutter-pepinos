import 'package:flutter/material.dart';

class DrawerItem {
  String title;
  Icon icon;
  String navigateTo;

  DrawerItem({String title, Icon icon, String navigateTo}) {
    this.title = title;
    this.icon = icon;
    this.navigateTo = navigateTo;
  }
}

class DrawerMenu extends StatefulWidget {
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final List<DrawerItem> _listViewData = [
    DrawerItem(
        title: 'Ventas',
        icon: Icon(Icons.shopping_cart_rounded),
        navigateTo: '/'),
    DrawerItem(
        title: 'Clientes', icon: Icon(Icons.person), navigateTo: 'clientes'),
    DrawerItem(
        title: 'Productos',
        icon: Icon(Icons.inventory),
        navigateTo: 'productos'),
    DrawerItem(
        title: 'Invernaderos',
        icon: Icon(Icons.place),
        navigateTo: 'invernaderos'),
    DrawerItem(
        title: 'Campañas',
        icon: Icon(Icons.calendar_today),
        navigateTo: 'campanias')
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[_headerDrawer(), _createItemsDrawer(context)],
      ),
    );
  }

  Widget _headerDrawer() {
    return UserAccountsDrawerHeader(
        accountName: Text("Carlos Morales"),
        accountEmail: Text("carlosandresmr65@gmail.com"),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.grey[200],
        ));
  }

  Widget _createItemsDrawer(BuildContext context) {
    String _currentRoute = ModalRoute.of(context)?.settings?.name;
    return Flexible(
      child: ListView.builder(
          itemCount: _listViewData.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              color: _currentRoute == _listViewData[index].navigateTo
                  ? Colors.grey[200]
                  : Colors.transparent,
              child: ListTile(
                  leading: _listViewData[index].icon,
                  title: Text(_listViewData[index].title),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    if (_currentRoute == _listViewData[index].navigateTo)
                      return;
                    Navigator.pushReplacementNamed(
                        context, _listViewData[index].navigateTo);
                  }),
            );
          }),
    );
  }
}
