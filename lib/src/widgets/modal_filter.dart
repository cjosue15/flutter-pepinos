import 'package:flutter/material.dart';

class ModalFilter {
  static modalBottomSheet({
    BuildContext context,
    @required Form filters,
    void Function() onReset,
    void Function() onFilter,
  }) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      builder: (BuildContext context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'FILTROS',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              filters,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar '),
                  ),
                  ElevatedButton(
                    onPressed: onReset,
                    child: Text('Resetear'),
                  ),
                  ElevatedButton(
                    onPressed: onFilter,
                    child: Text('Filtrar'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static modalItemWithMarginBottom({@required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      child: child,
    );
  }

  static modalItemWithMarginBottomAndTitle(
      {@required Widget child, @required Widget title}) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: title,
        ),
        SizedBox(
          height: 20.0,
        ),
        child,
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
