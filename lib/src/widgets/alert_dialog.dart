import 'dart:ui';
import 'package:flutter/material.dart';

class Constants {
  Constants._();
  static const double padding = 15;
  static const double avatarRadius = 45;
}

class CustomAlertDialog {
  static CustomAlertDialog _alertDialog;

  confirmAlert(
      {BuildContext context,
      Function backFunction,
      String title,
      String description,
      String text}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(
                context: context,
                title: title,
                description: description,
                text: text,
                backFunction: backFunction,
                alertType: 'success'),
          );
        });
  }

  errorAlert(
      {BuildContext context,
      Function backFunction,
      String title = 'Ops!',
      String description = 'Ocurrio un error.',
      String text = 'Aceptar'}) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.padding),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: contentBox(
                context: context,
                title: title,
                description: description,
                text: text,
                backFunction: backFunction,
                alertType: 'error'),
          );
        });
  }

  Widget showErrorInBuilders(BuildContext context) {
    Future.delayed(
        Duration.zero,
        () => errorAlert(
              context: context,
            ));
    return Container();
  }

  Widget contentBox(
      {BuildContext context,
      Function backFunction,
      String title,
      String description,
      String text,
      String alertType}) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black54,
                    // offset: Offset(0, 10),
                    blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                description,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (backFunction != null) {
                        backFunction();
                      }
                    },
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.asset(
                    'assets/${alertType == "success" ? "success" : "error"}.png')),
          ),
        ),
      ],
    );
  }
}
