import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pepinos/src/enums/estado_enum.dart';
import 'package:pepinos/src/models/dropdown_items.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/providers/ventas/ventas_provider.dart';
import 'package:pepinos/src/utils/date_format.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';
import 'package:pepinos/src/widgets/date_range_picker.dart';
import 'package:pepinos/src/widgets/dismissible_background.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';
import 'package:pepinos/src/utils/number_format.dart';
import 'package:pepinos/src/widgets/dropdown.dart';
import 'package:pepinos/src/widgets/infinite_list_view.dart';
import 'package:pepinos/src/widgets/modal_filter.dart';
import 'package:pepinos/src/widgets/price_range.dart';

class VentasPage extends StatefulWidget {
  @override
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final _ventasProvider = new VentasProvider();
  VentaFilter _ventaFilter = new VentaFilter();
  bool _isFetching = false;
  bool _isInitialLoading = false;
  bool _hasInitialError = false;
  bool _hasErrorAfterFetching = false;
  bool _isSearching = false;
  Paginacion _paginacion = new Paginacion();
  DropdownItem _clienteSelected;
  DropdownItem _invernaderoSelected;
  DropdownItem _campaniaSelected;
  DropdownItem _estadoSelected;
  bool _isDeleting = false;
  List<Venta> _ventas = [];
  StateSetter _stateModal;
  CustomAlertDialog _customAlertDialog = new CustomAlertDialog();

