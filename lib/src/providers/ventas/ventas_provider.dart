import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/utils/api.dart';

class VentasProvider {
  Dio dio = new Dio();
  final Options _options = Options(headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
  });

  Future<dynamic> createVenta(Venta venta) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/ventas',
        data: ventaToJson(venta),
        options: _options,
      );
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }

  Future<VentaFilterListado> getFiltersVenta() async {
    List<DropdownItem> clientes = [];
    List<DropdownItem> invernaderos = [];
    List<DropdownItem> campanias = [];
    List<DropdownItem> estados = [];
    try {
      final response = await dio.get(
        '$apiUrl/api/ventas/filtros',
      );
      final decodedData = response.data;
      for (final item in decodedData['campanias']) {
        campanias.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_campania'],
            textValue: item['nombre_campania']));
      }
      for (final item in decodedData['clientes']) {
        clientes.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_cliente'],
            textValue: item['nombres'] + ' ' + item['apellidos']));
      }
      for (final item in decodedData['invernaderos']) {
        invernaderos.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_invernadero'],
            textValue: item['nombre_invernadero']));
      }
      for (final item in decodedData['estados']) {
        estados.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_tabla_general'],
            textValue: item['descripcion']));
      }
      return VentaFilterListado(
          campanias: campanias,
          clientes: clientes,
          invernaderos: invernaderos,
          estados: estados);
    } catch (e) {
      return e;
    }
  }

  Future<Venta> getOneVenta({String idVenta}) async {
    try {
      final response = await dio.get('$apiUrl/api/ventas/$idVenta');
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
          data: ventaPagoToJson(pago), options: _options);
      final decodedData = response.data;
      return decodedData['message'];
    } catch (e) {
      return e;
    }
  }

  Future<Map<String, dynamic>> getVentas({VentaFilter ventaFilter}) async {
    try {
      final response = await dio.get('$apiUrl/api/ventas',
          queryParameters: ventaFilter.toJson());
      final dynamic decodedData = response.data;
      final ventas = new Venta.fromJsonList(jsonList: decodedData["data"]);
      final paginacion = new Paginacion.fromJson(decodedData["paginacion"]);
      return {'ventas': ventas.items, 'paginacion': paginacion};
    } catch (e) {
      return e;
    }
  }
}
