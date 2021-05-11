import 'package:flutter/material.dart';
import 'package:pepinos/src/models/paginacion_model.dart';

// typedef ItemBuilder<T> = Widget Function(T item, int index);

class InfiniteListView<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final void Function(int) onScroll;
  final Paginacion paginacion;
  final List<T> data;
  final bool isFetching;
  final bool isInitialLoading;
  final int length;

  InfiniteListView({
    this.itemBuilder,
    this.onScroll,
    this.paginacion,
    this.data,
    this.isFetching = false,
    this.isInitialLoading = false,
    this.length,
  });

  @override
  _InfiniteListViewState createState() => _InfiniteListViewState<T>();
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  ScrollController _scrollController = new ScrollController();
  bool hasDataAfterScroll = true;

  @override
  void initState() {
    super.initState();
    // print(widget.data);
    _scrollController.addListener(_handleController);
  }

  @override
  void didUpdateWidget(InfiniteListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.data != oldWidget.data) {
    //   print('cambio?');
    // }
    // print(oldWidget.data.length);
    // // print(widget.data.length);
    if (widget.length != oldWidget.length && oldWidget.data.length > 0) {
      _scrollController.animateTo(_scrollController.position.pixels + 50,
          duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
    }

    //     if (widget.length != oldWidget.length &&
    //     oldWidget.data.length > 0 &&
    //     !widget.isInitialLoading) {
    //   print('cambio length');
    //   // _scrollController.animateTo(_scrollController.position.pixels + 50,
    //   //     duration: Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
    // }
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
              widget.data.length > 0
                  ? ListView.builder(
                      controller: _scrollController,
                      itemCount: widget.data?.length ?? 0,
                      itemBuilder: (context, index) => widget.itemBuilder(
                          context, widget.data[index], index),
                    )
                  : Container(),
              // ListView(
              //   controller: _scrollController,
              //   children: <Widget>[
              //     for (var i = 0; i < widget.data.length; i++)
              //       widget.itemBuilder(context, widget.data[i], i),
              //     hasDataAfterScroll
              //         ? Container()
              //         : ListTile(
              //             title: Text('No data'),
              //           )
              //   ],
              // ),
              // hasDataAfterScroll ? Container() : Text('No more data'),
              _createLoading()
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

  _handleController() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (widget.paginacion.pagSiguiente == null || widget.isFetching) {
        print('not more data');
        setState(() {
          hasDataAfterScroll = false;
        });
        return;
      } else {
        setState(() {
          hasDataAfterScroll = true;
        });
        print('has more data');
      }
      widget.onScroll(widget.paginacion.pagSiguiente);
    }
  }
}
