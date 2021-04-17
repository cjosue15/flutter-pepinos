import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:dio/dio.dart';

class DropdownProvider {
  Dio dio;
  final String url = 'http://192.168.1.24:8080';
  CancelToken token;
  DropdownProvider() {
    dio = new Dio();
    token = CancelToken();
  }
// List<DropdownItem>
  Future<dynamic> getClienteDropdown() async {
    try {
      // var list = [{'id':3, 'name':'third'},{'id':4, 'name':'fourth'}];
      // final clientes = [
      //   {'id_cliente': 1, 'nombres': 'Carlos Morales'},
      //   {'id_cliente': 1, 'nombres': 'Miguel Morales'}
      // ];
      final response = await dio.get('$url/api/clientes', cancelToken: token);
      final dynamic decodedData = response.data;
      // final result = clientes.map((cliente) =>
      //     DropdownItem(id: cliente['id_cliente'], text: cliente['nombres']));
      final clientes = DropdownItem.fromJsonList(
          jsonList: decodedData['clientes'],
          idValue: 'id_cliente',
          textValue: 'nombres');

      // .toList();
      // final response = await dio.get(
      //   '$url/api/clientes',
      // );
      // final decodedData = response.data;
      print(clientes);
      return clientes.items;
    } catch (e) {
      print(e);
      return e;
    }
  }
}
