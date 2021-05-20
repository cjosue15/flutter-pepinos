import 'package:flutter/material.dart';
import 'package:pepinos/src/models/invernadero.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/invernaderos/invernaderos_provider.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
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
  bool _isDeleting = false;
  CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  StateSetter stateModal;

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
        onScroll: (int pagina) async {
          setState(() {
            _hasErrorAfterFetching = false;
            _isFetching = true;
          });
          try {
            _invernaderoFilter.pagina = pagina;
            final response = await _invernaderoProvider.getAllInvernaderos(
                invernaderoFilter: _invernaderoFilter);
            _invernaderos.addAll(response['invernaderos']);
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
            onTap: () => _goFormPage(
              context,
              invernadero.idInvernadero.toString(),
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
                                  title: Text('Eliminar invernadero'),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'Todo lo relacionado con el invernadero'),
                                        TextSpan(
                                            text:
                                                ' ${invernadero.nombreInvernadero} ',
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
                                          : () => onDelete(invernadero),
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

  void onDelete(Invernadero invernadero) async {
    _isDeleting = true;
    setState(() {});
    stateModal(() {});
    try {
      final message = await _invernaderoProvider
          .deleteInvernadero(invernadero.idInvernadero);
      final index = _invernaderos.indexWhere(
          (element) => element.idInvernadero == invernadero.idInvernadero);
      _invernaderos.removeAt(index);
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
