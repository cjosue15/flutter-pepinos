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
  Cliente({
    this.idCliente,
    this.nombres,
    this.apellidos,
    this.lugar,
    this.puesto,
    // this.createdAt,
    // this.updatedAt,
  });

  int idCliente;
  String nombres;
  String apellidos;
  String lugar;
  String puesto;
  // String createdAt;
  // String updatedAt;

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        idCliente: json["id_cliente"],
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        lugar: json["lugar"],
        puesto: json["puesto"],
        // createdAt: json["createdAt"],
        // updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        // "id_cliente": idCliente,
        "nombres": nombres,
        "apellidos": apellidos,
        "lugar": lugar,
        "puesto": puesto,
        // "createdAt": createdAt,
        // "updatedAt": updatedAt,
      };
}
