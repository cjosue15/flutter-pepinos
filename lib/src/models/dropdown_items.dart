// class DropdownItem {
//   int id;
//   String text;
//   List<DropdownItem> items = [];

//   DropdownItem({this.id, this.text});

//   factory DropdownItem.fromJsonMap(
//           {Map<String, dynamic> json, String idValue, String textValue}) =>
//       DropdownItem(id: json[idValue], text: json[textValue]);

//   DropdownItem.fromJsonList(
//       {List<dynamic> jsonList, String idValue, String textValue}) {
//     if (jsonList == null) return;

//     for (final item in jsonList) {
//       this.items.add(new DropdownItem.fromJsonMap(
//           json: item, idValue: idValue, textValue: textValue));
//     }
//   }
//
class DropdownItem {
  int id;
  String text;
  List<DropdownItem> items = [];

  DropdownItem({this.id, this.text});

  factory DropdownItem.fromJsonMap(
          {Map<String, dynamic> json, int idValue, String textValue}) =>
      DropdownItem(id: idValue, text: textValue);

  // DropdownItem.fromJsonList(
  //     {List<dynamic> jsonList, String idValue, String textValue}) {
  //   if (jsonList == null) return;

  //   for (final item in jsonList) {
  //     this.items.add(new DropdownItem.fromJsonMap(
  //         json: item, idValue: idValue, textValue: textValue));
  //   }
  // }

  // Map<String, dynamic> toJson() => {
  //       // "id_cliente": idCliente,
  //       "nombres": nombres,
  //       "apellidos": apellidos,
  //       "lugar": lugar,
  //       "puesto": puesto,
  //       // "createdAt": createdAt,
  //       // "updatedAt": updatedAt,
  //     };
}
