import 'package:flutter/material.dart';
import 'package:pepinos/src/enums/estado_campania.dart';
import 'package:pepinos/src/models/campanias_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/campanias/campanias_provider.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/dismissible_background.dart';
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
  CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  CampaniasProvider _campaniasProvider = new CampaniasProvider();
  CampaniaFilter _campaniaFilter = new CampaniaFilter();
  bool _isInitialLoading = false;
  bool _isFetching = false;
  bool _hasInitialError = false;
  bool _hasErrorAfterFetching = false;
  bool _isDeleting = false;
  StateSetter _stateModal;

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
        onScroll: (int page) async {
          setState(() {
            _hasErrorAfterFetching = false;
            _isFetching = true;
          });
          try {
            _campaniaFilter.pagina = page;
            final response = await _campaniasProvider.getAllCampanias(
                campaniaFilter: _campaniaFilter);
            _campanias.addAll(response['campanias']);
            _paginacion = response['paginacion'];
            _hasErrorAfterFetching = false;
            _isFetching = false;
            setState(() {});
          } catch (e) {
            setState(() {
              _hasErrorAfterFetching = true;
              _isFetching = false;
            });
          }
        },
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
    Color color = campania.idEstado ==
            EstadoCampania.getValue(EstadoCampaniaEnum.EN_CURSO)
        ? Colors.green
        : Colors.amber;

    return Dismissible(
      key: Key(campania.idCampania.toString()),
      direction: DismissDirection.endToStart,
      background: DismissibleBackground(
        color: Colors.redAccent,
        icon: Icons.delete,
        text: 'Eliminar',
      ),
      confirmDismiss: (direction) async {
        final bool res = await showDialog(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (context, StateSetter _setState) {
              _stateModal = _setState;
              return AlertDialog(
                content: Text(
                    "¿Esta seguro de eliminar la campaña ${campania.nombreCampania}?"),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            _isDeleting ? Colors.grey : Colors.redAccent)),
                    child: Text(
                      "${_isDeleting ? 'Eliminando' : 'Eliminar campaña'}",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _isDeleting ? null : () => onDelete(campania),
                  ),
                ],
              );
            },
          ),
        );
        return res;
      },
      child: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.circle,
                    color: color,
                  ),
                ],
              ),
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
            Divider(
              height: 0,
            )
          ],
        ),
      ),
    );
  }

  void navigateWithNamedAndArguments(
      {@required BuildContext context, String id, @required String route}) {
    Navigator.pushNamed(context, route,
        arguments: id == null || id.isEmpty ? null : id);
  }

  onDelete(Campania campania) async {
    _isDeleting = true;
    setState(() {});
    _stateModal(() {});
    try {
      final message =
          await _campaniasProvider.deleteCampania(campania.idCampania);
      final index = _campanias
          .indexWhere((element) => element.idCampania == campania.idCampania);
      _customAlertDialog.confirmAlert(
        context: context,
        title: 'Eliminación exitosa',
        description: message,
        text: 'Aceptar',
        backFunction: () {
          Navigator.pop(context, true);
          _removeItem(index);
        },
      );
      _isDeleting = false;
      setState(() {});
      _stateModal(() {});
    } catch (e) {
      _customAlertDialog.errorAlert(
        context: context,
        title: 'Ops!',
        description: 'Ocurrio un error.',
        text: 'Aceptar',
      );
      _isDeleting = false;
      setState(() {});
      _stateModal(() {});
    }
  }

  void _removeItem(int index) {
    setState(() {});
    _campanias.removeAt(index);
  }
}
