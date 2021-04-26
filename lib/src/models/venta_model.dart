// To parse this JSON data, do
//
//     final venta = ventaFromJson(jsonString);

import 'dart:convert';

Venta ventaFromJson(String str) => Venta.fromJson(json.decode(str));

String ventaToJson(Venta data) => json.encode(data.toJson());

class Venta {
  Venta({
    this.numeroComprobante,
    this.idCliente,
    this.cliente,
    this.montoTotal,
    this.montoPagado,
    this.fechaModificacion,
    this.idEstado,
    this.estado,
  });

  String numeroComprobante;
  int idCliente;
  String cliente;
  double montoTotal;
  double montoPagado;
  DateTime fechaModificacion;
  int idEstado;
  String estado;
  List<Venta> items = [];

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
        numeroComprobante: json["numero_comprobante"],
        idCliente: json["id_cliente"],
        cliente: json["cliente"],
        montoTotal: double.parse(json["monto_total"]),
        montoPagado: double.parse(json["monto_pagado"]),
        fechaModificacion: json.containsKey(json["fecha_modificacion"])
            ? DateTime.parse(json["fecha_modificacion"])
            : null,
        idEstado: json["id_estado"],
        estado: json["estado"],
      );

  Venta.fromJsonList({List<dynamic> jsonList}) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      items.add(new Venta.fromJson(item));
    }
  }

  Map<String, dynamic> toJson() => {
        // "numero_comprobante": numeroComprobante,
        "id_cliente": idCliente,
        "cliente": cliente,
        "monto_total": montoTotal,
        "monto_pagado": montoPagado,
        "fecha_modificacion": fechaModificacion.toIso8601String(),
        "id_estado": idEstado,
        "estado": estado,
      };
}
