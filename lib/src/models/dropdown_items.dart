class DropdownItem {
  int id;
  String text;
  List<DropdownItem> items = [];

  DropdownItem({this.id, this.text});

  int get hashCode => id.hashCode;
  bool operator ==(Object other) => other is DropdownItem && other.id == id;

  factory DropdownItem.fromJsonMap(
          {Map<String, dynamic> json, int idValue, String textValue}) =>
      DropdownItem(id: idValue, text: textValue);
}
