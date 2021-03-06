import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pepinos/src/models/invernadero.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/utils/api.dart';

class InvernaderoProvider {
  Dio dio;
  InvernaderoProvider() {
    dio = new Dio();
  }

  Future<String> updateInvernadero(
      String idInvernadero, Invernadero invernadero) async {
    try {
      final response = await dio.put(
        '$apiUrl/api/invernaderos/$idInvernadero',
        data: invernaderoToJsonRequestPut(invernadero),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<Invernadero> getInvernadero(String idInvernadero) async {
    try {
      final response = await dio.get(
        '$apiUrl/api/invernaderos/$idInvernadero',
      );
      final decodedData = response.data;
      final invernadero = Invernadero.fromJson(decodedData);
      return invernadero;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<String> createInvernadero(Invernadero invernadero) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/invernaderos',
        data: invernaderoToJson(invernadero),
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

  Future<Map<String, dynamic>> getAllInvernaderos(
      {InvernaderoFilter invernaderoFilter}) async {
    try {
      final response = await dio.get('$apiUrl/api/invernaderos',
          queryParameters: invernaderoFilter.toJson());
      final dynamic decodedData = response.data;
      final invernaderos =
          new Invernadero.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      return {'invernaderos': invernaderos.items, 'paginacion': paginacion};
    } catch (e) {
      return e;
    }
  }

  Future<String> deleteInvernadero(int idInvernadero) async {
    try {
      final response = await dio.delete(
        '$apiUrl/api/invernaderos/$idInvernadero',
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }
}
