import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/producto_model.dart';
import 'package:pepinos/src/utils/api.dart';

class ProductosProvider {
  Dio dio = new Dio();
  CancelToken token = CancelToken();
  List<Producto> _productos = [];

  final _productosStreamController = new StreamController<List<Producto>>();

  Function(List<Producto>) get productosSink =>
      _productosStreamController.sink.add;

  Function(dynamic) get productosAddError =>
      _productosStreamController.sink.addError;

  Stream<List<Producto>> get productosStream =>
      _productosStreamController.stream;

  void disposeStream() {
    _productosStreamController?.close();
  }

  Future<dynamic> createProduct(Producto producto) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/productos',
        cancelToken: token,
        data: productoToJson(producto),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }

  Future<Map<String, dynamic>> getAllProducts({int pagina = 1}) async {
    try {
      final response = await dio.get('$apiUrl/api/productos',
          cancelToken: token, queryParameters: {'pagina': pagina, 'filas': 10});
      final dynamic decodedData = response.data;
      final productos =
          new Producto.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      _productos.addAll(productos.items);
      productosSink(_productos);
      return {'ventas': productos.items, 'paginacion': paginacion};
    } catch (e) {
      productosAddError(e);
      return e;
    }
  }

  Future<Producto> getProduct(String idProducto) async {
    try {
      final response = await dio.get('$apiUrl/api/productos/$idProducto',
          cancelToken: token);
      Map<String, dynamic> decodedData = response.data;
      final Producto producto = Producto.fromJson(decodedData);
      return producto;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<dynamic> updateProduct(Producto producto) async {
    try {
      final response = await dio.put(
        '$apiUrl/api/productos/${producto.idProducto}',
        cancelToken: token,
        data: productoToJson(producto),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }
}
