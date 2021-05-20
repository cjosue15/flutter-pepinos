import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/campanias_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/utils/api.dart';

class CampaniasProvider {
  Dio dio;
  CampaniasProvider() {
    dio = new Dio();
  }

  Future<String> updateCampanias(String idCampania, Campania campania) async {
    try {
      final response = await dio.put(
        '$apiUrl/api/campanias/$idCampania',
        data: campaniaToJson(campania),
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

  Future<Campania> getCampania(String idCampania) async {
    try {
      final response = await dio.get(
        '$apiUrl/api/campanias/$idCampania',
      );
      final decodedData = response.data;
      final campania = Campania.fromJson(decodedData);
      return campania;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<String> createCampania(Campania campania) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/campanias',
        data: campaniaToJson(campania),
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

  Future<String> deleteCampania(int idCampania) async {
    try {
      final response = await dio.delete(
        '$apiUrl/api/campanias/$idCampania',
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }

  Future<Map<String, dynamic>> getAllCampanias(
      {CampaniaFilter campaniaFilter}) async {
    try {
      final response = await dio.get('$apiUrl/api/campanias',
          queryParameters: campaniaFilter.toJson());
      final dynamic decodedData = response.data;
      final campanias =
          new Campania.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      return {'campanias': campanias.items, 'paginacion': paginacion};
    } catch (e) {
      return e;
    }
  }
}
