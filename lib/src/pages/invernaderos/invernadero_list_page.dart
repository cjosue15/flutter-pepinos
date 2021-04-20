import 'package:flutter/material.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class InvernaderoListPage extends StatefulWidget {
  @override
  _InvernaderoListPageState createState() => _InvernaderoListPageState();
}

class _InvernaderoListPageState extends State<InvernaderoListPage> {
  @override
  void dispose() {
    super.dispose();
    // _productosProvider.token.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invernaderos'),
      ),
      drawer: DrawerMenu(),
      // body: _createFutureBuilderInvernaderos(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goFormPage(context, null),
      ),
    );
  }

  // Widget _createFutureBuilderInvernaderos(BuildContext context) {
  //   return FutureBuilder(
  //     future: _productosProvider.getAllProducts(),
  //     builder: (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
  //       return snapshot.hasData
  //           ? _createListProduct(snapshot.data)
  //           : snapshot.hasError
  //               ? showError(context)
  //               : Center(child: CircularProgressIndicator());
  //     },
  //   );
  // }

  // Widget _createListProduct(List<Producto> productos) {
  //   return productos.length > 0
  //       ? ListView.builder(
  //           itemCount: productos.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             return _createItem(context, productos[index]);
  //           },
  //         )
  //       : Center(
  //           child: Text(
  //           'No hay resultados para productos.',
  //           style: TextStyle(fontSize: 20),
  //         ));
  // }

  // Widget _createItem(BuildContext context, Producto producto) {
  //   return Container(
  //     child: Column(
  //       children: <Widget>[
  //         ListTile(
  //             title: Text(producto.nombreProducto),
  //             trailing: Icon(
  //               Icons.keyboard_arrow_right,
  //               color: Colors.green,
  //             ),
  //             onTap: () =>
  //                 _goFormPage(context, producto.idProducto.toString())),
  //         Divider()
  //       ],
  //     ),
  //   );
  // }

  void _goFormPage(BuildContext context, String idProducto) {
    Navigator.pushNamed(context, 'invernaderos/form',
        arguments:
            idProducto == null || idProducto.isEmpty ? null : idProducto);
  }

  // showError(BuildContext context) {
  //   Future.delayed(
  //       Duration.zero,
  //       () => _customAlertDialog.errorAlert(
  //             context: context,
  //           ));
  //   return Container();
  // }
}
