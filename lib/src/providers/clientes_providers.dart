import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/utils/api.dart';

class ClienteProvider {
  Dio dio = new Dio();
  CancelToken token = CancelToken();
  List<Cliente> _clientes = [];

  final _clientesStreamController = new StreamController<List<Cliente>>();

  Function(List<Cliente>) get ventasSink => _clientesStreamController.sink.add;

  Function(dynamic) get ventasAddError =>
      _clientesStreamController.sink.addError;

  Stream<List<Cliente>> get ventasStream => _clientesStreamController.stream;

  void disposeStream() {
    _clientesStreamController?.close();
  }

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

  // Future<List<Cliente>> getClientsList({ int pagina = 1}) async {
  //   try {
  //     var response = await dio.get('$apiUrl/api/clientes', cancelToken: token,queryParameters: {'pagina': pagina, 'filas': 10});
  //     final dynamic decodedData = response.data;
  //     if (decodedData == null) return [];
  //     final data = new Clientes.fromJsonList(decodedData);
  //     return data.clientes;
  //   } catch (e) {
  //     return e;
  //   }
  // }

  Future<Map<String, dynamic>> getClientsList({int pagina = 1}) async {
    try {
      final response = await dio.get('$apiUrl/api/clientes',
          cancelToken: token, queryParameters: {'pagina': pagina, 'filas': 10});
      final dynamic decodedData = response.data;
      final clientes = new Cliente.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      _clientes.addAll(clientes.items);
      ventasSink(_clientes);
      return {'ventas': clientes.items, 'paginacion': paginacion};
    } catch (e) {
      ventasAddError(e);
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
