import 'dart:convert';

VentasDetalle ventasDetalleFromJson(String str) =>
    VentasDetalle.fromJson(json.decode(str));

String ventasDetalleToJson(VentasDetalle data) => json.encode(data.toJson());

class VentasDetalle {
  VentasDetalle({
    this.idVentaDetalle,
    this.idVentaCabecera,
    this.idUnidadMedida,
    this.cantidad,
    this.precioUnitario,
    this.idProducto,
  });

  int idVentaDetalle;
  int idVentaCabecera;
  int idUnidadMedida;
  int cantidad;
  double precioUnitario;
  int idProducto;

  factory VentasDetalle.fromJson(Map<String, dynamic> json) => VentasDetalle(
        idVentaDetalle: json["id_venta_detalle"],
        idVentaCabecera: json["id_venta_cabecera"],
        idUnidadMedida: json["id_unidad_medida"],
        cantidad: json["cantidad"],
        precioUnitario: json["precio_unitario"].toDouble(),
        idProducto: json["id_producto"],
      );

  Map<String, dynamic> toJson() => {
        "id_venta_detalle": idVentaDetalle,
        "id_venta_cabecera": idVentaCabecera,
        "id_unidad_medida": idUnidadMedida,
        "cantidad": cantidad,
        "precio_unitario": precioUnitario,
        "id_producto": idProducto,
      };
}
