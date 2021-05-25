import 'package:flutter/material.dart';

class DismissibleBackground extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  DismissibleBackground(
      {Key key, @required this.text, @required this.color, @required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
            ),
            Text(
              " $text",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
