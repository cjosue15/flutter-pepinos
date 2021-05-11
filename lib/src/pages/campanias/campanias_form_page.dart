import 'package:flutter/material.dart';
import 'package:pepinos/src/widgets/date_picker_form.dart';

class CampaniaFormPage extends StatefulWidget {
  @override
  _CampaniaFormPageState createState() => _CampaniaFormPageState();
}

class _CampaniaFormPageState extends State<CampaniaFormPage> {
  final formKey = GlobalKey<FormState>();
  String _date;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva campaña'),
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        margin: EdgeInsets.only(top: 20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              _createNameCampania(),
              SizedBox(height: 25.0),
              _createStartDate(),
              SizedBox(height: 25.0),
              _createFinishDate(),
              SizedBox(height: 30.0),
              _createButton()
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _createNameCampania() {
    return TextFormField(
      // controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Campaña',
        border: OutlineInputBorder(),
      ),
      // onSaved: (value) => cliente.nombres = value,
      // validator: (value) => validators.isTextEmpty(
      // value: value, length: 1, message: 'Ingrese un nombre'),
    );
  }

  Widget _createStartDate() {
    return DatePickerForm(
      initialDate: DateTime.now(),
      onSaved: (date) {
        print(date);
        _date = date;
      },
      onDateChanged: (date) {
        setState(() {
          _date = date;
        });
      },
      // onDateChanged: (date) => _venta.fechaVenta = date,
    );
  }

  Widget _createFinishDate() {
    return DatePickerForm(
      onSaved: (date) {
        print(date);
        _date = date;
      },
      onDateChanged: (date) {
        setState(() {
          _date = date;
        });
      },
      // onDateChanged: (date) => _venta.fechaVenta = date,
    );
  }

  Widget _createButton() {
    return ElevatedButton(
        onPressed: () {
          formKey.currentState.save();
          // print(_date);
        },
        child: Text('Guardar'));
  }
}
