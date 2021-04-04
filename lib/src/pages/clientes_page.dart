import 'package:flutter/material.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/providers/clientes_providers.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class ClientesPage extends StatefulWidget {
  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClienteProvider _clientProvider = new ClienteProvider();

  final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _clientProvider.token.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add), onPressed: () => _goClient(context, null))
        ],
      ),
      body: _createFutureBuilderClient(context),
      drawer: DrawerMenu(),
    );
  }

  Widget _createFutureBuilderClient(BuildContext context) {
    return FutureBuilder(
      future: _clientProvider.getClients(),
      builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
        return snapshot.hasData
            ? _createListClient(snapshot.data)
            : snapshot.hasError
                ? showError(context)
                : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _createListClient(List<Cliente> clientes) {
    return clientes.length > 0
        ? ListView.builder(
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
              title: Text(cliente.nombres),
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

  showError(BuildContext context) {
    Future.delayed(
        Duration.zero,
        () => _customAlertDialog.errorAlert(
              context: context,
            ));
    return Container();
  }
}

void _goClient(BuildContext context, String idCliente) {
  Navigator.pushNamed(context, 'clientes/form',
      arguments: idCliente == null || idCliente.isEmpty ? null : idCliente);
}
