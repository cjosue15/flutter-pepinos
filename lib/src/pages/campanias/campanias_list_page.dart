import 'package:flutter/material.dart';
import 'package:pepinos/src/models/campanias_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/campanias/campanias_provider.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
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
  StateSetter stateModal;

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
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (contextModalBottom) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: new Icon(Icons.delete),
                        title: new Text('Eliminar'),
                        onTap: () async {
                          final response = await showDialog(
                            context: context,
                            builder: (contextDialog) {
                              return StatefulBuilder(
                                  builder: (context, StateSetter setState) {
                                stateModal = setState;
                                return AlertDialog(
                                  title: Text('Eliminar campaña'),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'Todo lo relacionado con la campaña'),
                                        TextSpan(
                                            text:
                                                ' ${campania.nombreCampania} ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: 'se borrara.')
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                _isDeleting
                                                    ? Colors.grey
                                                    : Colors.red),
                                      ),
                                      onPressed: _isDeleting
                                          ? null
                                          : () => onDelete(campania),
                                      child: Text(
                                        '${_isDeleting ? 'Eliminando' : 'Entiendo lo que hago.'}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                );
                              });
                            },
                          );

                          if (response != null && response) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Divider(
              // height: 0,
              )
        ],
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
    stateModal(() {});
    try {
      final message =
          await _campaniasProvider.deleteCampania(campania.idCampania);
      final index = _campanias
          .indexWhere((element) => element.idCampania == campania.idCampania);
      _campanias.removeAt(index);
      _customAlertDialog.confirmAlert(
        context: context,
        title: 'Eliminación exitosa',
        description: message,
        text: 'Aceptar',
        backFunction: () {
          Navigator.pop(context, true);
        },
      );
      _isDeleting = false;
      setState(() {});
      stateModal(() {});
    } catch (e) {
      _customAlertDialog.errorAlert(
        context: context,
        title: 'Ops!',
        description: 'Ocurrio un error.',
        text: 'Aceptar',
      );
      _isDeleting = false;
      setState(() {});
      stateModal(() {});
    }
  }
}
