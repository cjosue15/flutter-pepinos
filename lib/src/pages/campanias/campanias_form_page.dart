import 'package:flutter/material.dart';
import 'package:pepinos/src/models/campanias_model.dart';
import 'package:pepinos/src/providers/campanias/campanias_provider.dart';
import 'package:pepinos/src/utils/date_format.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/date_picker_form.dart';

class CampaniaFormPage extends StatefulWidget {
  @override
  _CampaniaFormPageState createState() => _CampaniaFormPageState();
}

class _CampaniaFormPageState extends State<CampaniaFormPage> {
  final formKey = GlobalKey<FormState>();
  CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  CampaniasProvider _campaniasProvider = new CampaniasProvider();
  Campania _campania = new Campania();
  String _idCampania;
  bool _isSaving = false;
  bool _isLoading = false;
  // fielfds
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) async {
      if (ModalRoute.of(context).settings.arguments != null) {
        if (mounted)
          setState(() {
            _isLoading = true;
          });
        _idCampania = ModalRoute.of(context).settings.arguments;
        try {
          _campania = await _campaniasProvider.getCampania(_idCampania);
          _nameController.text = _campania.nombreCampania;
          _isLoading = false;
          if (mounted) setState(() {});
        } catch (e) {
          _isLoading = false;
          if (mounted) setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idCampaniaIsEmpty = _idCampania == null || _idCampania.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(idCampaniaIsEmpty ? 'Nueva campaña' : 'Editar campaña'),
      ),
      body: !_isLoading
          ? Container(
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.only(top: 20.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    _createNameCampania(),
                    SizedBox(height: 25.0),
                    _createStartDate(),
                    idCampaniaIsEmpty ? Container() : SizedBox(height: 25.0),
                    idCampaniaIsEmpty ? Container() : _createFinishDate(),
                    SizedBox(height: 30.0),
                    _createButton(context)
                  ],
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  TextFormField _createNameCampania() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Campaña',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => _campania.nombreCampania = value,
      onChanged: (value) => _campania.nombreCampania = value,
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese un nombre'),
    );
  }

  Widget _createStartDate() {
    return DatePickerForm(
      labelText: 'Fecha de inicio',
      initialDate: _campania.fechaInicio != null
          ? dateStringToDateTime(date: _campania.fechaInicio)
          : null,
      onSaved: (date) => _campania.fechaInicio = date,
      onDateChanged: (date) => _campania.fechaInicio = date,
    );
  }

  Widget _createFinishDate() {
    return DatePickerForm(
      labelText: 'Fecha de cierre',
      firstDate: _campania.fechaInicio != null
          ? dateStringToDateTime(date: _campania.fechaInicio)
          : null,
      initialDate: _campania.fechaFin != null
          ? dateStringToDateTime(date: _campania.fechaFin)
          : null,
      onSaved: (date) => _campania.fechaFin = date,
      onDateChanged: (date) => _campania.fechaFin = date,
    );
  }

  Widget _createButton(BuildContext context) {
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
      if (_idCampania != null) {
        // editar
        response =
            await _campaniasProvider.updateCampanias(_idCampania, _campania);
      } else {
        response = await _campaniasProvider.createCampania(_campania);
      }
      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Registro exitoso',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'campanias');
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
