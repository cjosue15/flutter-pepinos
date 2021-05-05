// To parse this JSON data, do
//
//     final invernadero = invernaderoFromJson(jsonString);

import 'dart:convert';

Invernadero invernaderoFromJson(String str) =>
    Invernadero.fromJson(json.decode(str));

String invernaderoToJson(Invernadero data) => json.encode(data.toJson());

class Invernadero {
  Invernadero(
      {this.idInvernadero,
      this.nombreInvernadero,
      this.idEstado,
      this.productosSeleccionados});

  int idInvernadero;
  String nombreInvernadero;
  int idEstado;
  List<int> productosSeleccionados;

  factory Invernadero.fromJson(Map<String, dynamic> json) => Invernadero(
      idInvernadero: json["id_invernadero"],
      nombreInvernadero: json["nombre_invernadero"],
      idEstado: json["id_estado"],
      productosSeleccionados: json["productos"].length > 0
          ? json["productos"].map((item) => item["id_producto"]).toList()
          : null);

  Map<String, dynamic> toJson() => {
        "nombre_invernadero": nombreInvernadero,
        "productos_seleccionados": productosSeleccionados
      };
}
