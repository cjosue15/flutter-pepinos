import 'package:flutter/material.dart';
import 'package:pepinos/src/widgets/drawer_menu.dart';

class NoResultFoundScreen extends StatelessWidget {
  final bool hasAppBar;

  NoResultFoundScreen({Key key, this.hasAppBar = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: hasAppBar ? DrawerMenu() : null,
      appBar: hasAppBar ? AppBar() : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/no-data-screen.png",
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.065,
            right: MediaQuery.of(context).size.width * 0.065,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 13),
                    blurRadius: 25,
                    color: Color(0xFF5666C2).withOpacity(0.17),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
