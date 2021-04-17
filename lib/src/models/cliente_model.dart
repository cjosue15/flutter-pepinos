import 'dart:convert';

class Clientes {
  List<Cliente> clientes = [];
  Clientes();

  Clientes.fromJsonList(List<dynamic> jsonList) {
    if (jsonList == null) return;

    for (final item in jsonList) {
      this.clientes.add(new Cliente.fromJson(item));
    }
  }
}

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
        "id_estado": idEstado
      };
}
