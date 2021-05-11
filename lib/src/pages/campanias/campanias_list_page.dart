import 'package:flutter/material.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class CampaniasListPage extends StatefulWidget {
  CampaniasListPage({Key key}) : super(key: key);

  @override
  _CampaniasListPageState createState() => _CampaniasListPageState();
}

class _CampaniasListPageState extends State<CampaniasListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      drawer: DrawerMenu(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          this.navigateWithNamedAndArguments(
              context: context, route: 'campanias/form');
        },
      ),
    );
  }

  @override
  void dispose() {
    print('bai');
    super.dispose();
  }

  AppBar _createAppBar() {
    return AppBar(
      title: Text('Campañas'),
    );
  }

  void navigateWithNamedAndArguments(
      {@required BuildContext context, String id, @required String route}) {
    Navigator.pushNamed(context, route,
        arguments: id == null || id.isEmpty ? null : id);
  }
}
