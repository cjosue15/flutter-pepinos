// To parse this JSON data, do
//
//     final invernadero = invernaderoFromJson(jsonString);

import 'dart:convert';

Invernadero invernaderoFromJson(String str) =>
    Invernadero.fromJson(json.decode(str));

String invernaderoToJson(Invernadero data) => json.encode(data.toJson());

String invernaderoToJsonRequestPut(Invernadero data) =>
    json.encode(data.toJsonPUT());

class Invernadero {
  Invernadero(
      {this.idInvernadero,
      this.nombreInvernadero,
      this.idEstado,
      this.productosSeleccionados,
      this.productosNoSeleccionados,
      this.cantidadProductos});

  int idInvernadero;
  String nombreInvernadero;
  int idEstado;
  int cantidadProductos;
  List<int> productosSeleccionados;
  List<int> productosNoSeleccionados;
  List<Invernadero> items = [];

  Invernadero.fromJsonList({List<dynamic> jsonList}) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      this.items.add(new Invernadero.fromJson(item));
    }
  }

  factory Invernadero.fromJson(Map<String, dynamic> json) => Invernadero(
        idInvernadero: json["id_invernadero"],
        nombreInvernadero: json["nombre_invernadero"],
        idEstado: json["id_estado"],
        cantidadProductos: json['cantidad_productos'],
        productosSeleccionados:
            json.containsKey("productos") && json["productos"].length > 0
                ? List<int>.from(
                    json["productos"].map((item) => item["id_producto"]))
                : [],
      );

  Map<String, dynamic> toJson() => {
        "nombre_invernadero": nombreInvernadero,
        "productos_seleccionados": productosSeleccionados
      };

  Map<String, dynamic> toJsonPUT() => {
        "nombre_invernadero": nombreInvernadero,
        "productos_seleccionados": productosSeleccionados,
        "productos_no_seleccionados": productosNoSeleccionados
      };
}

InvernaderoFilter invernaderoFilterFromJson(String str) =>
    InvernaderoFilter.fromJson(json.decode(str));

String invernaderoFilterToJson(InvernaderoFilter data) =>
    json.encode(data.toJson());

class InvernaderoFilter {
  int pagina;
  int filas;

  InvernaderoFilter({
    this.pagina = 1,
    this.filas = 12,
  });

  factory InvernaderoFilter.fromJson(Map<String, dynamic> json) =>
      InvernaderoFilter(
        pagina: json["pagina"],
        filas: json["filas"],
      );

  Map<String, dynamic> toJson() => {
        "pagina": pagina,
        "filas": filas,
      };
}
