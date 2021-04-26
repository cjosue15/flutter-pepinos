import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;

class VentasDetailPage extends StatefulWidget {
  @override
  _VentasDetailPageState createState() => _VentasDetailPageState();
}

class _VentasDetailPageState extends State<VentasDetailPage> {
  final _formKey = GlobalKey<FormState>();
  List<Pago> pagos = [
    Pago(date: '15/05/20', description: 'Pago 1', pay: 25.0),
    Pago(date: '15/05/20', description: 'Pago 1', pay: 25.0),
    Pago(date: '15/05/20', description: 'Pago 1', pay: 25.0),
  ];

  final _descriptionController = TextEditingController();

  final _montoController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: 'S/ ',
    initialValue: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boleta 0054545'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _createTotales(),
            _createSubtitle(title: 'DETALLES'),
            _createDetails(),
            _createSubtitle(title: 'PAGOS', icon: Icons.add_circle),
            _createListPagos()
          ],
        ),
      ),
    );
  }

  Widget _createSubtitle({@required String title, IconData icon}) {
    return Column(
      children: <Widget>[
        Divider(thickness: 1.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                )),
            icon != null
                ? Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
                    child: IconButton(
                        iconSize: 30.0,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(
                          icon,
                          color: Colors.green,
                        ),
                        onPressed: () => _modalUpdateTotal()))
                : Container()
          ],
        ),
        Divider(thickness: 1.0),
      ],
    );
  }

  Widget _createTotales() {
    TextStyle textStyle = new TextStyle(
      fontSize: 18.0,
    );
    TextStyle montosTextStyle =
        new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Text('Monto Total', style: textStyle),
              SizedBox(height: 10.0),
              Text('S/ 75.00', style: montosTextStyle),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Text('Monto Pagado', style: textStyle),
              SizedBox(height: 10.0),
              Text('S/ 65.00', style: montosTextStyle),
            ],
          ),
        )
      ],
    );
  }

  Widget _createDetails() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _createItem(title: 'Cliente', subtitle: 'Miguel'),
              _createItem(title: 'Invernadero', subtitle: 'Cieneguilla')
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              _createItem(title: 'Producto', subtitle: 'Pepino'),
              _createItem(title: 'Unidad de Medida', subtitle: 'Docena')
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              _createItem(title: 'Cantidad', subtitle: '5'),
              _createItem(title: 'Precio Unitario', subtitle: '12.50')
            ],
          )
        ],
      ),
    );
  }

  Widget _createItem({@required String title, @required String subtitle}) {
    return Expanded(
      flex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 5.0),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _createListPagos() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: pagos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(pagos[index].description),
            subtitle: Text(pagos[index].date),
            trailing: Text(
              'S/ ${pagos[index].pay.toString()}',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          );
        },
      ),
    );
  }

  void _modalUpdateTotal() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Wrap(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Monto faltante S/ 15.00',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validators.isTextEmpty(
                        length: 1,
                        message: 'Ingrese una descripción.',
                        value: value),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    controller: _montoController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validators.isNumberEmpty(
                        message: 'Ingrese un monto mayor a S/ 0.00.',
                        value: value),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () => _addNewPago(), child: Text('Agregar')),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNewPago() {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    setState(() {
      pagos.add(new Pago(
          date: '15/05/21',
          description: _descriptionController.text,
          pay: _montoController.numberValue));
    });
    Navigator.pop(context);
    _montoController.updateValue(0);
    _descriptionController.text = '';
  }
}

class Pago {
  String description;
  String date;
  double pay;

  Pago({this.description, this.date, this.pay});
}
