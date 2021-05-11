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
      this.productosNoSeleccionados});

  int idInvernadero;
  String nombreInvernadero;
  int idEstado;
  List<int> productosSeleccionados;
  List<int> productosNoSeleccionados;

  factory Invernadero.fromJson(Map<String, dynamic> json) => Invernadero(
        idInvernadero: json["id_invernadero"],
        nombreInvernadero: json["nombre_invernadero"],
        idEstado: json["id_estado"],
        productosSeleccionados: json["productos"].length > 0
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
