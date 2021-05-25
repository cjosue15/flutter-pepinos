import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pepinos/src/models/cliente_model.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/providers/clientes_providers.dart';
import 'package:pepinos/src/utils/number_format.dart';
import 'package:pepinos/src/widgets/screens/error_screen.dart';

class ClienteDetailsPage extends StatefulWidget {
  ClienteDetailsPage({Key key}) : super(key: key);

  @override
  _ClienteDetailsPageState createState() => _ClienteDetailsPageState();
}

class _ClienteDetailsPageState extends State<ClienteDetailsPage> {
  List<String> _options = [
    'Reporte anual',
    'Reporte de productos',
    'Exportar excel',
  ];
  List<Venta> _ventas = [];
  ClienteReporteTotal _totales;
  String _idCliente;
  Cliente _cliente;
  DateTime _selectedDateYear = DateTime.now();
  DateTime _selectedDateMonth = DateTime.now();
  StateSetter _setState;
  ClienteProvider _clienteProvider = new ClienteProvider();
  TextEditingController monthController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) async {
      if (ModalRoute.of(context).settings.arguments != null) {
        _getData(month: _selectedDateMonth.month, year: _selectedDateYear.year);
      }
    });
    monthController.text = _monthToString(_selectedDateMonth);
    yearController.text = DateFormat.y('es').format(_selectedDateYear);
  }

  void _getData({@required int month, @required int year}) async {
    if (mounted)
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    try {
      _idCliente = ModalRoute.of(context).settings.arguments;
      final response = await _clienteProvider.clienteReporteVentas(
          idCliente: _idCliente,
          month: month.toString(),
          year: year.toString());
      _ventas = response['ventas'];
      _totales = response['totales'];
      _cliente = await _clienteProvider.getClient(_idCliente);
      _isLoading = false;
      _hasError = false;
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _hasError
        ? ErrorScreen(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              '/',
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Detalle del cliente'),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'clientes/form',
                        arguments: _idCliente);
                  },
                ),
                PopupMenuButton<String>(
                  // child: IconButton(
                  //   icon: Icon(Icons.more_vert),
                  //   // onPressed: () {},
                  // ),
                  // offset: Offset(0, 0),
                  onSelected: choiceOption,
                  // onCanceled: () {
                  //   print('cancelled!');
                  // },
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) {
                    return _options.map((String option) {
                      return PopupMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: _isLoading || _cliente == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: <Widget>[
                            createDetailCliente(),
                            SizedBox(
                              height: 15.0,
                            ),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _createMonthPicker(),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    _createYearPicker()
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            _createTotales(),
                            SizedBox(
                              height: 15.0,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ventas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _ventas.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _ventas[index].numeroComprobante,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _ventas[index].fechaVenta,
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        'S/ ${_ventas[index].montoTotal.toStringDouble(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(
                            height: 0,
                            color: Colors.black26,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }

  Widget _createMonthPicker() {
    return SizedBox(
      width: 150.0,
      child: TextField(
        controller: monthController,
        textAlign: TextAlign.center,
        readOnly: true,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onTap: () {
          _selectMonth();
        },
      ),
    );
  }

  Widget _createYearPicker() {
    return SizedBox(
      width: 100.0,
      child: TextField(
        controller: yearController,
        textAlign: TextAlign.center,
        readOnly: true,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onTap: () {
          _selectYear();
        },
      ),
    );
  }

  void _selectYear() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Selecciona el año"),
          contentPadding: EdgeInsets.zero,
          content: Container(
            // Need to use container to add size constraint.
            padding: EdgeInsets.zero,
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100, 1),
              lastDate: DateTime(DateTime.now().year + 100, 1),
              initialDate: DateTime.now(),
              // save the selected date to _selectedDate DateTime variable.
              // It's used to set the previous selected date when
              // re-showing the dialog.
              selectedDate: _selectedDateYear,
              onChanged: (DateTime dateTime) {
                // close the dialog when year is selected.
                _selectedDateYear = dateTime;
                _getData(
                    month: _selectedDateMonth.month,
                    year: _selectedDateYear.year);
                setState(() {});
                yearController.text = _selectedDateYear.year.toString();
                Navigator.pop(context, yearController);

                // Do something with the dateTime selected.
                // Remember that you need to use dateTime.year to get the year
              },
            ),
          ),
        );
      },
    );
  }

  void _selectMonth() {
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter stateDialog) {
          _setState = stateDialog;
          return AlertDialog(
            contentPadding: EdgeInsets.all(18.0),
            actionsPadding: EdgeInsets.symmetric(vertical: 0.0),
            title: Text('Selecciona el mes'),
            content: Container(
              width: 300,
              height: 220,
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                children: List<int>.generate(12, (i) => i + 1)
                    .map((month) => DateTime(_selectedDateYear.year, month))
                    .map(
                      (date) => Padding(
                        padding: EdgeInsets.all(3.0),
                        child: TextButton(
                          onPressed: () {
                            _selectedDateMonth = date;
                            monthController.text =
                                _monthToString(_selectedDateMonth);
                            Navigator.pop(context, _selectedDateMonth);
                            _getData(
                                month: _selectedDateMonth.month,
                                year: _selectedDateYear.year);
                            setState(() {});
                            _setState(() {});
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                date.month == _selectedDateMonth.month
                                    ? Colors.green
                                    : null),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                          ),
                          child: Text(
                            DateFormat.MMM('es').format(date),
                            style: TextStyle(
                              color: date.month == _selectedDateMonth.month
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget createDetailCliente() {
    TextStyle bold = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    );

    TextStyle text = TextStyle(
      fontSize: 16.0,
    );
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Nombre: ',
                  style: bold,
                ),
                Text(
                  _cliente.nombres,
                  style: text,
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: <Widget>[
                Text('Apellidos: ', style: bold),
                Text(
                  _cliente.apellidos,
                  style: text,
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: <Widget>[
                Text('Lugar: ', style: bold),
                Text(
                  _cliente.lugar,
                  style: text,
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: <Widget>[
                Text('Puesto: ', style: bold),
                Text(
                  _cliente.puesto,
                  style: text,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _createTotales() {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  'Cantidad de ventas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(_totales.cantidadTotal.toString(),
                    style: TextStyle(fontSize: 16.0)),
              ],
            ),
            SizedBox(
              width: 30.0,
            ),
            Column(
              children: <Widget>[
                Text(
                  'Total de soles',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text('S/ ${_totales.montoTotal.toStringDouble(2)}',
                    style: TextStyle(fontSize: 16.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthToString(DateTime date) =>
      DateFormat.MMMM('es').format(date).capitalize();

  // void _changeDate({int numberOfMonths, bool isIncrement}) {
  //   final date = DateTime(
  //       _selectedDateYear.year,
  //       isIncrement
  //           ? _selectedDateMonth.month + numberOfMonths
  //           : _selectedDateMonth.month - numberOfMonths);
  //   _selectedDateMonth = date;
  //   monthController.text = _monthToString(_selectedDateMonth);
  //   setState(() {});
  // }

  void choiceOption(String option) {
    print(option);
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
