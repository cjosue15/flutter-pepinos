import 'dart:convert';

Cliente clienteFromJson(String str) => Cliente.fromJson(json.decode(str));

String clienteToJson(Cliente data) => json.encode(data.toJson());

class Cliente {
  Cliente(
      {this.idCliente,
      this.nombres,
      this.apellidos,
      this.lugar,
      this.puesto,
      this.idEstado = 1});

  int idCliente;
  String nombres;
  String apellidos;
  String lugar;
  String puesto;
  int idEstado;
  List<Cliente> items = [];

  Cliente.fromJsonList({List<dynamic> jsonList}) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      this.items.add(new Cliente.fromJson(item));
    }
  }

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
      idCliente: json["id_cliente"],
      nombres: json["nombres"],
      apellidos: json["apellidos"],
      lugar: json["lugar"],
      puesto: json["puesto"],
      idEstado: json.containsKey("id_estado") ? json["id_estado"] : null);

  Map<String, dynamic> toJson() => {
        "nombres": nombres,
        "apellidos": apellidos,
        "lugar": lugar,
        "puesto": puesto,
        // "id_estado": idEstado
      };
}

ClienteFilter clienteFilterFromJson(String str) =>
    ClienteFilter.fromJson(json.decode(str));

String clienteFilterToJson(ClienteFilter data) => json.encode(data.toJson());

class ClienteFilter {
  int pagina;
  int filas;

  ClienteFilter({
    this.pagina = 1,
    this.filas = 12,
  });

  factory ClienteFilter.fromJson(Map<String, dynamic> json) => ClienteFilter(
        pagina: json["pagina"],
        filas: json["filas"],
      );

  Map<String, dynamic> toJson() => {
        "pagina": pagina,
        "filas": filas,
      };
}

ClienteReporteTotal clienteReporteTotalFromJson(String str) =>
    ClienteReporteTotal.fromJson(json.decode(str));

String clienteReporteTotalToJson(ClienteReporteTotal data) =>
    json.encode(data.toJson());

class ClienteReporteTotal {
  ClienteReporteTotal({
    this.cantidadTotal,
    this.montoTotal,
  });

  int cantidadTotal;
  double montoTotal;

  factory ClienteReporteTotal.fromJson(Map<String, dynamic> json) =>
      ClienteReporteTotal(
        cantidadTotal: json["cantidad_total"],
        montoTotal: (json["monto_total"] ?? 0) / 1,
      );

  Map<String, dynamic> toJson() => {
        "cantidad_total": cantidadTotal,
        "monto_total": montoTotal,
      };
}
