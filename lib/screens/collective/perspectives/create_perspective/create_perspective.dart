import 'package:flutter/material.dart';

import '../../../../typography/style.dart';
import '../../../../typography/palette.dart';
import '../../../../custom_icons.dart';

class CreatePerspective extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: AppBar(
            automaticallyImplyLeading: false,
            brightness: Brightness.light,
            iconTheme: IconThemeData(color: JuntoPalette.juntoSleek),
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(CustomIcons.back_arrow_left,
                      color: JuntoPalette.juntoSleek, size: 24),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Color(0xffeeeeee),
              )
            )
          ),
          
        ),
        
        body: Column(
          children: <Widget>[],
        ));
  }
}
