import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/producto_model.dart';
import 'package:pepinos/src/utils/api.dart';

class ProductosProvider {
  Dio dio = new Dio();
  CancelToken token = CancelToken();

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

  Future<List<Producto>> getAllProducts() async {
    try {
      final response =
          await dio.get('$apiUrl/api/productos', cancelToken: token);
      final dynamic decodedData = response.data;
      if (decodedData == null) return [];
      final data = new Producto.fromJsonList(jsonList: decodedData);
      return data.items;
    } catch (e) {
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