  @override
  void initState() {
    super.initState();
    _getVenta();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getVenta() {
    if (mounted)
      setState(() {
        _isInitialLoading = true;
        _hasInitialError = false;
      });
    _ventasProvider.getVentas(ventaFilter: _ventaFilter).then((response) {
      if (mounted)
        setState(() {
          _paginacion = response['paginacion'];
          _ventas = response['ventas'];
          _isInitialLoading = false;
          _hasInitialError = false;
        });
    }).catchError((error) {
      if (mounted)
        setState(() {
          _isInitialLoading = false;
          _hasInitialError = true;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createSearchBar(),
      drawer: DrawerMenu(),
      body: InfiniteListView<Venta>(
        context: context,
        paginacion: _paginacion,
        data: _ventas,
        length: _ventas.length,
        isInitialLoading: _isInitialLoading,
        isFetching: _isFetching,
        hasInitialError: _hasInitialError,
        hasErrorAfterFetching: _hasErrorAfterFetching,
        itemBuilder: (context, item, index) {
          return _createItem(item);
        },
        onScroll: (int pagina) {
          setState(() {
            _isFetching = true;
            _hasErrorAfterFetching = false;
          });
          _ventaFilter.pagina = pagina;
          _ventasProvider.getVentas(ventaFilter: _ventaFilter).then((response) {
            final ventas = response['ventas'];
            _paginacion = response['paginacion'];
            _ventas.addAll(ventas);
            _isFetching = false;
            _hasErrorAfterFetching = false;

            setState(() {});
          }).catchError((error) {
            setState(() {
              _isFetching = false;
              _hasErrorAfterFetching = true;
            });
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() => _goVenta(context, null)),
        child: Icon(Icons.add),
      ),
    );
  }

  void _goVenta(BuildContext context, String numeroComprobante) {
    Navigator.pushNamed(
        context, 'ventas/${numeroComprobante == null ? 'form' : 'detail'}',
        arguments: numeroComprobante);
  }

  AppBar _createSearchBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  hintText: 'Buscar número de comprobante',
                  hintStyle: TextStyle(color: Colors.white)),
            )
          : Text('Ventas'),
      actions: <Widget>[
        _isSearching
            ? IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  setState(() {
                    this._isSearching = false;
                  });
                })
            : IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    this._isSearching = true;
                  });
                }),
        IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              ModalFilter.modalBottomSheet(
                context: context,
                filters: Form(
                  child: Column(
                    children: <Widget>[
                      FutureBuilder(
                        future: _ventasProvider.getFiltersVenta(),
                        builder: (BuildContext context,
                            AsyncSnapshot<VentaFilterListado> snapshot) {
                          final List<DropdownItem> campanias =
                              snapshot.hasData ? snapshot.data?.campanias : [];
                          final List<DropdownItem> invernaderos =
                              snapshot.hasData
                                  ? snapshot.data?.invernaderos
                                  : [];
                          final List<DropdownItem> clientes =
                              snapshot.hasData ? snapshot.data?.clientes : [];
                          final List<DropdownItem> estados =
                              snapshot.hasData ? snapshot.data?.estados : [];

                          return snapshot.hasData
                              ? Column(
                                  children: <Widget>[
                                    ModalFilter.modalItemWithMarginBottom(
                                      child: AppDropdownInput<DropdownItem>(
                                        hintText: 'Cliente',
                                        options: clientes,
                                        value: _clienteSelected,
                                        onChanged: (DropdownItem cliente) {
                                          _clienteSelected = cliente;
                                          _ventaFilter.idCliente = cliente.id;
                                        },
                                      ),
                                    ),
                                    ModalFilter.modalItemWithMarginBottom(
                                      child: AppDropdownInput<DropdownItem>(
                                        hintText: 'Invernadero',
                                        options: invernaderos,
                                        value: _invernaderoSelected,
                                        onChanged: (invernadero) {
                                          // setState(() {
                                          _invernaderoSelected = invernadero;
                                          _ventaFilter.idInvernadero =
                                              invernadero.id;
                                          // });
                                        },
                                      ),
                                    ),
                                    ModalFilter.modalItemWithMarginBottom(
                                      child: AppDropdownInput<DropdownItem>(
                                        hintText: 'Estado',
                                        options: estados,
                                        value: _estadoSelected,
                                        onChanged: (estado) {
                                          _estadoSelected = estado;
                                          _ventaFilter.idEstado = estado.id;
                                        },
                                      ),
                                    ),
                                    ModalFilter.modalItemWithMarginBottom(
                                      child: AppDropdownInput<DropdownItem>(
                                        hintText: 'Campaña',
                                        options: campanias,
                                        value: _campaniaSelected,
                                        onChanged: (campania) {
                                          _campaniaSelected = campania;
                                          _ventaFilter.idCampania = campania.id;
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : snapshot.hasError
                                  ? Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 50.0),
                                      child: Text(
                                        'Ops hubo un error cargando los combos',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    )
                                  : Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 50.0),
                                      child: CircularProgressIndicator(),
                                    );
                        },
                      ),
                      ModalFilter.modalItemWithMarginBottom(
                        child: DateRangePicker(
                          // hasInitialDate: false,
                          hasInitialDate: _ventaFilter.fechaDesde != null &&
                              _ventaFilter.fechaHasta != null,
                          initialDateRange: _ventaFilter.fechaDesde != null &&
                                  _ventaFilter.fechaHasta != null
                              ? DateTimeRange(
                                  start:
                                      DateTime.parse(_ventaFilter.fechaDesde),
                                  end: DateTime.parse(_ventaFilter.fechaHasta))
                              : null,
                          onDateChanged: (DateTimeRange date) {
                            setState(() {
                              _ventaFilter.fechaDesde = dateTimeToString(
                                date: date.start,
                                dateFormat: DateFormat('yyyy-MM-dd'),
                              );
                              _ventaFilter.fechaHasta = dateTimeToString(
                                date: date.end,
                                dateFormat: DateFormat('yyyy-MM-dd'),
                              );
                            });
                          },
                        ),
                      ),
                      ModalFilter.modalItemWithMarginBottomAndTitle(
                        title: Text('Rango de precios',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        child: PriceRange(
                          initialValueMin: _ventaFilter.montoMinimo,
                          initialValueMax: _ventaFilter.montoMaximo,
                          onChangedMin: (min) => _ventaFilter.montoMinimo = min,
                          onChangedMax: (max) => _ventaFilter.montoMaximo = max,
                        ),
                      ),
                    ],
                  ),
                ),
                onReset: () {
                  _resetFilters();
                  _ventas.clear();
                  _getVenta();
                  Navigator.pop(context);
                },
                onFilter: () {
                  _ventaFilter.pagina = 1;
                  _ventaFilter.filas = 10;
                  _ventas.clear();
                  _getVenta();
                  Navigator.pop(context);
                },
              );
            })
      ],
    );
  }

  Widget _createItem(Venta venta) {
    Color color = venta.idEstado == Estado.getValue(EstadoEnum.CANCELADO)
        ? Colors.green
        : venta.idEstado == Estado.getValue(EstadoEnum.PENDIENTE)
            ? Colors.amber
            : Colors.red;

    bool isPendigState =
        venta.idEstado == Estado.getValue(EstadoEnum.PENDIENTE);

    return Dismissible(
      key: Key(venta.numeroComprobante),
      direction: DismissDirection.endToStart,
      background: DismissibleBackground(
        color: Colors.redAccent,
        icon: Icons.delete,
        text: 'Anular',
      ),
      confirmDismiss: (direction) async {
        if (venta.idEstado == Estado.getValue(EstadoEnum.ANULADO)) return false;
        final bool res = await showDialog(
          context: context,
          builder: (BuildContext context) => StatefulBuilder(
            builder: (context, StateSetter _setState) {
              _stateModal = _setState;
              return AlertDialog(
                content: Text(
                    "¿Esta seguro de ANULAR la venta con comprobante ${venta.numeroComprobante}?"),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            _isDeleting ? Colors.grey : Colors.redAccent)),
                    child: Text(
                      "${_isDeleting ? 'Anulando' : 'Anular venta'}",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _isDeleting ? null : () => onDelete(venta),
                  ),
                ],
              );
            },
          ),
        );
        return res;
      },
      child: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.circle,
                    color: color,
                  ),
                ],
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(),
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(5.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${venta.cliente}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isPendigState
                              ? 'S/ ${(venta.montoTotal - venta.montoPagado).toStringDouble(2)}'
                              : 'S/ ${venta.montoTotal.toStringDouble(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(5.0)),
                  Text('${venta.numeroComprobante}  ${venta.estado}'),
                  Padding(padding: EdgeInsets.all(5.0)),
                  Text('Fecha: ${venta.fechaVenta}'),
                  Padding(padding: EdgeInsets.all(5.0)),
                ],
              ),
              onTap: () => _goVenta(context, venta.numeroComprobante),
              trailing: Icon(
                venta.idEstado == Estado.getValue(EstadoEnum.PENDIENTE) ||
                        venta.idEstado == Estado.getValue(EstadoEnum.CANCELADO)
                    ? Icons.keyboard_arrow_right
                    : null,
                color: Colors.green,
              ),
              // onTap: () =>
              //     _goFormPage(context, producto.idProducto.toString())
            ),
            Divider(
              height: 0,
            )
          ],
        ),
      ),
    );
  }

  void onDelete(Venta venta) async {
    _isDeleting = true;
    if (mounted) {
      setState(() {});
      _stateModal(() {});
    }
    try {
      final msg = await _ventasProvider.cancelVenta(venta.numeroComprobante);
      final index = _ventas.indexWhere(
          (element) => element.numeroComprobante == venta.numeroComprobante);
      _isDeleting = false;

      _customAlertDialog.confirmAlert(
        context: context,
        title: 'Eliminación exitosa',
        description: msg,
        text: 'Aceptar',
        backFunction: () {
          Navigator.pop(context);
          _removeItem(index);
        },
      );

      if (mounted) {
        setState(() {});
        _stateModal(() {});
      }
    } catch (e) {
      _customAlertDialog.errorAlert(
        context: context,
        title: 'Ops!',
        description: 'Ocurrio un error.',
        text: 'Aceptar',
      );
      _isDeleting = false;
      if (mounted) {
        setState(() {});
        _stateModal(() {});
      }
    }
  }

  void _removeItem(int index) {
    _ventas.removeAt(index);
    setState(() {});
  }

  void _resetFilters() {
    _clienteSelected = null;
    _invernaderoSelected = null;
    _campaniaSelected = null;
    _estadoSelected = null;
    _ventaFilter = new VentaFilter();
    setState(() {});
  }
}
