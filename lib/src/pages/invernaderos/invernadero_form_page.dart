import 'package:flutter/material.dart';
import 'package:pepinos/src/models/invernadero.dart';
import 'package:pepinos/src/providers/dropdowns_provider.dart';
import 'package:pepinos/src/providers/invernaderos/invernaderos_provider.dart';
import 'package:pepinos/src/utils/constants.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;

class InvernaderoPageForm extends StatefulWidget {
  @override
  _InvernaderoPageFormState createState() => _InvernaderoPageFormState();
}

class _InvernaderoPageFormState extends State<InvernaderoPageForm> {
  String _idInvernadero;
  final _formKey = GlobalKey<FormState>();
  DropdownProvider _dropdownProvider = new DropdownProvider();
  InvernaderoProvider _invernaderoProvider = new InvernaderoProvider();
  CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  List<Product> _productos = [];
  Invernadero _invernadero;
  bool _isSaving = false;
  bool _isLoading = false;
  bool _hasError = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      if (mounted)
        setState(() {
          _isLoading = true;
        });
      try {
        final productosJson = await _dropdownProvider.getProductosCombo();
        if (ModalRoute.of(context).settings.arguments != null) {
          _idInvernadero = ModalRoute.of(context).settings.arguments;
          this._invernadero = await this
              ._invernaderoProvider
              .getInvernadero(this._idInvernadero);
          _nameController.text = this._invernadero.nombreInvernadero;
        }

        this._productos = productosJson
            .map<Product>((item) => Product(
                checked: this._invernadero == null ||
                        this._invernadero.productosSeleccionados == null
                    ? false
                    : this
                            ._invernadero
                            .productosSeleccionados
                            .contains(item['id_producto'])
                        ? true
                        : false,
                nombre: item['nombre_producto'],
                id: item['id_producto']))
            .toList();
        if (mounted)
          setState(() {
            _isLoading = false;
            _hasError = false;
          });
      } catch (e) {
        if (mounted)
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
      }
    });
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _dropdownProvider.token.cancel();
    _invernaderoProvider?.disposeStream();
    _invernaderoProvider.token.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '${_idInvernadero == null || _idInvernadero.isEmpty ? 'Nuevo' : 'Editar'} invernadero',
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _hasError
                ? _customAlertDialog.showErrorInBuilders(context)
                : _createSingleChildScrollView());
  }

  Widget _createSingleChildScrollView() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(ConstantsForm.padding),
        margin: EdgeInsets.only(top: ConstantsForm.margin),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _createInvernaderoName(),
              SizedBox(height: ConstantsForm.height),
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Agrege los productos',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _createCheckBoxProducts(),
              SizedBox(height: ConstantsForm.height),
              _createButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _createInvernaderoName() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nombre',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => this._invernadero.nombreInvernadero = value,
      onChanged: (value) {
        setState(() {
          this._invernadero.nombreInvernadero = value;
        });
      },
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese el invernadero'),
    );
  }

  Widget _createCheckBoxProducts() {
    return Container(
      child: Column(
        children: this._productos.map(
          (Product product) {
            return CheckboxListTile(
              title: Text(product.nombre),
              value: product.checked,
              onChanged: (bool value) {
                setState(() {
                  product.checked = value;
                });
              },
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _createButton() {
    return ElevatedButton.icon(
        onPressed: _isSaving ? null : () => _handleSubmit(),
        icon: Icon(Icons.save),
        label: _isSaving ? Text('Guardando') : Text('Guardar'));
  }

  Future<void> _handleSubmit() async {
    String response;

    setState(() {
      _isSaving = true;
    });
    try {
      this._invernadero.productosSeleccionados = this
          ._productos
          .where((producto) => producto.checked)
          .map((producto) => producto.id)
          .toList();
      if (this._idInvernadero == null) {
        response =
            await _invernaderoProvider.createInvernadero(this._invernadero);
      } else {
        this._invernadero.productosNoSeleccionados = this
            ._productos
            .where((producto) => !producto.checked)
            .map((producto) => producto.id)
            .toList();
        response = await _invernaderoProvider.updateInvernadero(
            this._idInvernadero, this._invernadero);
      }
      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Registro exitoso',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'invernaderos');
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

class Product {
  String nombre;
  bool checked;
  int id;
  Product({this.nombre, this.checked, this.id});
}
