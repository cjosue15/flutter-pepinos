import 'package:flutter/material.dart';
import 'package:pepinos/src/utils/constants.dart';

class InvernaderoPageForm extends StatefulWidget {
  @override
  _InvernaderoPageFormState createState() => _InvernaderoPageFormState();
}

class _InvernaderoPageFormState extends State<InvernaderoPageForm> {
  String _idInvernadero;
  final _formKey = GlobalKey<FormState>();
  Map<String, bool> numbers = {
    'One': false,
    'Two': false,
    'Three': false,
    'Four': false,
    'Five': false,
    'Six': false,
    'Seven': false,
  };

  //   ProductosProvider _productosProvider = new ProductosProvider();
  // final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  // Producto _producto = new Producto();
  // bool _isSaving = false;
  //
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      if (ModalRoute.of(context).settings.arguments != null) {
        setState(() {
          _idInvernadero = ModalRoute.of(context).settings.arguments;
        });
        // _producto = await _productosProvider.getProduct(_idProducto);
        // _nameController.text = _producto.nombreProducto;
        // _descripcionController.text = _producto.descripcion;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_idInvernadero == null || _idInvernadero.isEmpty ? 'Nuevo' : 'Editar'} invernadero',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(ConstantsForm.padding),
          margin: EdgeInsets.only(top: ConstantsForm.margin),
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _createInvernaderoName(),
                SizedBox(height: ConstantsForm.height),
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Agrege los productos',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                _createCheckBoxProducts(),
                // SizedBox(height: ConstantsForm.height),
                // _createCheckBoxState(),
                // SizedBox(height: ConstantsForm.height),
                // _crearButton(context),
                // SizedBox(height: ConstantsForm.height),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createInvernaderoName() {
    return TextFormField(
      // controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nombre',
        border: OutlineInputBorder(),
      ),
      // onSaved: (value) => _producto.nombreProducto = value,
      // validator: (value) => validators.isTextEmpty(
      //     value: value, length: 1, message: 'Ingrese el nombre'),
    );
  }

  Widget _createCheckBoxProducts() {
    return Container(
      child: Column(
        children: numbers.keys.map(
          (String key) {
            return CheckboxListTile(
              title: Text(key),
              value: numbers[key],
              onChanged: (bool value) {
                setState(() {
                  numbers[key] = value;
                });
              },
            );
          },
        ).toList(),
      ),
    );
  }
}
