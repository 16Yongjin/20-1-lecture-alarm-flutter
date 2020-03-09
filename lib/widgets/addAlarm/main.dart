import 'package:flutter/material.dart';

import 'package:lecture_alarm_20_1/provider/alarmProvider.dart';
import 'package:provider/provider.dart';

import 'package:lecture_alarm_20_1/data/courses.dart';
import 'package:lecture_alarm_20_1/model/lecture.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:lecture_alarm_20_1/widgets/addAlarm/bottomAppBar.dart';
import 'departmentDropdown.dart';
import 'lectureList.dart';
import 'radioWidget.dart';

class AddAlarmModal extends StatefulWidget {
  @override
  _AddAlarmModalState createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  String campusSelect = '서울';
  String courseSelect = '전공';
  String departmentSelect = 'ATMB3_H1';
  String lectureSelect = '';
  List<Lecture> lectures = [];
  String error = '';

  @override
  void initState() {
    super.initState();

    fetchLectures(departmentSelect);
  }

  void onCampusSelect(String campus) {
    setState(() {
      campusSelect = campus;
      departmentSelect = Courses.courses[campusSelect + courseSelect][0][1];
    });
    fetchLectures(departmentSelect);
  }

  void onCourseSelect(String course) {
    setState(() {
      courseSelect = course;
      departmentSelect = Courses.courses[campusSelect + courseSelect][0][1];
    });
    fetchLectures(departmentSelect);
  }

  void onDepartmentSelect(String department) {
    setState(() {
      departmentSelect = department;
    });
    fetchLectures(departmentSelect);
  }

  fetchLectures(courseId) {
    setState(() {
      lectureSelect = '';
      error = '';
      lectures = [];
    });

    AlarmProvider.fetchLectures(departmentSelect).then((v) {
      setState(() {
        lectures = v;
      });
    }).catchError((err) {
      setState(() {
        error = err.toString();
      });
    });
  }

  onLectureSelect(String lectureId) {
    setState(() {
      lectureSelect = lectureSelect == lectureId ? '' : lectureId;
    });
  }

  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('알람 추가하기'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        children: <Widget>[
          Center(
            child: Text(
              '알람을 추가할 강의를 선택하세요.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RadioWidget(
            label: '캠퍼스:',
            values: ['서울', '글로벌'],
            onSelect: onCampusSelect,
          ),
          RadioWidget(
            label: '과정:',
            values: ['전공', '교양'],
            onSelect: onCourseSelect,
          ),
          DepartmentDropdown(
            courseSelect: campusSelect + courseSelect,
            departmentSelect: departmentSelect,
            onChange: onDepartmentSelect,
          ),
          LectureList(
            lectures: lectures,
            selectedLectureId: lectureSelect,
            onLectureSelect: onLectureSelect,
            error: error,
          ),
        ],
      ),
      bottomNavigationBar: AddModalBottomAppBar(),
      floatingActionButton: AddModalFloatingActionButton(
        disabled: error.isEmpty && lectureSelect.isEmpty,
        onPress: () async {
          print('hi');
          try {
            await alarm.addAlarm(lectureSelect);
            Navigator.of(context).pop('알람 등록 성공!!');
          } catch (e) {
            setState(() {
              error = e.toString();
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class AddModalFloatingActionButton extends StatelessWidget {
  const AddModalFloatingActionButton({this.disabled, this.onPress});

  final bool disabled;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor:
          disabled ? Colors.grey[300] : Theme.of(context).primaryColor,
      elevation: 4.0,
      icon: const Icon(Icons.add),
      label: const Text(
        '알람 추가하기',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: disabled ? null : onPress,
    );
  }
}
