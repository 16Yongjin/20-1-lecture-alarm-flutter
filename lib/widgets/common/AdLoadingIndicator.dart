import 'package:flutter/material.dart';

class AdLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.4),
      child: Center(
        child: SizedBox(
          height: 150,
          width: 200,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('광고 불러오는 중..'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
