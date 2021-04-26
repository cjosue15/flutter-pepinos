class VentaDetalle {
  VentaDetalle({
    this.idItem,
    this.idUnidadMedida,
    this.cantidad,
    this.precioUnitario,
    this.idInvernadero,
    this.idProducto,
  });

  int idItem;
  int idUnidadMedida;
  int cantidad;
  double precioUnitario;
  int idInvernadero;
  int idProducto;

  factory VentaDetalle.fromJson(Map<String, dynamic> json) => VentaDetalle(
        idItem: json["id_item"],
        idUnidadMedida: json["id_unidad_medida"],
        cantidad: json["cantidad"],
        precioUnitario: json["precio_unitario"].toDouble(),
        idInvernadero: json["id_invernadero"],
        idProducto: json["id_producto"],
      );

  Map<String, dynamic> toJson() => {
        "id_item": idItem,
        "id_unidad_medida": idUnidadMedida,
        "cantidad": cantidad,
        "precio_unitario": precioUnitario,
        "id_invernadero": idInvernadero,
        "id_producto": idProducto,
      };
}
