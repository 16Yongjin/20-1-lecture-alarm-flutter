import 'package:flutter/material.dart';

class AddModalBottomAppBar extends StatelessWidget {
  final Function onActionPress;
  final IconData actionIcon;

  AddModalBottomAppBar({this.onActionPress, this.actionIcon});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: Icon(actionIcon),
            onPressed: onActionPress,
          ),
        ],
      ),
    );
  }
}
