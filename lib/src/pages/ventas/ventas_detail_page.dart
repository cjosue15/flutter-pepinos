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
  List<VentaDetalle> _items = [];
  String _idVenta = '';
  VentasProvider _ventasProvider = new VentasProvider();
  List<VentaPago> _pagos = [];
  bool isLoading = false;
  bool _isFetching = false;
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
      _items = _venta.ventaDetalles;
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
      print('Must show an error page');
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
            : Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _createTotales(),
                        _createSubtitle(title: 'DETALLES'),
                        _createDetails(),
                        _createSubtitle(title: 'ITEMS'),
                        _createListItems(),
                        _createSubtitle(title: 'PAGOS', icon: Icons.add_circle),
                        _createListPagos()
                      ],
                    ),
                  ),
                  _createLoading()
                ],
              ),
      ),
    );
  }

  Widget _createLoading() {
    return _isFetching
        ? Container(
            color: Colors.white70,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          )
        : Container();
  }

  Future<bool> _moveToScreen(BuildContext context) async {
    Navigator.pushReplacementNamed(context, 'ventas');
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

    TextStyle textStyleRed = new TextStyle(fontSize: 18.0, color: Colors.red);

    TextStyle montosTextStyle =
        new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900);

    TextStyle montosTextStyleRed = new TextStyle(
        fontSize: 20.0, fontWeight: FontWeight.w900, color: Colors.red);

    final totales = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
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
          padding: EdgeInsets.all(20.0),
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

    final porPagar = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: <Widget>[
              Text('Monto Faltante', style: textStyleRed),
              SizedBox(height: 10.0),
              Text(
                  'S/ ${(_venta.montoTotal - _venta.montoPagado).toStringDouble(2)}',
                  style: montosTextStyleRed),
            ],
          ),
        )
      ],
    );

    return Column(
      children: <Widget>[
        totales,
        _venta.idEstado == Estado.getValue(EstadoEnum.PENDIENTE)
            ? porPagar
            : Container()
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
              _createItem(title: 'Cliente', subtitle: _venta.cliente ?? ''),
              _createItem(title: 'Fecha', subtitle: _venta.fechaVenta ?? ''),
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              _createItem(
                  title: 'Campaña', subtitle: _venta.nombreCampania ?? ''),
              _createItem(title: 'Estado', subtitle: _venta.estado ?? ''),
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            children: <Widget>[
              _createItem(
                  title: 'Observacion', subtitle: _venta.observaciones ?? '')
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
            style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 5.0),
          Text(
            subtitle,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _createListItems() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      itemCount: _items.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _items[index].nombreProducto,
                  // style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _items[index].nombreInvernadero,
                  style: TextStyle(fontSize: 14.0),
                )
              ],
            ),
            Column(
              children: <Widget>[
                Text(
                    'S/ ${(_items[index].cantidad * _items[index].precioUnitario).toStringDouble(2)}'),
              ],
            )
          ],
        ),
        // subtitle: Text(_items[index].nombreInvernadero),
        onTap: () => _showItem(_items[index]),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: Colors.green,
        ),
      ),
    );
  }

  void _showItem(VentaDetalle item) {
    final TextStyle textStyle = TextStyle(fontWeight: FontWeight.bold);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Producto: ',
                    style: textStyle,
                  ),
                  Text(item.nombreProducto)
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Invernadero: ',
                    style: textStyle,
                  ),
                  Text(item.nombreInvernadero)
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Unidad M: ',
                    style: textStyle,
                  ),
                  Text(item.unidadMedida)
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Precio: ',
                    style: textStyle,
                  ),
                  Text('S/ ${item.precioUnitario.toStringDouble(2)}')
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Cantidad: ',
                    style: textStyle,
                  ),
                  Text(item.cantidad.toString())
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Total: ',
                    style: textStyle,
                  ),
                  Text(
                      'S/ ${(item.cantidad * item.precioUnitario).toStringDouble(2)}')
                ],
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
            leading: _venta.idEstado == Estado.getValue(EstadoEnum.ANULADO)
                ? null
                : IconButton(
                    onPressed: () async {
                      final res = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text('¿Estas seguro de eliminar el pago?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              child: Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red)),
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text('Eliminar'),
                            )
                          ],
                        ),
                      );

                      if (!res) return;
                      _isFetching = true;
                      setState(() {});

                      try {
                        final msg = await _ventasProvider
                            .cancelPago(_pagos[index].idVentaPago.toString());
                        _pagos.removeAt(index);
                        _customAlertDialog.confirmAlert(
                          context: context,
                          title: 'Eliminación exitosa',
                          description: msg,
                          text: 'Aceptar',
                          backFunction: () {
                            // Navigator.pop(context);
                            getVenta(_idVenta);
                          },
                        );

                        _isFetching = false;
                        setState(() {});
                      } catch (e) {
                        _isFetching = false;
                        setState(() {});
                        _customAlertDialog.errorAlert(
                          context: context,
                          title: 'Ops!',
                          description: 'Ocurrio un error.',
                          text: 'Aceptar',
                        );
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                  ),
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

  void _modalUpdateTotal() async {
    final resp = await showModalBottomSheet(
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
                    onPressed: () {
                      if (!_formKey.currentState.validate()) return;
                      _formKey.currentState.save();
                      Navigator.pop(context, true);
                    },
                    child: Text('Aceptar'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    if (resp != null && resp) {
      _addNewPago();
      _ventaPago.detallePago = '';
      _montoController.updateValue(0);
    }
  }

  void _addNewPago() async {
    String response;
    _isFetching = true;
    setState(() {});
    try {
      response = await _ventasProvider.updatePago(
          pago: _ventaPago, numeroComprobante: _venta.numeroComprobante);

      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Se registro el pago',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            // Navigator.pop(context);
            getVenta(_idVenta);
          });
      _isFetching = false;
      setState(() {});
    } catch (e) {
      print(e);
      _customAlertDialog.errorAlert(
        context: context,
        title: 'Ops!',
        description: 'Ocurrio un error.',
        text: 'Aceptar',
      );
      _isFetching = false;
      setState(() {});
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
