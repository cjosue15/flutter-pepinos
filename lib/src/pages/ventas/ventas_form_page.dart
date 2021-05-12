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

class VentasForm extends StatefulWidget {
  @override
  _VentasFormState createState() => _VentasFormState();
}

class _VentasFormState extends State<VentasForm> {
  VentasProvider _ventasProvider = new VentasProvider();
  DropdownProvider _dropdownProvider = new DropdownProvider();

  Venta _venta = new Venta();
  VentaDetalle _ventaDetalle = new VentaDetalle();
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
  String _idVenta;
  String prevPrecio = '';
  String prevCantidad = '';

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
        });
      }
    }).catchError((error) {
      print('errooorrr');
      print(error);
      print('fin errooorrr');
    });

    _precioController.addListener(_resetMontoPagado);
    _cantidadController.addListener(_resetMontoPagado);
    _montoPagadoController.addListener(_checkMontoPagado);
  }

  @override
  void dispose() {
    super.dispose();
    _ventasProvider.token.cancel();
    _precioController.dispose();
    _cantidadController.dispose();
    _montoPagadoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_idVenta == null || _idVenta.isEmpty ? 'Nueva' : 'Editar'} venta',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(ConstantsForm.padding),
          margin: EdgeInsets.only(top: ConstantsForm.margin),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _createSubtitle(title: 'DETALLE'),
                SizedBox(height: ConstantsForm.height),
                _createDropdownCliente(),
                SizedBox(height: ConstantsForm.height),
                _createDateVenta(),
                SizedBox(height: ConstantsForm.height),
                _createDropdownInvernadero(),
                SizedBox(height: ConstantsForm.height),
                _createDropdownProducto(),
                SizedBox(height: ConstantsForm.height),
                _createDropdownCampania(),
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
                _createSubtitle(title: 'RESUMEN'),
                SizedBox(height: ConstantsForm.height),
                _createTotal(),
                SizedBox(height: ConstantsForm.height),
                _createMontoPagado(),
                SizedBox(height: ConstantsForm.height),
                _createEstado(),
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

  Widget _createDropdownInvernadero() {
    return AppDropdownInput(
      hintText: "Invernadero",
      options: _invernaderos,
      value: selectedInvernadero,
      onChanged: (DropdownItem idInvernadero) async {
        final productos = await _dropdownProvider
            .getProductosByInvernaderoCombo(idInvernadero.id);
        setState(() {
          _productos = productos;
        });
        selectedInvernadero = idInvernadero;
        _ventaDetalle.idInvernadero = idInvernadero.id;
      },
      validator: (value) => value == null ? 'Ingrese un invernadero' : null,
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

  Widget _createDropdownProducto() {
    return AppDropdownInput(
      hintText: "Producto",
      options: _productos,
      value: selectedProducto,
      onChanged: (DropdownItem producto) {
        selectedProducto = producto;
        _ventaDetalle.idProducto = producto.id;
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
          controller: _cantidadController,
          keyboardType: TextInputType.numberWithOptions(decimal: false),
          decoration: InputDecoration(
            labelText: 'Cantidad',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _ventaDetalle.cantidad = int.parse(value),
          onChanged: (String value) {
            setState(() {
              _ventaDetalle.cantidad = int.parse(value.isEmpty ? '0' : value);
            });
          },
          validator: (value) => validators.isTextEmpty(
              value: value, length: 1, message: 'Ingrese la cantidad'),
        ),
      ),
    );
  }

  Widget _createPrecio() {
    final double _price = _precioController.numberValue;
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 12.5),
        child: TextFormField(
          controller: _precioController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Precio',
            border: OutlineInputBorder(),
          ),
          onSaved: (value) =>
              _ventaDetalle.precioUnitario = _precioController.numberValue,
          onChanged: (String value) {
            setState(() {
              _ventaDetalle.precioUnitario = _precioController.numberValue;
            });
          },
          validator: (value) => validators.isPriceGreaterThanZero(
              value: _price.toString(), message: 'Ingrese el precio'),
        ),
      ),
    );
  }

  Widget _createMontoPagado() {
    int cantidad = _ventaDetalle.cantidad ?? 0;
    double precio = _ventaDetalle.precioUnitario ?? 0.0;
    final double _monto = _montoPagadoController.numberValue;
    return TextFormField(
      controller: _montoPagadoController,
      enabled: cantidad == 0 || precio == 0 ? false : true,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: 'Monto pagado',
          border: OutlineInputBorder(),
          helperText: cantidad == 0 || precio == 0
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
      validator: (value) => validators.isPriceGreaterThanZero(
          value: _monto.toString(), message: 'Ingrese el monto'),
    );
  }

  Widget _createSubtitle({String title}) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(
          color: Colors.black54,
        )
      ],
    );
  }

  Widget _createTotal() {
    int cantidad = _ventaDetalle.cantidad ?? 0;
    double precio = _ventaDetalle.precioUnitario ?? 0.0;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Monto total : S/ ${(cantidad * precio).toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _createEstado() {
    double montoTotal =
        (_ventaDetalle.cantidad ?? 0) * (_ventaDetalle.precioUnitario ?? 0.0);
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
        'Estado de la venta : S/ $estado',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _crearButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : () => _submit(context),
      icon: Icon(Icons.save),
      label: _isSaving ? Text('Guardando') : Text('Guardar'),
    );
  }

  void _submit(BuildContext context) async {
    String response;

    try {
      if (!_formKey.currentState.validate()) return;
      setState(() {
        _isSaving = true;
      });
      _formKey.currentState.save();
      _ventaDetalle.idItem = 1;
      _venta.montoTotal = _ventaDetalle.precioUnitario * _ventaDetalle.cantidad;
      _venta.ventaDetalles = [_ventaDetalle];
      response = await _ventasProvider.createVenta(_venta);

      _customAlertDialog.confirmAlert(
          context: context,
          title: 'Registro exitoso',
          description: response,
          text: 'Aceptar',
          backFunction: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/');
          });
      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      print(e);
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

  void _resetMontoPagado() {
    if (prevPrecio != _precioController.text ||
        prevCantidad != _cantidadController.text) {
      prevPrecio = _precioController.text;
      prevCantidad = _cantidadController.text;
      _montoPagadoController.updateValue(0);
    }
  }

  void _checkMontoPagado() {
    final montoTotal =
        (_ventaDetalle.cantidad ?? 0) * (_ventaDetalle.precioUnitario ?? 0);
    final montoPagado = _montoPagadoController.numberValue;
    if (montoPagado > montoTotal) {
      _montoPagadoController.updateValue(0);
    }
  }
}
