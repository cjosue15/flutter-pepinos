import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/venta_cabecera_model.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/utils/api.dart';

class VentasProvider {
  Dio dio = new Dio();
  CancelToken token = CancelToken();
  List<Venta> _ventas = [];

  final _ventasStreamController = new StreamController<List<Venta>>();

  Function(List<Venta>) get ventasSink => _ventasStreamController.sink.add;

  Function(dynamic) get ventasAddError => _ventasStreamController.sink.addError;

  Stream<List<Venta>> get ventasStream => _ventasStreamController.stream;

  void disposeStream() {
    _ventasStreamController?.close();
  }

  Future<List<DropdownItem>> getClientsCombo() async {
    List<DropdownItem> items = [];
    try {
      final response =
          await dio.get('$apiUrl/api/clientes/combo', cancelToken: token);
      final dynamic decodedData = response.data;
      if (decodedData == null) return [];
      for (final item in decodedData) {
        items.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_cliente'],
            textValue: item['nombres'] + ' ' + item['apellidos']));
      }
      return items;
    } catch (e) {
      return e;
    }
  }

  Future<List<DropdownItem>> getInvernaderosCombo() async {
    List<DropdownItem> items = [];
    try {
      final response =
          await dio.get('$apiUrl/api/invernaderos/combo', cancelToken: token);
      final dynamic decodedData = response.data;
      if (decodedData == null) return [];
      for (final item in decodedData) {
        items.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_invernadero'],
            textValue: item['nombre_invernadero']));
      }
      return items;
    } catch (e) {
      return e;
    }
  }

  Future<List<DropdownItem>> getUnidadMedidasCombo() async {
    List<DropdownItem> items = [];
    try {
      final response =
          await dio.get('$apiUrl/api/tablageneral/2', cancelToken: token);
      final dynamic decodedData = response.data;
      if (decodedData == null) return [];
      for (final item in decodedData) {
        items.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_tabla_general'],
            textValue: item['descripcion']));
      }
      return items;
    } catch (e) {
      return e;
    }
  }

  Future<List<DropdownItem>> getProductosByInvernaderoCombo(
      int idInvernadero) async {
    List<DropdownItem> items = [];
    try {
      final response = await dio.get(
          '$apiUrl/api/productos/invernadero/$idInvernadero',
          cancelToken: token);
      final dynamic decodedData = response.data;
      if (decodedData == null) return [];
      for (final item in decodedData) {
        items.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_producto'],
            textValue: item['nombre_producto']));
      }
      return items;
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> createVenta(VentaCabecera ventaCabecera) async {
    try {
      final response = await dio.post(
        '$apiUrl/api/ventas',
        cancelToken: token,
        data: ventaCabeceraToJson(ventaCabecera),
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
