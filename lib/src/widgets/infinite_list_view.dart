import 'package:flutter/material.dart';
import 'package:pepinos/src/models/paginacion_model.dart';
import 'package:pepinos/src/widgets/screens/error_screen.dart';
import 'package:pepinos/src/widgets/screens/no_data_screen.dart';

class InfiniteListView<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final void Function(int) onScroll;
  final Paginacion paginacion;
  final List<T> data;
  final bool isFetching;
  final bool isInitialLoading;
  final bool hasInitialError;
  final bool hasErrorAfterFetching;
  final int length;
  final BuildContext context;

  InfiniteListView({
    Key key,
    this.context,
    @required this.itemBuilder,
    this.onScroll,
    @required this.paginacion,
    @required this.data,
    this.isFetching = false,
    this.isInitialLoading = false,
    @required this.length,
    this.hasInitialError = false,
    this.hasErrorAfterFetching = false,
  })  : assert(data != null, 'init data must not be null'),
        assert(itemBuilder != null, 'itemBuilder must not be null'),
        assert(length != null, 'length must not be null'),
        super(key: key);

  @override
  _InfiniteListViewState createState() => _InfiniteListViewState<T>();
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  ScrollController _scrollController = new ScrollController();
  bool hasDataAfterScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleController);
  }

  @override
  void didUpdateWidget(InfiniteListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.length != oldWidget.length && oldWidget.data.length > 0) {
      _scrollController.animateTo(_scrollController.position.pixels + 50,
          duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
    }

    if (widget.hasErrorAfterFetching) {
      showSnackBarError();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isInitialLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Stack(
            children: <Widget>[
              widget.hasInitialError
                  ? ErrorScreen(
                      hasAppBar: false,
                    )
                  : widget.data.length > 0
                      ? ListView.builder(
                          controller: _scrollController,
                          itemCount: widget.data?.length ?? 0,
                          itemBuilder: (context, index) => widget.itemBuilder(
                              context, widget.data[index], index),
                        )
                      : NoResultFoundScreen(
                          hasAppBar: false,
                        ),
              _createLoading(),
            ],
          );
  }

  Widget _createLoading() {
    return widget.isFetching
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

  void _handleController() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (widget.paginacion.pagSiguiente == null || widget.isFetching) {
        setState(() {
          hasDataAfterScroll = false;
        });
        return;
      } else {
        setState(() {
          hasDataAfterScroll = true;
        });
      }
      widget.onScroll(widget.paginacion.pagSiguiente);
    }
  }

  void showSnackBarError() {
    Future.delayed(
      Duration.zero,
      () async {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Colors.white,
              ),
              SizedBox(
                height: 10.0,
              ),
              Text('Ops ocurrio un error!')
            ],
          ),
          duration: Duration(seconds: 2),
        );

        ScaffoldMessenger.of(widget.context).showSnackBar(snackBar);
      },
    );
  }
}
