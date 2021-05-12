import 'package:flutter/material.dart';
import 'package:pepinos/src/models/invernadero.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/invernaderos/invernaderos_provider.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';
import 'package:pepinos/src/widgets/infinite_list_view.dart';

class InvernaderoListPage extends StatefulWidget {
  @override
  _InvernaderoListPageState createState() => _InvernaderoListPageState();
}

class _InvernaderoListPageState extends State<InvernaderoListPage> {
  Paginacion _paginacion = new Paginacion();
  InvernaderoFilter _invernaderoFilter = new InvernaderoFilter();
  InvernaderoProvider _invernaderoProvider = new InvernaderoProvider();
  List<Invernadero> _invernaderos = [];
  bool _hasInitialError = false;
  bool _hasErrorAfterFetching = false;
  bool _isInitialLoading = false;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        _hasInitialError = false;
        _isInitialLoading = true;
      });
    }
    _invernaderoProvider
        .getAllInvernaderos(invernaderoFilter: _invernaderoFilter)
        .then((response) {
      if (mounted) {
        setState(() {
          _paginacion = response['paginacion'];
          _invernaderos = response['invernaderos'];
          _hasInitialError = false;
          _isInitialLoading = false;
        });
      }
    }).catchError((onError) {
      if (mounted) {
        setState(() {
          _hasInitialError = true;
          _isInitialLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invernaderos'),
      ),
      drawer: DrawerMenu(),
      body: InfiniteListView<Invernadero>(
        context: context,
        itemBuilder: (context, item, index) => _createItem(item),
        paginacion: _paginacion,
        data: _invernaderos,
        length: _invernaderos.length,
        onScroll: (int pagina) {},
        hasInitialError: _hasInitialError,
        hasErrorAfterFetching: _hasErrorAfterFetching,
        isInitialLoading: _isInitialLoading,
        isFetching: _isFetching,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goFormPage(context, null),
      ),
    );
  }

  Widget _createItem(Invernadero invernadero) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
              title: Text(invernadero.nombreInvernadero),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.green,
              ),
              onTap: () =>
                  _goFormPage(context, invernadero.idInvernadero.toString())),
          Divider()
        ],
      ),
    );
  }

  void _goFormPage(BuildContext context, String idInvernadero) {
    Navigator.pushNamed(context, 'invernaderos/form',
        arguments: idInvernadero == null || idInvernadero.isEmpty
            ? null
            : idInvernadero);
  }
}
