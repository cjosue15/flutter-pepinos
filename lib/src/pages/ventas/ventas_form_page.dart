import 'package:flutter/material.dart';
import 'package:pepinos/src/enums/estado_enum.dart';
import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/providers/dropdowns_provider.dart';
import 'package:pepinos/src/providers/ventas/ventas_provider.dart';
import 'package:pepinos/src/utils/constants.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/date_picker_form.dart';
import 'package:pepinos/src/widgets/dropdown.dart';
import 'package:pepinos/src/utils/utils_validatos.dart' as validators;
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:pepinos/src/utils/number_format.dart';

class VentasForm extends StatefulWidget {
  @override
  _VentasFormState createState() => _VentasFormState();
}

class _VentasFormState extends State<VentasForm> {
  VentasProvider _ventasProvider = new VentasProvider();
  DropdownProvider _dropdownProvider = new DropdownProvider();

  Venta _venta = new Venta();
  VentaDetalle _ventaDetalle = new VentaDetalle();
  List<VentaDetalle> _items = [];
  final CustomAlertDialog _customAlertDialog = new CustomAlertDialog();
  final _formKey = GlobalKey<FormState>();
  List<DropdownItem> _clientes = [];
  List<DropdownItem> _invernaderos = [];
  List<DropdownItem> _unidadDeMedidas = [];
  List<DropdownItem> _productos = [];
  List<DropdownItem> _campanias = [];
  DropdownItem selectedClient;
  DropdownItem selectedInvernadero;
  DropdownItem selectedProducto;
  DropdownItem selectedUnidadMedida;
  DropdownItem selectedCampania;
  bool _isSaving = false;
  bool _isLoading = false;
  double prevMontoTotal = 0;

  int currentStep = 0;
  bool complete = false;
  StateSetter _setState;
  // keys
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  List<bool> stepStates = [null, null, null];

