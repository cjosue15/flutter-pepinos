import 'package:flutter/material.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/providers/clientes_providers.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;
import 'package:pepinos/src/widgets/alert_dialog.dart';

class ClienteFormPage extends StatefulWidget {
  @override
  _ClienteFormPageState createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final formKey = GlobalKey<FormState>();
  Cliente cliente = new Cliente();
  final ClienteProvider _clienteProvider = new ClienteProvider();
  final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  bool _isSaving = false;
  String _idCliente;
  // fielfds
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _puestoController = TextEditingController();
  final _lugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      if (ModalRoute.of(context).settings.arguments != null) {
        setState(() {
          _idCliente = ModalRoute.of(context).settings.arguments;
        });
        cliente = await _clienteProvider.getClient(_idCliente);
        _nameController.text = cliente.nombres;
        _lastNameController.text = cliente.apellidos;
        _puestoController.text = cliente.puesto;
        _lugarController.text = cliente.lugar;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _puestoController.dispose();
    _lugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                '${_idCliente == null || _idCliente.isEmpty ? 'Nuevo' : 'Editar'} cliente')),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(15.0),
                margin: EdgeInsets.only(top: 20.0),
                child: Form(
                    key: formKey,
                    child: Column(children: <Widget>[
                      _createName(),
                      SizedBox(height: 25.0),
                      _createLastName(),
                      SizedBox(height: 25.0),
                      _createLugar(),
                      SizedBox(height: 25.0),
                      _createPuesto(),
                      SizedBox(height: 30.0),
                      _crearButton(context)
                    ])))));
  }

  Widget _createName() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Nombres',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => cliente.nombres = value,
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese un nombre'),
    );
  }

  Widget _createLastName() {
    return TextFormField(
        controller: _lastNameController,
        decoration: InputDecoration(
          labelText: 'Apellidos',
          border: OutlineInputBorder(),
        ),
        onSaved: (value) => cliente.apellidos = value,
        validator: (value) => validators.isTextEmpty(
            value: value, length: 1, message: 'Ingrese un apellido'));
  }

  Widget _createLugar() {
    return TextFormField(
      controller: _lugarController,
      decoration: InputDecoration(
        labelText: 'Lugar',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => cliente.lugar = value,
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese un lugar'),
    );
  }

  Widget _createPuesto() {
    return TextFormField(
        controller: _puestoController,
        decoration: InputDecoration(
          labelText: 'Puesto',
          border: OutlineInputBorder(),
        ),
        onSaved: (value) => cliente.puesto = value,
        validator: (value) => validators.isTextEmpty(
            value: value, length: 1, message: 'Ingrese un puesto'));
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
      if (!formKey.currentState.validate()) return;
      setState(() {
        _isSaving = true;
      });
      formKey.currentState.save();
      if (_idCliente != null) {
        // editar
        response = await _clienteProvider.updateClient(cliente);
      } else {
        response = await _clienteProvider.createClient(cliente);
      }
      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Registro exitoso',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'clientes');
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
