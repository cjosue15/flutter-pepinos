// To parse this JSON data, do
//
//     final venta = ventaFromJson(jsonString);

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pepinos/src/utils/date_format.dart';

Venta ventaFromJson(String str) => Venta.fromJson(json.decode(str));

String ventaToJson(Venta data) => json.encode(data.toJson());

class Venta {
  Venta({
    this.numeroComprobante,
    this.idCliente,
    this.cliente,
    this.montoTotal,
    this.montoPagado,
    this.idCampania,
    this.nombreCampania,
    this.idEstado,
    this.estado,
    this.fechaCreacion,
    this.ventaDetalles,
    this.ventaPagos,
  });

  String numeroComprobante;
  int idCliente;
  String cliente;
  double montoTotal;
  double montoPagado;
  int idCampania;
  String nombreCampania;
  int idEstado;
  String estado;
  String fechaCreacion;
  List<VentaDetalle> ventaDetalles;
  List<VentaPago> ventaPagos;
  List<Venta> items = [];

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
        numeroComprobante: json["numero_comprobante"],
        idCliente: json["id_cliente"],
        cliente: json["cliente"],
        montoTotal: json["monto_total"].toDouble(),
        montoPagado: json["monto_pagado"]?.toDouble(),
        idCampania: json["id_campania"],
        nombreCampania: json["nombre_campania"],
        idEstado: json["id_estado"],
        estado: json["estado"],
        // fechaVenta: json.containsKey("fecha_venta")
        //     ? DateTime.parse(json["fecha_venta"])
        //     : null,
        fechaCreacion: dateTimeToString(json["fecha_creacion"]),
        ventaDetalles: json.containsKey("venta_detalles")
            ? List<VentaDetalle>.from(
                json["venta_detalles"]?.map((x) => VentaDetalle.fromJson(x)))
            : [],
        ventaPagos: json.containsKey("venta_pagos")
            ? List<VentaPago>.from(
                json["venta_pagos"].map((x) => VentaPago.fromJson(x)))
            : [],
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
        "monto_total": montoTotal,
        "id_campania": idCampania,
        "fecha_venta": dateFormatToDatabase(fechaCreacion),
        "monto_pagado": montoPagado,
        "detalle_pago": "Primer pago",
        // "id_estado": idEstado,
        // "cliente": cliente,
        // "nombre_campania": nombreCampania,
        // "estado": estado,
        // "venta_detalles":
        "venta_detalles":
            List<dynamic>.from(ventaDetalles.map((x) => x.toJson())),
        // "venta_pagos": ventaPagos != null
        //     ? List<dynamic>.from(ventaPagos.map((x) => x.toJson()))
        //     : null,
      };
}

VentaDetalle ventasDetalleFromJson(String str) =>
    VentaDetalle.fromJson(json.decode(str));

String ventasDetalleToJson(VentaDetalle data) => json.encode(data.toJson());

class VentaDetalle {
  VentaDetalle({
    this.idItem,
    this.idUnidadMedida,
    this.unidadMedida,
    this.cantidad,
    this.precioUnitario,
    this.idInvernadero,
    this.nombreInvernadero,
    this.idProducto,
    this.nombreProducto,
  });

  int idItem;
  int idUnidadMedida;
  String unidadMedida;
  int cantidad;
  double precioUnitario;
  int idInvernadero;
  String nombreInvernadero;
  int idProducto;
  String nombreProducto;

  factory VentaDetalle.fromJson(Map<String, dynamic> json) => VentaDetalle(
        idItem: json["id_item"],
        idUnidadMedida: json["id_unidad_medida"],
        unidadMedida: json["unidad_medida"],
        cantidad: json["cantidad"],
        precioUnitario: json["precio_unitario"].toDouble(),
        idInvernadero: json["id_invernadero"],
        nombreInvernadero: json["nombre_invernadero"],
        idProducto: json["id_producto"],
        nombreProducto: json["nombre_producto"],
      );

  Map<String, dynamic> toJson() => {
        "id_item": idItem,
        "id_unidad_medida": idUnidadMedida,
        // "unidad_medida": unidadMedida,
        "cantidad": cantidad,
        "precio_unitario": precioUnitario,
        "id_invernadero": idInvernadero,
        // "nombre_invernadero": nombreInvernadero,
        "id_producto": idProducto,
        // "nombre_producto": nombreProducto,
      };
}

VentaPago ventaPagoFromJson(String str) => VentaPago.fromJson(json.decode(str));

String ventaPagoToJson(VentaPago data) => json.encode(data.toJson());

class VentaPago {
  VentaPago(
      {this.idVentaPago,
      // this.numeroComprobante,
      this.montoPagado,
      this.fechaPago,
      this.detallePago});

  int idVentaPago;
  // String numeroComprobante;
  double montoPagado;
  String fechaPago;
  String detallePago;

  factory VentaPago.fromJson(Map<String, dynamic> json) => VentaPago(
        idVentaPago: json["id_venta_pago"],
        detallePago: json["detalle_pago"],
        // numeroComprobante: json["numero_comprobante"],
        montoPagado: json["monto_pagado"].toDouble(),
        fechaPago: dateTimeToString(json["fecha_pago"]),
      );

  Map<String, dynamic> toJson() => {
        // "id_venta_pago": idVentaPago,
        // "numero_comprobante": numeroComprobante,
        "monto_pagado": montoPagado,
        "fecha_pago": dateFormatToDatabase(fechaPago),
        "detalle_pago": detallePago
      };
}
