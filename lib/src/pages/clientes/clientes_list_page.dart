import 'package:flutter/material.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/clientes_providers.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/dismissible_background.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';
import 'package:pepinos/src/widgets/infinite_list_view.dart';

class ClientesListPage extends StatefulWidget {
  @override
  _ClientesListPageState createState() => _ClientesListPageState();
}

class _ClientesListPageState extends State<ClientesListPage> {
  final ClienteProvider _clientProvider = new ClienteProvider();
  Paginacion _paginacion = new Paginacion();
  ClienteFilter _clienteFilter = new ClienteFilter();
  bool _isFetching = false;
  bool _isInitialLoading = false;
  bool _hasInitialError = false;
  bool _hasErrorAfterFetching = false;
  bool _isDeleting = false;
  List<Cliente> _clientes = [];
  StateSetter stateModal;
  CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  StateSetter _stateModal;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isInitialLoading = true;
      _hasInitialError = false;
    });
    _clientProvider
        .getClientsList(clienteFilter: _clienteFilter)
        .then((response) {
      setState(() {
        _clientes = response['clientes'];
        _paginacion = response['paginacion'];
        _isInitialLoading = false;
        _hasInitialError = false;
      });
    }).catchError((error) {
      setState(() {
        _isInitialLoading = false;
        _hasInitialError = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
      ),
      body: InfiniteListView<Cliente>(
        context: context,
        data: _clientes,
        hasErrorAfterFetching: _hasErrorAfterFetching,
        hasInitialError: _hasInitialError,
        isFetching: _isFetching,
        isInitialLoading: _isInitialLoading,
        length: _clientes.length,
        onScroll: (int pagina) async {
          setState(() {
            _hasErrorAfterFetching = false;
            _isFetching = true;
          });
          try {
            _clienteFilter.pagina = pagina;
            final response = await _clientProvider.getClientsList(
                clienteFilter: _clienteFilter);
            _clientes.addAll(response['clientes']);
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
        paginacion: _paginacion,
        itemBuilder: (context, item, index) => _createItem(context, item),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goClient('clientes/form', context, null),
      ),
      drawer: DrawerMenu(),
    );
  }

  Widget _createItem(BuildContext context, Cliente cliente) {
    return Dismissible(
      key: Key(cliente.idCliente.toString()),
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
                    "¿Esta seguro de eliminar el cliente ${cliente.nombres} ${cliente.apellidos}?"),
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
                      "${_isDeleting ? 'Anulando' : 'Eliminar cliente'}",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _isDeleting ? null : () => onDelete(cliente),
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
              title: Text(cliente.nombres + ' ' + cliente.apellidos),
              subtitle: Text(cliente.lugar),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.green,
              ),
              onTap: () => _goClient(
                'clientes/details',
                context,
                cliente.idCliente.toString(),
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

  void onDelete(Cliente cliente) async {
    _isDeleting = true;
    setState(() {});
    _stateModal(() {});
    try {
      final message = await _clientProvider.deleteCliente(cliente.idCliente);
      final index = _clientes
          .indexWhere((element) => element.idCliente == cliente.idCliente);
      _isDeleting = false;

      _customAlertDialog.confirmAlert(
        context: context,
        title: 'Eliminación exitosa',
        description: message,
        text: 'Aceptar',
        backFunction: () {
          Navigator.pop(context);
          _removeItem(index);
        },
      );

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
    _clientes.removeAt(index);
  }
}

void _goClient(String route, BuildContext context, String idCliente) {
  Navigator.pushNamed(context, route,
      arguments: idCliente == null || idCliente.isEmpty ? null : idCliente);
}
