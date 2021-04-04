import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/cliente_model.dart';

class ClienteProvider {
  final String url = 'http://192.168.1.24:8080';
  Dio dio = new Dio();
  CancelToken token = CancelToken();

  Future<dynamic> createProduct(Cliente cliente) async {
    try {
      final response = await dio.post(
        '$url/api/clientes',
        cancelToken: token,
        data: clienteToJson(cliente),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      final decodedData = response.data;
      return decodedData['msg'];
    } catch (e) {
      return e;
    }
  }

  Future<List<Cliente>> getClients() async {
    try {
      var response = await dio.get('$url/api/clientes', cancelToken: token);
      final dynamic decodedData = response.data;
      if (decodedData == null || decodedData['clientes'] == null) return [];
      final data = new Clientes.fromJsonList(decodedData['clientes']);
      return data.clientes;
    } catch (e) {
      return e;
    }
  }

  Future<Cliente> getClient(String idCliente) async {
    try {
      final response =
          await dio.get('$url/api/clientes/$idCliente', cancelToken: token);
      Map<String, dynamic> decodedData = response.data;
      final Cliente cliente = Cliente.fromJson(decodedData);
      return cliente;
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> updateClient(Cliente cliente) async {
    try {
      final response = await dio.put(
        '$url/api/clientes/${cliente.idCliente}',
        cancelToken: token,
        data: clienteToJson(cliente),
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        }),
      );
      final decodedData = response.data;
      return decodedData['msg'];
    } catch (e) {
      return e;
    }
  }
}
