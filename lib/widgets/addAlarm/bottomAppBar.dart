import 'package:flutter/material.dart';

class AddModalBottomAppBar extends StatelessWidget {
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
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: ListTile(
                    title: Text('장식용 입니다.'),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('ㅇㅋ'),
                      onPressed: () => Navigator.of(context).pop(''),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
