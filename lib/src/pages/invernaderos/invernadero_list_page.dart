import 'package:flutter/material.dart';
import 'package:pepinos/src/models/invernadero.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/invernaderos/invernaderos_provider.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/dismissible_background.dart';
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
  StateSetter _stateModal;

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
    return Dismissible(
      key: Key(invernadero.idInvernadero.toString()),
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
                    "¿Esta seguro de eliminar el invernadero ${invernadero.nombreInvernadero}?"),
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
                    onPressed: _isDeleting ? null : () => onDelete(invernadero),
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
              title: Text(invernadero.nombreInvernadero),
              subtitle: Text(
                  'Productos asociados: ${invernadero.cantidadProductos ?? 0}'),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.green,
              ),
              onTap: () => _goFormPage(
                context,
                invernadero.idInvernadero.toString(),
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

  void _goFormPage(BuildContext context, String idInvernadero) {
    Navigator.pushNamed(context, 'invernaderos/form',
        arguments: idInvernadero == null || idInvernadero.isEmpty
            ? null
            : idInvernadero);
  }

  void onDelete(Invernadero invernadero) async {
    _isDeleting = true;
    setState(() {});
    _stateModal(() {});
    try {
      final message = await _invernaderoProvider
          .deleteInvernadero(invernadero.idInvernadero);
      final index = _invernaderos.indexWhere(
          (element) => element.idInvernadero == invernadero.idInvernadero);
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
    _invernaderos.removeAt(index);
    setState(() {});
  }
}
