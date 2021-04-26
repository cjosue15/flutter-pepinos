import 'package:flutter/material.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/providers/clientes_providers.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class ClientesListPage extends StatefulWidget {
  @override
  _ClientesListPageState createState() => _ClientesListPageState();
}

class _ClientesListPageState extends State<ClientesListPage> {
  final ClienteProvider _clientProvider = new ClienteProvider();
  final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  ScrollController _scrollController = new ScrollController();
  Paginacion _paginacion = new Paginacion();
  int _nextPage = 1;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _clientProvider.getClientsList(pagina: _nextPage).then((response) {
      setState(() {
        _paginacion = response['paginacion'];
      });
    }).catchError((error) {
      print(error);
      _clientProvider.disposeStream();
    });

    _scrollController.addListener(_handleController);
  }

  @override
  void dispose() {
    super.dispose();
    _clientProvider.token.cancel();
    _clientProvider.disposeStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
      ),
      body: Stack(
        children: <Widget>[
          _createFutureBuilderClient(context),
          _createLoading()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goClient(context, null),
      ),
      drawer: DrawerMenu(),
    );
  }

  Widget _createFutureBuilderClient(BuildContext context) {
    return StreamBuilder(
      stream: _clientProvider.ventasStream,
      builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
        return snapshot.hasData
            ? _createListClient(snapshot.data)
            : snapshot.hasError
                ? _customAlertDialog.showErrorInBuilders(context)
                : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _createListClient(List<Cliente> clientes) {
    return clientes.length > 0
        ? ListView.builder(
            controller: _scrollController,
            itemCount: clientes.length,
            itemBuilder: (BuildContext context, int index) {
              return _createItem(context, clientes[index]);
            },
          )
        : Center(
            child: Text(
            'No hay resultados para clientes.',
            style: TextStyle(fontSize: 20),
          ));
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
              onTap: () => _goClient(context, cliente.idCliente.toString())),
          Divider()
        ],
      ),
    );
  }

  Widget _createLoading() {
    return _isLoading
        ? Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Center(child: CircularProgressIndicator()),
                SizedBox(
                  height: 20.0,
                )
              ])
        : Container();
  }

  void _handleController() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_paginacion.pagSiguiente == null) return;
      _nextPage++;
      setState(() {
        _isLoading = true;
      });
      try {
        final response =
            await _clientProvider.getClientsList(pagina: _nextPage);
        setState(() {
          _paginacion = response['paginacion'];
          _isLoading = false;
        });
        _scrollController.animateTo(_scrollController.position.pixels + 50,
            duration: Duration(milliseconds: 450), curve: Curves.fastOutSlowIn);
      } catch (e) {
        _clientProvider.disposeStream();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

void _goClient(BuildContext context, String idCliente) {
  Navigator.pushNamed(context, 'clientes/form',
      arguments: idCliente == null || idCliente.isEmpty ? null : idCliente);
}
