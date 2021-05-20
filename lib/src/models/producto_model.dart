import 'dart:convert';

Producto productoFromJson(String str) => Producto.fromJson(json.decode(str));

String productoToJson(Producto data) => json.encode(data.toJson());

class Producto {
  Producto({
    this.idProducto,
    this.nombreProducto,
    this.descripcion,
    this.idEstado = 1,
  });

  int idProducto;
  String nombreProducto;
  String descripcion;
  int idEstado;
  List<Producto> items = [];

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        idProducto: json["id_producto"],
        nombreProducto: json["nombre_producto"],
        descripcion: json["descripcion"],
        idEstado: json["id_estado"],
      );

  Producto.fromJsonList({List<dynamic> jsonList}) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      items.add(new Producto.fromJson(item));
    }
  }

  Map<String, dynamic> toJson() => {
        "id_producto": idProducto,
        "nombre_producto": nombreProducto,
        "descripcion": descripcion,
        "id_estado": idEstado,
      };
}

ProductoFilter productoFilterFromJson(String str) =>
    ProductoFilter.fromJson(json.decode(str));

String productoFilterToJson(ProductoFilter data) => json.encode(data.toJson());

class ProductoFilter {
  int pagina;
  int filas;

  ProductoFilter({
    this.pagina = 1,
    this.filas = 12,
  });

  factory ProductoFilter.fromJson(Map<String, dynamic> json) => ProductoFilter(
        pagina: json["pagina"],
        filas: json["filas"],
      );

  Map<String, dynamic> toJson() => {
        "pagina": pagina,
        "filas": filas,
      };
}
