import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:dio/dio.dart';
import 'package:pepinos/src/utils/api.dart';

class DropdownProvider {
  Dio dio;
  DropdownProvider() {
    dio = new Dio();
  }

  Future<List<DropdownItem>> getClientsCombo() async {
    List<DropdownItem> items = [];
    try {
      final response = await dio.get('$apiUrl/api/clientes/combo');
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

  Future<List<DropdownItem>> getCampaniasCombo() async {
    List<DropdownItem> items = [];
    try {
      final response = await dio.get('$apiUrl/api/campanias/combo');
      final dynamic decodedData = response.data;
      if (decodedData == null) return [];
      for (final item in decodedData) {
        items.add(new DropdownItem.fromJsonMap(
            json: item,
            idValue: item['id_campania'],
            textValue: item['nombre_campania']));
      }
      return items;
    } catch (e) {
      return e;
    }
  }

  Future<List<DropdownItem>> getInvernaderosCombo() async {
    List<DropdownItem> items = [];
    try {
      final response = await dio.get('$apiUrl/api/invernaderos/combo');
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
      final response = await dio.get('$apiUrl/api/tablageneral/2');
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
      );
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

  Future<dynamic> getProductosCombo() async {
    try {
      final response = await dio.get('$apiUrl/api/productos/combo');
      final dynamic decodedData = response.data;
      return decodedData;
    } catch (e) {
      return e;
    }
  }
}
