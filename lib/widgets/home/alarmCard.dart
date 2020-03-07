import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lecture_alarm_20_1/model/lecture.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';

class AlarmCard extends StatelessWidget {
  final Lecture lecture;

  const AlarmCard({this.lecture});

  @override
  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context);

    return Container(
      child: Card(
        child: ListTile(
            title: Text(lecture.name),
            subtitle: Text('${lecture.professor} / ${lecture.time}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                alarm.removeAlarm(lecture.id);
              },
            )),
      ),
    );
  }
}
