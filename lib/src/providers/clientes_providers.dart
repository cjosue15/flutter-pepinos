import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/utils/api.dart';

class ClienteProvider {
  Dio dio = new Dio();
  CancelToken token = CancelToken();

  Future<dynamic> createClient(Cliente cliente) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/clientes',
        cancelToken: token,
        data: clienteToJson(cliente),
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

  Future<List<Cliente>> getClients() async {
    try {
      var response = await dio.get('$apiUrl/api/clientes', cancelToken: token);
      final dynamic decodedData = response.data;
      if (decodedData == null) return [];
      final data = new Clientes.fromJsonList(decodedData);
      return data.clientes;
    } catch (e) {
      return e;
    }
  }

  Future<Cliente> getClient(String idCliente) async {
    try {
      final response =
          await dio.get('$apiUrl/api/clientes/$idCliente', cancelToken: token);
      Map<String, dynamic> decodedData = response.data;
      final Cliente cliente = Cliente.fromJson(decodedData);
      return cliente;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<dynamic> updateClient(Cliente cliente) async {
    try {
      final response = await dio.put(
        '$apiUrl/api/clientes/${cliente.idCliente}',
        cancelToken: token,
        data: clienteToJson(cliente),
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
