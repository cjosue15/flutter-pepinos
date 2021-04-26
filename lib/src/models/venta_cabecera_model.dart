// To parse this JSON data, do
//
//     final ventaCabecera = ventaCabeceraFromJson(jsonString);

import 'dart:convert';

import 'package:pepinos/src/models/venta_detalle_model.dart';

VentaCabecera ventaCabeceraFromJson(String str) =>
    VentaCabecera.fromJson(json.decode(str));

String ventaCabeceraToJson(VentaCabecera data) => json.encode(data.toJson());

class VentaCabecera {
  VentaCabecera({
    this.idCliente,
    this.montoTotal,
    this.montoPagado,
    this.idEstado,
    this.ventaDetalle,
  });

  int idCliente;
  double montoTotal;
  double montoPagado;
  int idEstado;
  List<VentaDetalle> ventaDetalle;

  factory VentaCabecera.fromJson(Map<String, dynamic> json) => VentaCabecera(
        idCliente: json["id_cliente"],
        montoTotal: json["monto_total"].toDouble(),
        montoPagado: json["monto_pagado"].toDouble(),
        idEstado: json["id_estado"],
        ventaDetalle: List<VentaDetalle>.from(
            json["venta_detalle"].map((x) => VentaDetalle.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id_cliente": idCliente,
        "monto_total": montoTotal,
        "monto_pagado": montoPagado,
        "id_estado": idEstado,
        "venta_detalle":
            List<dynamic>.from(ventaDetalle.map((x) => x.toJson())),
      };
}
