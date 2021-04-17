import 'dart:convert';

VentasCabecera ventasCabeceraFromJson(String str) =>
    VentasCabecera.fromJson(json.decode(str));

String ventasCabeceraToJson(VentasCabecera data) => json.encode(data.toJson());

class VentasCabecera {
  VentasCabecera({
    this.idVentaCabecera,
    this.idInvernadero,
    this.idCliente,
    this.montoTotal,
    this.idEstado,
    this.montoPagado,
  });

  int idVentaCabecera;
  int idInvernadero;
  int idCliente;
  double montoTotal;
  int idEstado;
  double montoPagado;

  factory VentasCabecera.fromJson(Map<String, dynamic> json) => VentasCabecera(
        idVentaCabecera: json["id_venta_cabecera"],
        idInvernadero: json["id_invernadero"],
        idCliente: json["id_cliente"],
        montoTotal: json["monto_total"].toDouble(),
        idEstado: json["id_estado"],
        montoPagado: json["monto_pagado"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id_venta_cabecera": idVentaCabecera,
        "id_invernadero": idInvernadero,
        "id_cliente": idCliente,
        "monto_total": montoTotal,
        "id_estado": idEstado,
        "monto_pagado": montoPagado,
      };
}
