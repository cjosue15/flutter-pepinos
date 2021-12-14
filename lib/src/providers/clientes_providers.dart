import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/utils/api.dart';

class ClienteProvider {
  Dio dio = new Dio();

  Future<dynamic> createClient(Cliente cliente) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/clientes',
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

  Future<Map<String, dynamic>> getClientsList(
      {ClienteFilter clienteFilter}) async {
    try {
      final response = await dio.get('$apiUrl/api/clientes',
          queryParameters: clienteFilter.toJson());
      final dynamic decodedData = response.data;
      final clientes = new Cliente.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      return {'clientes': clientes.items, 'paginacion': paginacion};
    } catch (e) {
      return e;
    }
  }

  Future<Cliente> getClient(String idCliente) async {
    try {
      final response = await dio.get('$apiUrl/api/clientes/$idCliente');
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

  Future<String> deleteCliente(int idCliente) async {
    try {
      final response = await dio.delete(
        '$apiUrl/api/clientes/$idCliente',
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }

  // Reportes

  Future<Map<String, dynamic>> clienteReporteVentas(
      {String idCliente, String year, String month}) async {
    try {
      final responseTotales = await dio.get(
        '$apiUrl/api/clientes/reporte/1?idCliente=$idCliente&periodo=${year + month.padLeft(2, '0')}',
      );
      final responseVentas = await dio.get(
        '$apiUrl/api/clientes/reporte/2?idCliente=$idCliente&periodo=${year + month.padLeft(2, '0')}',
      );
      final decodedDataVentas = responseVentas.data;
      final ventas = new Venta.fromJsonList(jsonList: decodedDataVentas);
      final decodedDataTotales = responseTotales.data[0];
      final totales = new ClienteReporteTotal.fromJson(decodedDataTotales);

      return {'ventas': ventas.items, 'totales': totales};
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future downloadReportByClient(String id) async {
    try {
      Response response = await dio.get(
        '$apiUrl/api/clientes/excel/$id',
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status < 500;
            }),
      );
      final name = response.headers.value('filename');
      File file = File('/storage/emulated/0/Download/$name');
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
      return e;
    }
  }
}
