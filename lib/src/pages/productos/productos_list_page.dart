import 'package:flutter/material.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
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
  ScrollController _scrollController = new ScrollController();
  bool _isLoading = false;
  int _nextPage = 1;
  Paginacion _paginacion = new Paginacion();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleController);

    _productosProvider.getAllProducts().then((response) {
      setState(() {
        _paginacion = response['paginacion'];
      });
    }).catchError((onError) {
      _productosProvider.disposeStream();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _productosProvider?.disposeStream();
    _productosProvider.token.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      drawer: DrawerMenu(),
      body: Stack(
        children: <Widget>[
          _createStreamBuilderProducts(context),
          _createLoading()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goFormPage(context, null),
      ),
    );
  }

  _createStreamBuilderProducts(BuildContext context) {
    return StreamBuilder(
      stream: _productosProvider.productosStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? _createListProduct(snapshot.data)
            : snapshot.hasError
                ? _customAlertDialog.showErrorInBuilders(context)
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

  _goFormPage(BuildContext context, String idProducto) {
    Navigator.pushNamed(context, 'productos/form',
        arguments:
            idProducto == null || idProducto.isEmpty ? null : idProducto);
  }

  _handleController() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_paginacion.pagSiguiente == null) return;
      _nextPage++;
      setState(() {
        _isLoading = true;
      });
      try {
        final response =
            await _productosProvider.getAllProducts(pagina: _nextPage);
        setState(() {
          _paginacion = response['paginacion'];
          _isLoading = false;
        });
        _scrollController.animateTo(_scrollController.position.pixels + 50,
            duration: Duration(milliseconds: 450), curve: Curves.fastOutSlowIn);
      } catch (e) {
        _productosProvider.disposeStream();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
