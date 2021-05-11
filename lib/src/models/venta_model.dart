import 'dart:convert';
import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
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
    this.fechaVenta,
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
  String fechaVenta;
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
        fechaVenta: json["fecha_venta"] != null
            ? dateFormFromDatabase(json["fecha_venta"])
            : null,
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
        "fecha_venta": dateFormatToDatabase(fechaVenta),
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
      {this.idVentaPago, this.montoPagado, this.fechaPago, this.detallePago});

  int idVentaPago;
  double montoPagado;
  String fechaPago;
  String detallePago;

  factory VentaPago.fromJson(Map<String, dynamic> json) => VentaPago(
        idVentaPago: json["id_venta_pago"],
        detallePago: json["detalle_pago"],
        montoPagado: json["monto_pagado"].toDouble(),
        fechaPago: dateFormFromDatabase(json["fecha_pago"]),
      );

  Map<String, dynamic> toJson() => {
        // "id_venta_pago": idVentaPago,
        // "numero_comprobante": numeroComprobante,
        "monto_pagado": montoPagado,
        "fecha_pago": dateFormatToDatabase(fechaPago),
        "detalle_pago": detallePago
      };
}

class VentaFilterListado {
  List<DropdownItem> campanias;
  List<DropdownItem> invernaderos;
  List<DropdownItem> clientes;
  List<DropdownItem> estados;

  VentaFilterListado(
      {this.campanias, this.clientes, this.invernaderos, this.estados});
}

VentaFilter ventaFilterFromJson(String str) =>
    VentaFilter.fromJson(json.decode(str));

String ventaFilterToJson(VentaFilter data) => json.encode(data.toJson());

class VentaFilter {
  int pagina;
  int filas;
  int idCliente;
  int idCampania;
  int idInvernadero;
  int idEstado;
  String fechaDesde;
  String fechaHasta;
  double montoMinimo;
  double montoMaximo;

  VentaFilter(
      {this.pagina = 1,
      this.filas = 10,
      this.idCliente,
      this.idCampania,
      this.idEstado,
      this.idInvernadero,
      this.fechaDesde,
      this.fechaHasta,
      this.montoMinimo,
      this.montoMaximo});

  int get page => this.pagina;

  set nextPage(int value) {
    this.pagina = value;
  }

  factory VentaFilter.fromJson(Map<String, dynamic> json) => VentaFilter(
        pagina: json["pagina"],
        filas: json["filas"],
        idCliente: json["idCliente"],
        idCampania: json["idCampania"],
        idEstado: json["idEstado"],
        fechaDesde: json["fechaDesde"],
        fechaHasta: json["fechaHasta"],
      );

  Map<String, dynamic> toJson() => {
        "pagina": pagina,
        "filas": filas,
        "idCliente": idCliente ?? 0,
        "idCampania": idCampania ?? 0,
        "idEstado": idEstado ?? 0,
        "idInvernadero": idInvernadero ?? 0,
        "fechaDesde": fechaDesde,
        "fechaHasta": fechaHasta,
        "montoMinimo": montoMinimo ?? 0,
        "montoMaximo": montoMaximo ?? 0,
      };
}
