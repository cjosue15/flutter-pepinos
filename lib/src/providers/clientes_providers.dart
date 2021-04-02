import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pepinos/src/models/cliente_model.dart';

class ClienteProvider {
  final String url = '192.168.1.24:8080';

  Future<dynamic> createProduct(Cliente cliente) async {
    try {
      final response = await http.post(Uri.http(url, '/api/clientes'),
          body: clienteToJson(cliente),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      final decodedData = json.decode(response.body);
      return decodedData['msg'];
    } catch (e) {
      return throw (e);
    }
  }

  Future<List<Cliente>> getClients() async {
    try {
      final response = await http.get(
        Uri.http(url, '/api/clientes'),
      );

      final decodedData = json.decode(response.body);
      if (decodedData == null || decodedData['clientes'] == null) return [];
      final data = new Clientes.fromJsonList(decodedData['clientes']);
      return data.clientes;
    } catch (e) {
      return throw (e);
    }
  }

  Future<Cliente> getClient(String idCliente) async {
    try {
      final response = await http.get(
        Uri.http(url, '/api/clientes/$idCliente'),
      );
      Map<String, dynamic> decodedData = json.decode(response.body);
      final Cliente cliente = Cliente.fromJson(decodedData);
      return cliente;
    } catch (e) {
      return throw (e);
    }
  }

  Future<dynamic> updateClient(Cliente cliente) async {
    try {
      final response = await http.put(
          Uri.http(url, '/api/clientes/${cliente.idCliente}'),
          body: clienteToJson(cliente),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          });
      final decodedData = json.decode(response.body);
      return decodedData['msg'];
    } catch (e) {
      return throw (e);
    }
  }
}
