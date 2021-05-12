import 'package:flutter/material.dart';
import 'package:pepinos/src/models/producto_model.dart';
import 'package:pepinos/src/providers/productos/productos_provider.dart';
import 'package:pepinos/src/utils/constants.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;
import 'package:pepinos/src/widgets/alert_dialog.dart';

class ProductsFormPage extends StatefulWidget {
  @override
  _ProductsFormPageState createState() => _ProductsFormPageState();
}

class _ProductsFormPageState extends State<ProductsFormPage> {
  String _idProducto;
  final _formKey = GlobalKey<FormState>();
  ProductosProvider _productosProvider = new ProductosProvider();
  final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  Producto _producto = new Producto();
  bool _isSaving = false;

  // fields
  final _nameController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      if (ModalRoute.of(context).settings.arguments != null) {
        setState(() {
          _idProducto = ModalRoute.of(context).settings.arguments;
        });
        _producto = await _productosProvider.getProduct(_idProducto);
        _nameController.text = _producto.nombreProducto;
        _descripcionController.text = _producto.descripcion;
      }
    });
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _descripcionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_idProducto == null || _idProducto.isEmpty ? 'Nuevo' : 'Editar'} producto',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(ConstantsForm.padding),
          margin: EdgeInsets.only(top: ConstantsForm.margin),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _createProductName(),
                SizedBox(height: ConstantsForm.height),
                _createProductDescription(),
                SizedBox(height: ConstantsForm.height),
                _createCheckBoxState(),
                SizedBox(height: ConstantsForm.height),
                _crearButton(context),
                SizedBox(height: ConstantsForm.height),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createProductName() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Producto',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => _producto.nombreProducto = value,
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese el nombre'),
    );
  }

  Widget _createProductDescription() {
    return TextFormField(
      controller: _descripcionController,
      decoration: InputDecoration(
        labelText: 'Descripción',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => _producto.descripcion = value,
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese la descripción'),
    );
  }

  Widget _createCheckBoxState() {
    return CheckboxListTile(
        title: Text('Activo'),
        value: _producto.idEstado == 1 ? true : false,
        onChanged: (value) {
          setState(() {
            _producto.idEstado = value ? 1 : 0;
          });
        });
  }

  Widget _crearButton(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: _isSaving ? null : () => _submit(context),
        icon: Icon(Icons.save),
        label: _isSaving ? Text('Guardando') : Text('Guardar'));
  }

  void _submit(BuildContext context) async {
    String response;
    try {
      if (!_formKey.currentState.validate()) return;
      setState(() {
        _isSaving = true;
      });
      _formKey.currentState.save();
      if (_idProducto != null) {
        // editar
        response = await _productosProvider.updateProduct(_producto);
      } else {
        response = await _productosProvider.createProduct(_producto);
      }
      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Registro exitoso',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'productos');
          });
      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      _customAlertDialog.errorAlert(
        context: context,
        title: 'Ops!',
        description: 'Ocurrio un error.',
        text: 'Aceptar',
      );
      setState(() {
        _isSaving = false;
      });
    }
  }
}
