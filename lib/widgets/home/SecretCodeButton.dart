import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:toast/toast.dart';

class SecretCodeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      splashColor: Colors.white,
      onPressed: null,
      textColor: Colors.black,
      child: SizedBox(),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('비밀코드 입력'),
            content: TextFormField(
              onFieldSubmitted: (code) {
                String hello = '땡';

                if (code == '포어과') {
                  final alarm = Provider.of<Alarm>(context, listen: false);
                  alarm.incrementAlarmLimit(7);
                  hello = '반가워요';
                }

                Toast.show(
                  hello,
                  context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.CENTER,
                );

                Navigator.popUntil(
                    context, (Route<dynamic> route) => route.isFirst);
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('닫기'),
                onPressed: () => Navigator.of(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
