import 'package:flutter/material.dart';
import 'package:pepinos/src/models/producto_model.dart';
import 'package:pepinos/src/providers/productos/productos_provider.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class ProductosListPage extends StatefulWidget {
  @override
  _ProductosListPageState createState() => _ProductosListPageState();
}

class _ProductosListPageState extends State<ProductosListPage> {
  final ProductosProvider _productosProvider = new ProductosProvider();
  final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      drawer: DrawerMenu(),
      body: _createFutureBuilderProducts(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goFormPage(context, null),
      ),
    );
  }

  _createFutureBuilderProducts(BuildContext context) {
    return FutureBuilder(
      future: _productosProvider.getAllProducts(),
      builder: (BuildContext context, AsyncSnapshot<List<Producto>> snapshot) {
        return snapshot.hasData
            ? _createListProduct(snapshot.data)
            : snapshot.hasError
                ? showError(context)
                : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _createListProduct(List<Producto> productos) {
    return productos.length > 0
        ? ListView.builder(
            itemCount: productos.length,
            itemBuilder: (BuildContext context, int index) {
              return _createItem(context, productos[index]);
            },
          )
        : Center(
            child: Text(
            'No hay resultados para productos.',
            style: TextStyle(fontSize: 20),
          ));
  }

  Widget _createItem(BuildContext context, Producto producto) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
              title: Text(producto.nombreProducto),
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.green,
              ),
              onTap: () =>
                  _goFormPage(context, producto.idProducto.toString())),
          Divider()
        ],
      ),
    );
  }

  _goFormPage(BuildContext context, String idProducto) {
    Navigator.pushNamed(context, 'productos/form',
        arguments:
            idProducto == null || idProducto.isEmpty ? null : idProducto);
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
