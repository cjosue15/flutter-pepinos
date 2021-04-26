import 'package:flutter/material.dart';
import 'package:pepinos/src/enums/estado_enum.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/models/venta_model.dart';
import 'package:pepinos/src/providers/ventas/ventas_provider.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';
import 'package:pepinos/src/widgets/alert_dialog.dart';

class VentasPage extends StatefulWidget {
  @override
  _VentasPageState createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final _ventasProvider = new VentasProvider();
  ScrollController _scrollController = new ScrollController();
  bool _isLoading = false;
  Paginacion _paginacion = new Paginacion();
  CustomAlertDialog alert = new CustomAlertDialog();
  int _nextPage = 1;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleController);

    _ventasProvider.getVentas(pagina: _nextPage).then((response) {
      print(response);
      setState(() {
        _paginacion = response['paginacion'];
      });
    }).catchError((error) {
      _ventasProvider.disposeStream();
      print(error);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _ventasProvider.disposeStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas'),
      ),
      drawer: DrawerMenu(),
      body: Stack(
        children: <Widget>[_createStreamListVenta(), _createLoading()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goVenta(context, null),
        child: Icon(Icons.add),
      ),
    );
  }

  void _goVenta(BuildContext context, String numeroComprobante) {
    Navigator.pushNamed(
        context, 'ventas/${numeroComprobante == null ? 'form' : 'detail'}',
        arguments: numeroComprobante);
  }

  Widget _createStreamListVenta() {
    return StreamBuilder(
      stream: _ventasProvider.ventasStream,
      builder: (BuildContext context, AsyncSnapshot<List<Venta>> snapshot) {
        return snapshot.hasData
            ? _createListVenta(snapshot.data)
            : snapshot.hasError
                ? alert.showErrorInBuilders(context)
                : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _createListVenta(List<Venta> ventas) {
    print(ventas);
    return ListView.builder(
        controller: _scrollController,
        itemCount: ventas.length,
        itemBuilder: (BuildContext context, int index) =>
            _createItem(ventas[index]));
  }

  Widget _createItem(Venta venta) {
    Color color = venta.idEstado == Estado.getValue(EstadoEnum.CANCELADO)
        ? Colors.green
        : venta.idEstado == Estado.getValue(EstadoEnum.PENDIENTE)
            ? Colors.amber
            : Colors.red;

    return Container(
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Boleta ${venta.numeroComprobante}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'S/ ${venta.montoTotal.toString()}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            subtitle: Text(venta.cliente + ' - ' + venta.estado),
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
          Divider()
        ],
      ),
    );
  }

  Widget _createLoading() {
    return _isLoading
        ? Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                Center(child: CircularProgressIndicator()),
                SizedBox(
                  height: 20.0,
                )
              ])
        : Container();
  }

  _handleController() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_paginacion.pagSiguiente == null) return;
      _nextPage++;
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await _ventasProvider.getVentas(pagina: _nextPage);
        setState(() {
          _paginacion = response['paginacion'];
          _isLoading = false;
        });
        _scrollController.animateTo(_scrollController.position.pixels + 50,
            duration: Duration(milliseconds: 450), curve: Curves.fastOutSlowIn);
      } catch (e) {
        _ventasProvider.disposeStream();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
