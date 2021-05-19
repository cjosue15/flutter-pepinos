import 'package:flutter/material.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class ErrorScreen extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  ErrorScreen({Key key, this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(),
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/error/error.png",
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.3,
            right: MediaQuery.of(context).size.width * 0.3,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                "${text ?? 'Ir al inicio'}".toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
