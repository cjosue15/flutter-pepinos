// To parse this JSON data, do
//
//     final campania = campaniaFromJson(jsonString);

import 'dart:convert';

import 'package:pepinos/src/utils/date_format.dart';

Campania campaniaFromJson(String str) => Campania.fromJson(json.decode(str));

String campaniaToJson(Campania data) => json.encode(data.toJson());

class Campania {
  Campania({
    this.idCampania,
    this.nombreCampania,
    this.fechaInicio,
    this.fechaFin,
    this.idEstado,
  });

  int idCampania;
  String nombreCampania;
  String fechaInicio;
  String fechaFin;
  int idEstado;
  List<Campania> items = [];

  Campania.fromJsonList({List<dynamic> jsonList}) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      this.items.add(new Campania.fromJson(item));
    }
  }

  factory Campania.fromJson(Map<String, dynamic> json) => Campania(
        idCampania: json["id_campania"],
        nombreCampania: json["nombre_campania"],
        fechaInicio: dateFormFromDatabase(json["fecha_inicio"]),
        fechaFin: json["fecha_fin"] != null
            ? dateFormFromDatabase(json["fecha_fin"])
            : null,
        idEstado: json["id_estado"],
      );

  Map<String, dynamic> toJson() => {
        "nombre_campania": nombreCampania,
        "fecha_inicio": dateFormatToDatabase(fechaInicio),
        "fecha_fin": fechaFin != null ? dateFormatToDatabase(fechaFin) : null,
      };
}

CampaniaFilter campaniaFilterFromJson(String str) =>
    CampaniaFilter.fromJson(json.decode(str));

String campaniaFilterToJson(CampaniaFilter data) => json.encode(data.toJson());

class CampaniaFilter {
  int pagina;
  int filas;

  CampaniaFilter({
    this.pagina = 1,
    this.filas = 10,
  });

  factory CampaniaFilter.fromJson(Map<String, dynamic> json) => CampaniaFilter(
        pagina: json["pagina"],
        filas: json["filas"],
      );

  Map<String, dynamic> toJson() => {
        "pagina": pagina,
        "filas": filas,
      };
}