  // controllers
  final _precioController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: 'S/ ',
    initialValue: 0,
  );
  final _cantidadController = TextEditingController();
  final _montoPagadoController = MoneyMaskedTextController(
      decimalSeparator: '.',
      thousandSeparator: ',',
      initialValue: 0,
      leftSymbol: 'S/ ');

  @override
  void initState() {
    super.initState();
    if (mounted)
      setState(() {
        _isLoading = true;
      });
    Future.delayed(Duration.zero).then((_) async {
      final clientes = await _dropdownProvider.getClientsCombo();
      final invernaderos = await _dropdownProvider.getInvernaderosCombo();
      final unidadDeMedidas = await _dropdownProvider.getUnidadMedidasCombo();
      _campanias = await _dropdownProvider.getCampaniasCombo();

      if (mounted) {
        setState(() {
          _clientes = clientes;
          _invernaderos = invernaderos;
          _unidadDeMedidas = unidadDeMedidas;
          _isLoading = false;
        });
      }
    }).catchError((error) {
      print('Must show an error page');
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    });

    _montoPagadoController.addListener(_checkMontoPagado);
  }

  @override
  void dispose() {
    super.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _montoPagadoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Step> steps = [
      Step(
        title: const Text('Venta'),
        isActive: currentStep == 0 ? true : false,
        state: stepStates[0] == null
            ? StepState.editing
            : stepStates[0]
                ? StepState.complete
                : StepState.error,
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: <Widget>[
              _createDropdownCliente(),
              SizedBox(height: ConstantsForm.height),
              _createDateVenta(),
              SizedBox(height: ConstantsForm.height),
              _createDropdownCampania(),
            ],
          ),
        ),
      ),
      Step(
        isActive: currentStep == 1 ? true : false,
        state: stepStates[1] == null
            ? StepState.editing
            : stepStates[1]
                ? StepState.complete
                : StepState.error,
        title: const Text('Items'),
        content: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            _items.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) => Column(
                          children: <Widget>[
                            ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('${_items[index].nombreProducto}'),
                                  Text(
                                    'S/ ${(_items[index].cantidad * _items[index].precioUnitario).toStringDouble(2)}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              subtitle: Text(_items[index].nombreInvernadero),
                              leading: IconButton(
                                onPressed: () {
                                  print(_items[index]);
                                  _items.removeWhere((venta) =>
                                      _items[index].idItem == venta.idItem);
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                              ),
                              // trailing: Icon(
                              //   Icons.keyboard_arrow_right,
                              //   color: Colors.green,
                              // ),
                              onTap: () {
                                _getItem(index);
                                _additem(_items[index].idItem);
                              },
                            ),
                            Divider()
                          ],
                        ))
                : Text(
                    'Debe agregar minimo 1 item.',
                    style: TextStyle(color: Colors.red, fontSize: 16.0),
                  ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
      Step(
        isActive: currentStep == 2 ? true : false,
        state: stepStates[2] == null
            ? StepState.editing
            : stepStates[2]
                ? StepState.complete
                : StepState.error,
        title: const Text('Resumen'),
        content: Form(
          key: _formKeys[2],
          child: Column(
            children: <Widget>[
              _createTotal(),
              SizedBox(height: ConstantsForm.height),
              _createMontoPagado(),
              SizedBox(height: ConstantsForm.height),
              _createObservacion(),
              SizedBox(height: ConstantsForm.height),
              _createEstado()
            ],
          ),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Nueva venta',
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stepper(
              type: StepperType.horizontal,
              steps: steps,
              currentStep: currentStep,
              onStepTapped: (step) => goTo(step),
              controlsBuilder: (context, {onStepCancel, onStepContinue}) =>
                  Column(
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      currentStep != 0
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.grey),
                              onPressed: cancel,
                              child: Text('Regresar'),
                            )
                          : Container(),
                      ElevatedButton(
                        onPressed: _isSaving ? null : next,
                        child: Text(currentStep == 2 ? 'Guardar' : 'Siguiente'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: currentStep == 1
          ? FloatingActionButton(
              child: Icon(Icons.add), onPressed: () => _additem(null))
          : Container(),
    );
  }

  void _additem(int idItem) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateAlert) {
                _setState = setStateAlert;
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _createDropdownInvernadero(),
                        SizedBox(height: ConstantsForm.height),
                        _createDropdownProducto(),
                        SizedBox(height: ConstantsForm.height),
                        _createDropdownUnidadMedida(),
                        SizedBox(height: ConstantsForm.height),
                        _createCantidad(),
                        SizedBox(height: ConstantsForm.height),
                        _createPrecio(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('Cancelar'),
              onPressed: () {
                _resetVentaDetalle();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(idItem != null ? 'Editar' : 'Agregar'),
              onPressed: () {
                if (!_formKey.currentState.validate()) return;
                _formKey.currentState.save();
                if (idItem == null) {
                  // nuevo item
                  _ventaDetalle.idItem = _items.length + 1;
                  _items.add(_ventaDetalle);
                } else {
                  // editar
                  int ventaIndex =
                      _items.indexWhere((venta) => venta.idItem == idItem);
                  _items[ventaIndex] = _ventaDetalle;
                }
                _resetVentaDetalle();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _getItem(int index) async {
    _ventaDetalle = _items[index];
    _productos = await _dropdownProvider
        .getProductosByInvernaderoCombo(_ventaDetalle.idInvernadero);
    selectedInvernadero = DropdownItem(
        id: _ventaDetalle.idInvernadero, text: _ventaDetalle.nombreInvernadero);
    selectedProducto = DropdownItem(
        id: _ventaDetalle.idProducto, text: _ventaDetalle.nombreProducto);
    selectedUnidadMedida = DropdownItem(
        id: _ventaDetalle.idUnidadMedida, text: _ventaDetalle.unidadMedida);
    _precioController.updateValue(_ventaDetalle.precioUnitario);
    _cantidadController.text = _ventaDetalle.cantidad.toString();
    setState(() {});
    _setState(() {});
  }

  void next() {
    //validate step 1 and 3
    if (_formKeys[currentStep].currentState != null &&
        !_formKeys[currentStep].currentState.validate()) {
      stepStates[currentStep] = false;
      setState(() {});
      return;
    } else {
      stepStates[currentStep] = true;
      setState(() {});
    }

    if (_formKeys[currentStep].currentState != null)
      _formKeys[currentStep].currentState.save();

    // validate step 2
    if (currentStep + 1 == 2) {
      if (_items.length == 0) {
        stepStates[currentStep] = false;
        setState(() {});
        return;
      } else {
        stepStates[currentStep] = true;
        setState(() {});
      }
    }

    if (currentStep + 1 == 2) {
      getTotalPagos();
    }

    currentStep + 1 != 3
        ? goTo(currentStep + 1)
        : setState(() => complete = true);

    if (complete) {
      _submit(context);
    }
  }

  void cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  void goTo(int step) {
    setState(() => currentStep = step);
  }

  // cabecera

  Widget _createDropdownCliente() {
    return AppDropdownInput(
      hintText: 'Cliente',
      options: _clientes,
      value: selectedClient,
      onChanged: (DropdownItem cliente) {
        selectedClient = cliente;
        _venta.idCliente = cliente.id;
      },
      validator: (value) => value == null ? 'Ingrese un cliente' : null,
    );
  }

  Widget _createDateVenta() {
    return DatePickerForm(
      initialDate: DateTime.now(),
      onSaved: (date) => _venta.fechaVenta = date,
      onDateChanged: (date) => _venta.fechaVenta = date,
    );
  }

  Widget _createDropdownCampania() {
    return AppDropdownInput(
      hintText: "Campaña",
      options: _campanias,
      value: selectedCampania,
      onChanged: (DropdownItem campania) async {
        selectedCampania = campania;
        _venta.idCampania = campania.id;
      },
      validator: (value) => value == null ? 'Ingrese una campaña' : null,
    );
  }

  // items de lista

  Widget _createDropdownInvernadero() {
    return AppDropdownInput(
      hintText: "Invernadero",
      options: _invernaderos,
      value: selectedInvernadero,
      onChanged: (DropdownItem invernadero) async {
        final productos = await _dropdownProvider
            .getProductosByInvernaderoCombo(invernadero.id);
        selectedProducto = null;
        _productos = productos;
        selectedInvernadero = invernadero;
        _ventaDetalle.idInvernadero = invernadero.id;
        _ventaDetalle.nombreInvernadero = invernadero.text;
        setState(() {});
        _setState(() {});
      },
      validator: (value) => value == null ? 'Ingrese un invernadero' : null,
    );
  }

  Widget _createDropdownProducto() {
    return AppDropdownInput(
      hintText: "Producto",
      options: _productos,
      value: selectedProducto,
      onChanged: (DropdownItem producto) {
        selectedProducto = producto;
        _ventaDetalle.idProducto = producto.id;
        _ventaDetalle.nombreProducto = producto.text;
        setState(() {});
        _setState(() {});
      },
      validator: (value) => value == null ? 'Ingrese un producto' : null,
    );
  }

  Widget _createDropdownUnidadMedida() {
    return AppDropdownInput(
      hintText: "Unidad de medida",
      options: _unidadDeMedidas,
      value: selectedUnidadMedida,
      onChanged: (DropdownItem unidad) {
        selectedUnidadMedida = unidad;
        _ventaDetalle.idUnidadMedida = unidad.id;
        _ventaDetalle.unidadMedida = unidad.text;
        setState(() {});
        _setState(() {});
      },
      validator: (value) =>
          value == null ? 'Ingrese la unidad de medida' : null,
    );
  }

  Widget _createCantidad() {
    return TextFormField(
      controller: _cantidadController,
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      decoration: InputDecoration(
        labelText: 'Cantidad',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) => _ventaDetalle.cantidad = int.parse(value),
      onChanged: (String value) {
        _ventaDetalle.cantidad = int.parse(value.isEmpty ? '0' : value);
        setState(() {});
        _setState(() {});
      },
      validator: (value) => validators.isTextEmpty(
          value: value, length: 1, message: 'Ingrese la cantidad'),
    );
  }

  Widget _createPrecio() {
    final double _price = _precioController.numberValue;
    return TextFormField(
      controller: _precioController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio',
        border: OutlineInputBorder(),
      ),
      onSaved: (value) =>
          _ventaDetalle.precioUnitario = _precioController.numberValue,
      onChanged: (String value) {
        _ventaDetalle.precioUnitario = _precioController.numberValue;
        setState(() {});
        _setState(() {});
      },
      validator: (value) => validators.isPriceGreaterThanZero(
          value: _price.toString(), message: 'Ingrese el precio'),
    );
  }

  // resumen

  Widget _createMontoPagado() {
    final montoTotal = _venta.montoTotal ?? 0;
    // final double _monto = _montoPagadoController.numberValue;
    return TextFormField(
      controller: _montoPagadoController,
      enabled: montoTotal == null || montoTotal == 0 ? false : true,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: 'Monto pagado',
          border: OutlineInputBorder(),
          helperText: montoTotal == 0
              ? null
              : 'El monto debe ser menor al monto total.',
          helperStyle: TextStyle(fontWeight: FontWeight.bold)),
      onSaved: (value) =>
          _venta.montoPagado = _montoPagadoController.numberValue,
      onChanged: (value) {
        setState(() {
          _venta.montoPagado = _montoPagadoController.numberValue;
        });
      },
      // validator: (value) => validators.isPriceGreaterThanZero(
      //     value: _monto.toString(), message: 'Ingrese el monto'),
    );
  }

  Widget _createObservacion() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      minLines: 6,
      decoration: InputDecoration(
        // labelText: 'Observación',
        hintText: 'Observación',
        border: OutlineInputBorder(),
        helperStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      onSaved: (value) => _venta.observaciones = value,
      onChanged: (value) {
        setState(() {
          _venta.observaciones = value;
        });
      },
      // validator: (value) => validators.isPriceGreaterThanZero(
      //     value: _monto.toString(), message: 'Ingrese el monto'),
    );
  }

  Widget _createTotal() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Monto total : S/ ${(_venta.montoTotal ?? 0).toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _createEstado() {
    double montoTotal = _venta.montoTotal ?? 0;
    String estado = montoTotal == (_venta.montoPagado ?? 0) && montoTotal != 0
        ? 'CANCELADO'
        : 'PENDIENTE';

    _venta.idEstado = Estado.getValue(estado == 'CANCELADO'
        ? EstadoEnum.CANCELADO
        : estado == 'PENDIENTE'
            ? EstadoEnum.PENDIENTE
            : EstadoEnum.ANULADO);

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Estado de la venta : $estado',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //

  void _submit(BuildContext context) async {
    String response;

    if (_isSaving) return;

    try {
      setState(() {
        _isSaving = true;
      });
      _venta.ventaDetalles = _items;
      response = await _ventasProvider.createVenta(_venta);

      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Registro exitoso',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, 'ventas');
          });
      setState(() {
        _isSaving = false;
      });
      // print(ventaToJson(_venta));
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

  void getTotalPagos() {
    final total = _items.length > 0
        ? _items.fold(
            0,
            (previousValue, element) =>
                previousValue + (element.cantidad * element.precioUnitario))
        : 0.0;
    _venta.montoTotal = total;

    if (prevMontoTotal != total) {
      prevMontoTotal = total;
      _montoPagadoController.updateValue(0);
      _venta.montoPagado = 0;
    }
  }

  void _checkMontoPagado() {
    final montoTotal = _venta.montoTotal ?? 0;
    final montoPagado = _montoPagadoController.numberValue;
    if (montoPagado > montoTotal) {
      _montoPagadoController.updateValue(0);
    }
  }

  _resetVentaDetalle() {
    _ventaDetalle = new VentaDetalle();
    selectedInvernadero = null;
    selectedProducto = null;
    selectedUnidadMedida = null;
    _precioController.updateValue(0);
    _cantidadController.text = '';
    _productos = [];
    setState(() {});
    _setState(() {});
  }
}
