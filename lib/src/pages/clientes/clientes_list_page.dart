import 'package:flutter/material.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/clientes_providers.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
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
        onPressed: () => _goClient(context, null),
      ),
      drawer: DrawerMenu(),
    );
  }

  Widget _createItem(BuildContext context, Cliente cliente) {
    return Container(
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
              context,
              cliente.idCliente.toString(),
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
                                  title: Text('Eliminar cliente'),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'Todo lo relacionado con el cliente'),
                                        TextSpan(
                                            text:
                                                ' ${cliente.nombres} ${cliente.apellidos} ',
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
                                          : () => onDelete(cliente),
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

  onDelete(Cliente cliente) async {
    _isDeleting = true;
    setState(() {});
    stateModal(() {});
    try {
      final message = await _clientProvider.deleteCliente(cliente.idCliente);
      final index = _clientes
          .indexWhere((element) => element.idCliente == cliente.idCliente);
      _clientes.removeAt(index);
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

void _goClient(BuildContext context, String idCliente) {
  Navigator.pushNamed(context, 'clientes/form',
      arguments: idCliente == null || idCliente.isEmpty ? null : idCliente);
}
