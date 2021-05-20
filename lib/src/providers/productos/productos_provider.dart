import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/producto_model.dart';
import 'package:pepinos/src/utils/api.dart';

class ProductosProvider {
  Dio dio = new Dio();

  Future<dynamic> createProduct(Producto producto) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/productos',
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

  Future<Map<String, dynamic>> getAllProducts(
      {ProductoFilter productoFilter}) async {
    try {
      final response = await dio.get('$apiUrl/api/productos',
          queryParameters: productoFilter.toJson());
      final dynamic decodedData = response.data;
      final productos =
          new Producto.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      return {'productos': productos.items, 'paginacion': paginacion};
    } catch (e) {
      return e;
    }
  }

  Future<Producto> getProduct(String idProducto) async {
    try {
      final response = await dio.get(
        '$apiUrl/api/productos/$idProducto',
      );
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

  Future<String> deleteProductos(int idProducto) async {
    try {
      final response = await dio.delete(
        '$apiUrl/api/productos/$idProducto',
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }
}
