import 'package:flutter/material.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/providers/clientes_providers.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class ClientesPage extends StatelessWidget {
  final ClienteProvider _clientProvider = new ClienteProvider();
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
      body: _createFutureBuilderClient(),
      drawer: DrawerMenu(),
    );
  }

  Widget _createFutureBuilderClient() {
    return FutureBuilder(
      future: _clientProvider.getClients(),
      builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
        return snapshot.hasData
            ? _createListClient(snapshot.data)
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
}

void _goClient(BuildContext context, String idCliente) {
  Navigator.pushNamed(context, 'clientes/formulario',
      arguments: idCliente == null || idCliente.isEmpty ? null : idCliente);
}
