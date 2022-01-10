import 'package:flutter/material.dart';
import 'package:pepinos/src/enums/estado_campania.dart';
import 'package:pepinos/src/models/campanias_model.dart';
import 'package:pepinos/src/providers/campanias/campanias_provider.dart';
import 'package:pepinos/src/utils/date_format.dart';
import 'package:pepinos/src/utils/navigate.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/date_picker_form.dart';
import 'package:pepinos/src/widgets/screens/error_screen.dart';

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
  bool _hasError = false;
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
            _hasError = false;
          });
        _idCampania = ModalRoute.of(context).settings.arguments;
        try {
          _campania = await _campaniasProvider.getCampania(_idCampania);
          _nameController.text = _campania.nombreCampania;
          _isLoading = false;
          _hasError = false;
          if (mounted) setState(() {});
        } catch (e) {
          print('Must show an error page');
          _isLoading = false;
          _hasError = true;
          if (mounted) setState(() {});
        }
      }
    });
  }

  // @override
  // void dispose() {
  //   _nameController?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final idCampaniaIsEmpty = _idCampania == null || _idCampania.isEmpty;
    return _hasError
        ? ErrorScreen(
            onPressed: () =>
                navigateWithNamedAndIdArgument(context: context, route: '/'))
        : Scaffold(
            appBar: AppBar(
              title:
                  Text(idCampaniaIsEmpty ? 'Nueva campaña' : 'Editar campaña'),
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
                          idCampaniaIsEmpty
                              ? Container()
                              : SizedBox(height: 25.0),
                          idCampaniaIsEmpty ? Container() : _createFinishDate(),
                          SizedBox(height: 30.0),
                          _campania.idEstado ==
                                  EstadoCampania.getValue(
                                      EstadoCampaniaEnum.TERMINADO)
                              ? Container()
                              : _createButton(context)
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
      enabled: _campania.idEstado ==
              EstadoCampania.getValue(EstadoCampaniaEnum.TERMINADO)
          ? false
          : true,
      onSaved: (value) => _campania.nombreCampania = value,
      onChanged: (value) => _campania.nombreCampania = value,
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese un nombre'),
    );
  }

  Widget _createStartDate() {
    return DatePickerForm(
      enabled: _campania.idEstado ==
              EstadoCampania.getValue(EstadoCampaniaEnum.TERMINADO)
          ? false
          : true,
      labelText: 'Fecha de inicio',
      initialDate: _campania.fechaInicio != null
          ? dateStringToDateTime(date: _campania.fechaInicio)
          : null,
      onSaved: (date) {
        setState(() {
          _campania.fechaInicio = date;
        });
      },
      onDateChanged: (date) {
        setState(() {
          _campania.fechaInicio = date;
          _campania.fechaFin = null;
        });
      },
    );
  }

  Widget _createFinishDate() {
    return DatePickerForm(
      enabled: _campania.idEstado ==
              EstadoCampania.getValue(EstadoCampaniaEnum.EN_CURSO)
          ? true
          : false,
      labelText: 'Fecha de cierre',
      firstDate: _campania.fechaInicio == null || _campania.fechaInicio.isEmpty
          ? null
          : dateStringToDateTime(date: _campania.fechaInicio),
      initialDate: _campania.fechaFin == null || _campania.fechaFin.isEmpty
          ? null
          : dateStringToDateTime(date: _campania.fechaFin),
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
