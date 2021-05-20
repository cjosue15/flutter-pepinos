import 'package:flutter/material.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/producto_model.dart';
import 'package:pepinos/src/providers/productos/productos_provider.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';
import 'package:pepinos/src/widgets/infinite_list_view.dart';

class ProductosListPage extends StatefulWidget {
  @override
  _ProductosListPageState createState() => _ProductosListPageState();
}

class _ProductosListPageState extends State<ProductosListPage> {
  ProductosProvider _productosProvider = new ProductosProvider();
  ProductoFilter _productoFilter = new ProductoFilter();
  bool _isFetching = false;
  bool _isInitialLoading = false;
  bool _hasInitialError = false;
  bool _hasErrorAfterFetching = false;
  Paginacion _paginacion = new Paginacion();
  List<Producto> _productos = [];
  bool _isDeleting = false;
  StateSetter stateModal;
  CustomAlertDialog _customAlertDialog = new CustomAlertDialog();

  @override
  void initState() {
    super.initState();
    setState(() {
      _hasInitialError = false;
      _isInitialLoading = true;
    });
    _productosProvider
        .getAllProducts(productoFilter: _productoFilter)
        .then((response) {
      setState(() {
        _paginacion = response['paginacion'];
        _productos = response['productos'];
        _hasInitialError = false;
        _isInitialLoading = false;
      });
    }).catchError((onError) {
      setState(() {
        _hasInitialError = true;
        _isInitialLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos'),
      ),
      drawer: DrawerMenu(),
      body: InfiniteListView(
        context: context,
        data: _productos,
        length: _productos.length,
        paginacion: _paginacion,
        hasInitialError: _hasInitialError,
        hasErrorAfterFetching: _hasErrorAfterFetching,
        isFetching: _isFetching,
        isInitialLoading: _isInitialLoading,
        onScroll: (int pagina) async {
          setState(() {
            _hasErrorAfterFetching = false;
            _isFetching = true;
          });
          try {
            _productoFilter.pagina = pagina;
            final response = await _productosProvider.getAllProducts(
                productoFilter: _productoFilter);
            _productos.addAll(response['productos']);
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
        itemBuilder: (context, item, index) => _createItem(context, item),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goFormPage(context, null),
      ),
    );
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
            onTap: () => _goFormPage(
              context,
              producto.idProducto.toString(),
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
                                  title: Text('Eliminar producto'),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                'Todo lo relacionado con el producto'),
                                        TextSpan(
                                            text:
                                                ' ${producto.nombreProducto} ',
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
                                          : () => onDelete(producto),
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

  _goFormPage(BuildContext context, String idProducto) {
    Navigator.pushNamed(context, 'productos/form',
        arguments:
            idProducto == null || idProducto.isEmpty ? null : idProducto);
  }

  onDelete(Producto producto) async {
    _isDeleting = true;
    setState(() {});
    stateModal(() {});
    try {
      final message =
          await _productosProvider.deleteProductos(producto.idProducto);
      final index = _productos
          .indexWhere((element) => element.idProducto == producto.idProducto);
      _productos.removeAt(index);
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
