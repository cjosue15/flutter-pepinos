import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:pepinos/src/enums/estado_enum.dart';
import 'package:pepinos/src/models/venta_model.dart';
// import 'package:pepinos/src/models/venta_detalle_model.dart';
import 'package:pepinos/src/providers/ventas/ventas_provider.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;
import 'package:pepinos/src/utils/number_format.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/date_picker_form.dart';

class VentasDetailPage extends StatefulWidget {
  @override
  _VentasDetailPageState createState() => _VentasDetailPageState();
}

class _VentasDetailPageState extends State<VentasDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  Venta _venta;
  VentaDetalle _ventaDetalle = new VentaDetalle();
  String _idVenta = '';
  VentasProvider _ventasProvider = new VentasProvider();
  List<VentaPago> _pagos = [];
  bool isLoading = false;
  // double _totalPagado = 0;
  DateTime _dateSelected = DateTime.now();
  VentaPago _ventaPago = new VentaPago();

  final _montoController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: 'S/ ',
    initialValue: 0,
  );

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if (ModalRoute.of(context).settings.arguments != null) {
        _idVenta = ModalRoute.of(context).settings.arguments;
        getVenta(_idVenta);
      }
    });

    _montoController.addListener(_checkMontoPagado);
  }

  @override
  void dispose() {
    super.dispose();
    _ventasProvider.token.cancel();
    _montoController.dispose();
  }

  getVenta(String idVenta) async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      _venta = await _ventasProvider.getOneVenta(idVenta: _idVenta);
      _ventaDetalle = _venta.ventaDetalles[0];
      _pagos = _venta.ventaPagos;
      getTotalPagos(_pagos);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _moveToScreen(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_venta?.numeroComprobante ?? ''),
        ),
        body: isLoading || _venta == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
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
      ),
    );
  }

  Future<bool> _moveToScreen(BuildContext context) async {
    Navigator.pushReplacementNamed(context, "/");
    return Future.value(true);
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
            icon != null &&
                    _venta.idEstado == Estado.getValue(EstadoEnum.PENDIENTE)
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
              Text('S/ ${(_venta.montoTotal).toStringDouble(2)}',
                  style: montosTextStyle),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              Text('Monto Pagado', style: textStyle),
              SizedBox(height: 10.0),
              Text('S/ ${(_venta.montoPagado).toStringDouble(2)}',
                  style: montosTextStyle),
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
              _createItem(title: 'Cliente', subtitle: _venta.cliente),
              _createItem(
                  title: 'Invernadero',
                  subtitle: _ventaDetalle.nombreInvernadero)
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              _createItem(title: 'Fecha', subtitle: _venta.fechaVenta),
              _createItem(title: 'Campaña', subtitle: _venta.nombreCampania)
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              _createItem(
                  title: 'Producto', subtitle: _ventaDetalle.nombreProducto),
              _createItem(
                  title: 'Unidad de Medida',
                  subtitle: _ventaDetalle.unidadMedida)
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              _createItem(
                  title: 'Cantidad',
                  subtitle: _ventaDetalle.cantidad.toString()),
              _createItem(
                  title: 'Precio Unitario',
                  subtitle: _ventaDetalle.precioUnitario.toString())
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
        itemCount: _pagos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_pagos[index].detallePago ?? ''),
            subtitle: Text(_pagos[index].fechaPago),
            trailing: Text(
              'S/ ${_pagos[index].montoPagado}',
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
                      'Monto faltante S/ ${(_venta.montoTotal - _venta.montoPagado).toStringDouble(2)}',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: DatePickerForm(
                    initialDate: _dateSelected,
                    labelText: 'Fecha',
                    onSaved: (String value) => _ventaPago.fechaPago = value,
                    onDateChanged: (value) {
                      setState(() {
                        _ventaPago.fechaPago = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    initialValue: _ventaPago.detallePago,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _ventaPago.detallePago = value,
                    onChanged: (String value) {
                      setState(() {
                        _ventaPago.detallePago = value;
                      });
                    },
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
                    onSaved: (value) =>
                        _ventaPago.montoPagado = _montoController.numberValue,
                    onChanged: (String value) {
                      setState(() {
                        _ventaPago.montoPagado = _montoController.numberValue;
                      });
                    },
                    validator: (value) => validators.isPriceGreaterThanZero(
                        message: 'Ingrese un monto mayor a S/ 0.00.',
                        value: _montoController.numberValue.toString()),
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
    ).whenComplete(() {
      _ventaPago.detallePago = '';
      _montoController.updateValue(0);
    });
  }

  void _addNewPago() async {
    String response;
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    try {
      response = await _ventasProvider.updatePago(
          pago: _ventaPago, numeroComprobante: _venta.numeroComprobante);

      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Se registro el pago',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            Navigator.pop(context);
            getVenta(_idVenta);
          });
    } catch (e) {
      _customAlertDialog.errorAlert(
        context: context,
        title: 'Ops!',
        description: 'Ocurrio un error.',
        text: 'Aceptar',
      );
    }
  }

  void getTotalPagos(List<VentaPago> pagos) {
    final total = pagos.length > 0
        ? pagos.fold(
            0,
            (previousValue, element) =>
                previousValue + element.montoPagado.toDouble())
        : 0.0;
    _venta.montoPagado = total;
  }

  void _checkMontoPagado() {
    final monto = _montoController.numberValue;
    final montoFaltante = _venta.montoTotal - _venta.montoPagado;
    if (monto > montoFaltante.toPrecision(2)) {
      _montoController.updateValue(0);
    }
  }
}
