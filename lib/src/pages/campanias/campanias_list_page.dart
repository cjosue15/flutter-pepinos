import 'package:flutter/material.dart';
import 'package:pepinos/src/models/campanias_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/campanias/campanias_provider.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';
import 'package:pepinos/src/widgets/infinite_list_view.dart';

class CampaniasListPage extends StatefulWidget {
  CampaniasListPage({Key key}) : super(key: key);

  @override
  _CampaniasListPageState createState() => _CampaniasListPageState();
}

class _CampaniasListPageState extends State<CampaniasListPage> {
  List<Campania> _campanias = [];
  Paginacion _paginacion = new Paginacion();
  CampaniasProvider _campaniasProvider = new CampaniasProvider();
  CampaniaFilter _campaniaFilter = new CampaniaFilter();
  bool _isInitialLoading = false;
  bool _isFetching = false;
  bool _hasInitialError = false;
  bool _hasErrorAfterFetching = false;

  @override
  void initState() {
    super.initState();
    if (mounted)
      setState(() {
        _isInitialLoading = true;
        _hasInitialError = false;
      });
    _campaniasProvider
        .getAllCampanias(campaniaFilter: _campaniaFilter)
        .then((response) {
      if (mounted)
        setState(() {
          _campanias = response['campanias'];
          _paginacion = response['paginacion'];
          _isInitialLoading = false;
          _hasInitialError = false;
        });
    }).catchError((error) {
      print(error);
      if (mounted)
        setState(() {
          _isInitialLoading = false;
          _hasInitialError = true;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      drawer: DrawerMenu(),
      body: InfiniteListView<Campania>(
        paginacion: _paginacion,
        data: _campanias,
        length: _campanias.length,
        itemBuilder: (context, item, index) => _createItem(item),
        isInitialLoading: _isInitialLoading,
        isFetching: _isFetching,
        hasInitialError: _hasInitialError,
        hasErrorAfterFetching: _hasErrorAfterFetching,
      ),
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
    super.dispose();
  }

  AppBar _createAppBar() {
    return AppBar(
      title: Text('Campañas'),
    );
  }

  Widget _createItem(Campania campania) {
    final start = campania.fechaInicio;
    final end = campania.fechaFin ?? '';
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(campania.nombreCampania),
            subtitle: Text('${start + ' - ' + end}'),
            trailing: Icon(
              Icons.keyboard_arrow_right,
              color: Colors.green,
            ),
            onTap: () => navigateWithNamedAndArguments(
              context: context,
              route: 'campanias/form',
              id: campania.idCampania.toString(),
            ),
          ),
          Divider()
        ],
      ),
    );
  }

  void navigateWithNamedAndArguments(
      {@required BuildContext context, String id, @required String route}) {
    Navigator.pushNamed(context, route,
        arguments: id == null || id.isEmpty ? null : id);
  }
}
