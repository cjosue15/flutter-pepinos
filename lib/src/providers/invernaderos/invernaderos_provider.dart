import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pepinos/src/models/invernadero.dart';
import 'package:pepinos/src/utils/api.dart';

class InvernaderoProvider {
  Dio dio;
  CancelToken token;
  List<Invernadero> _invernaderos = [];
  InvernaderoProvider() {
    dio = new Dio();
    token = CancelToken();
  }

  final _invernaderosStreamController =
      new StreamController<List<Invernadero>>();

  Function(List<Invernadero>) get invernaderosSink =>
      _invernaderosStreamController.sink.add;

  Function(dynamic) get invernaderosAddError =>
      _invernaderosStreamController.sink.addError;

  Stream<List<Invernadero>> get invernaderosStream =>
      _invernaderosStreamController.stream;

  void disposeStream() {
    _invernaderosStreamController?.close();
  }

  Future<String> updateInvernadero(
      String idInvernadero, Invernadero invernadero) async {
    try {
      final response = await dio.put(
        '$apiUrl/api/invernaderos/$idInvernadero',
        cancelToken: token,
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
        cancelToken: token,
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
        cancelToken: token,
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
}
