// To parse this JSON data, do
//
//     final paginacion = paginacionFromJson(jsonString);

import 'dart:convert';

Paginacion paginacionFromJson(String str) =>
    Paginacion.fromJson(json.decode(str));

String paginacionToJson(Paginacion data) => json.encode(data.toJson());

class Paginacion {
  Paginacion(
      {this.itemDesde,
      this.itemHasta,
      this.itemPagina,
      this.itemTotal,
      this.pagActual,
      this.pagAnterior,
      this.pagSiguiente,
      this.pagTotal,
      this.hasError});

  int itemDesde;
  int itemHasta;
  int itemPagina;
  int itemTotal;
  int pagActual;
  int pagAnterior;
  int pagSiguiente;
  int pagTotal;
  bool hasError;

  factory Paginacion.fromJson(Map<String, dynamic> json) => Paginacion(
        itemDesde: json["item_desde"],
        itemHasta: json["item_hasta"],
        itemPagina: json["item_pagina"],
        itemTotal: json["item_total"],
        pagActual: json["pag_actual"],
        pagAnterior: json["pag_anterior"],
        pagSiguiente: json["pag_siguiente"],
        pagTotal: json["pag_total"],
        hasError: json["has_error"],
      );

  Map<String, dynamic> toJson() => {
        "item_desde": itemDesde,
        "item_hasta": itemHasta,
        "item_pagina": itemPagina,
        "item_total": itemTotal,
        "pag_actual": pagActual,
        "pag_anterior": pagAnterior,
        "pag_siguiente": pagSiguiente,
        "pag_total": pagTotal,
        "has_error": hasError,
      };
}
