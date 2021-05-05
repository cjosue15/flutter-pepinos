import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/utils/api.dart';

class VentasProvider {
  Dio dio = new Dio();
  CancelToken token = CancelToken();
  List<Venta> _ventas = [];
  final Options _options = Options(headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
  });

  final _ventasStreamController = new StreamController<List<Venta>>();

  Function(List<Venta>) get ventasSink => _ventasStreamController.sink.add;

  Function(dynamic) get ventasAddError => _ventasStreamController.sink.addError;

  Stream<List<Venta>> get ventasStream => _ventasStreamController.stream;

  void disposeStream() {
    _ventasStreamController?.close();
  }

  Future<dynamic> createVenta(Venta venta) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/ventas',
        cancelToken: token,
        data: ventaToJson(venta),
        options: _options,
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }

  Future<Venta> getOneVenta({String idVenta}) async {
    try {
      final response =
          await dio.get('$apiUrl/api/ventas/$idVenta', cancelToken: token);
      final dynamic decodedData = response.data;
      final venta = new Venta.fromJson(decodedData['venta']);
      return venta;
    } catch (e) {
      return e;
    }
  }

  Future<String> updatePago({VentaPago pago, String numeroComprobante}) async {
    try {
      final response = await dio.put('$apiUrl/api/ventas/$numeroComprobante',
          cancelToken: token, data: ventaPagoToJson(pago), options: _options);
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }

  Future<Map<String, dynamic>> getVentas({int pagina = 1}) async {
    try {
      final response = await dio.get('$apiUrl/api/ventas',
          cancelToken: token, queryParameters: {'pagina': pagina, 'filas': 10});
      final dynamic decodedData = response.data;
      final ventas = new Venta.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      _ventas.addAll(ventas.items);
      ventasSink(_ventas);
      return {'ventas': ventas.items, 'paginacion': paginacion};
    } catch (e) {
      ventasAddError(e);
      return e;
    }
  }
}
