import 'package:flutter/material.dart';
import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:pepinos/src/providers/dropdowns_provider.dart';
import 'package:pepinos/src/utils/constants.dart';
import 'package:pepinos/src/widgets/dropdown.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;

class VentasForm extends StatefulWidget {
  @override
  _VentasFormState createState() => _VentasFormState();
}

class _VentasFormState extends State<VentasForm> {
  DropdownProvider _dropdownProvider = new DropdownProvider();
  final formKey = GlobalKey<FormState>();
  List<DropdownItem> _clientes = [];
  // List<DropdownItem> currentClientes = clientes;
  DropdownItem selectedClient;
  DropdownItem selectedInvernadero;
  DropdownItem selectedProducto;
  DropdownItem selectedUnidadMedida;
  DropdownItem selectedEstado;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      final clientes = await _dropdownProvider.getClienteDropdown();
      setState(() {
        _clientes = clientes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva venta'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(ConstantsForm.padding),
          margin: EdgeInsets.only(top: ConstantsForm.margin),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _createDropdownCliente(),
                SizedBox(height: ConstantsForm.height),
                _createDropdownInvernadero(),
                SizedBox(height: ConstantsForm.height),
                _createDropdownProducto(),
                SizedBox(height: ConstantsForm.height),
                _createDropdownUnidadMedida(),
                SizedBox(height: ConstantsForm.height),
                Row(
                  children: <Widget>[
                    _createCantidad(),
                    _createPrecio(),
                  ],
                ),
                SizedBox(height: ConstantsForm.height),
                _createMontoPagado(),
                SizedBox(height: ConstantsForm.height),
                _createDropdownEstado(),
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

  Widget _createDropdownCliente() {
    return AppDropdownInput(
      hintText: 'Cliente',
      options: _clientes,
      value: selectedClient,
      onChanged: (DropdownItem cliente) {
        setState(() {
          selectedClient = cliente;
        });
      },
      validator: (value) => value == null ? 'Ingrese un cliente' : null,
    );
  }

  Widget _createDropdownInvernadero() {
    return AppDropdownInput(
      hintText: "Invernadero",
      options: _clientes,
      value: selectedInvernadero,
      onChanged: (DropdownItem cliente) {
        setState(() {
          selectedInvernadero = cliente;
        });
      },
      validator: (value) => value == null ? 'Ingrese un invernadero' : null,
    );
  }

  Widget _createDropdownProducto() {
    return AppDropdownInput(
      hintText: "Producto",
      options: _clientes,
      value: selectedProducto,
      onChanged: (DropdownItem cliente) {
        setState(() {
          selectedProducto = cliente;
        });
      },
      validator: (value) => value == null ? 'Ingrese un producto' : null,
    );
  }

  Widget _createDropdownUnidadMedida() {
    return AppDropdownInput(
      hintText: "Unidad de medida",
      options: _clientes,
      value: selectedUnidadMedida,
      onChanged: (DropdownItem cliente) {
        setState(() {
          selectedUnidadMedida = cliente;
        });
      },
      validator: (value) =>
          value == null ? 'Ingrese la unidad de medida' : null,
    );
  }

  Widget _createCantidad() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 12.5),
        child: TextFormField(
          // controller: _nameController,
          initialValue: '',
          decoration: InputDecoration(
            labelText: 'Cantidad',
            border: OutlineInputBorder(),
          ),
          // onSaved: (value) => cliente.nombres = value,
          validator: (value) => validators.isTextEmpty(
              value: value, length: 1, message: 'Ingrese la cantidad'),
        ),
      ),
    );
  }

  Widget _createPrecio() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 12.5),
        child: TextFormField(
          // controller: _nameController,
          initialValue: '',
          decoration: InputDecoration(
            labelText: 'Precio',
            border: OutlineInputBorder(),
          ),
          // onSaved: (value) => cliente.nombres = value,
          validator: (value) => validators.isTextEmpty(
              value: value, length: 1, message: 'Ingrese la precio'),
        ),
      ),
    );
  }

  Widget _createMontoPagado() {
    return TextFormField(
      // controller: _nameController,
      initialValue: '',
      decoration: InputDecoration(
        labelText: 'Monto pagado',
        border: OutlineInputBorder(),
      ),
      // onSaved: (value) => cliente.nombres = value,
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese el monto pagado'),
    );
  }

  Widget _createDropdownEstado() {
    return AppDropdownInput(
      hintText: "Estado",
      options: _clientes,
      value: selectedEstado,
      onChanged: (DropdownItem cliente) {
        setState(() {
          selectedEstado = cliente;
        });
      },
      validator: (value) => value == null ? 'Ingrese un estado' : null,
    );
  }

  Widget _crearButton(BuildContext context) {
    return ElevatedButton.icon(
      // onPressed: _isSaving ? null : () => _submit(context),
      onPressed: () => _submit(context),
      icon: Icon(Icons.save),
      // label: _isSaving ? Text('Guardando') : Text('Guardar'),
      label: Text('Guardar'),
    );
  }

  void _submit(BuildContext context) async {
    String response;
    try {
      if (!formKey.currentState.validate()) return;
      // setState(() {
      //   _isSaving = true;
      // });
      formKey.currentState.save();
      // if (_idCliente != null) {
      //   // editar
      //   response = await _clienteProvider.updateClient(cliente);
      // } else {
      //   response = await _clienteProvider.createProduct(cliente);
      // }
      // _customAlertDialog.confirmAlert(
      //     context: context,
      //     title: 'Registro exitoso',
      //     description: response,
      //     text: 'Aceptar',
      //     backFunction: () => Navigator.pop(context));
      // setState(() {
      //   _isSaving = false;
      // });
    } catch (e) {
      // _customAlertDialog.errorAlert(
      //   context: context,
      //   title: 'Ops!',
      //   description: 'Ocurrio un error.',
      //   text: 'Aceptar',
      //   // backFunction: () => Navigator.pop(context)
      // );
      // setState(() {
      //   _isSaving = false;
      // });
      // setState(() {
      //   _isSaving = false;
      // });
    }
  }
}
