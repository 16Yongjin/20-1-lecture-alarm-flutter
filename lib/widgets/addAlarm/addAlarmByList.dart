import 'package:flutter/material.dart';
import 'package:lecture_alarm_20_1/data/courses.dart';
import 'package:lecture_alarm_20_1/model/lecture.dart';
import 'package:lecture_alarm_20_1/provider/alarmProvider.dart';
import 'package:lecture_alarm_20_1/widgets/addAlarm/radioWidget.dart';

import 'departmentDropdown.dart';
import 'lectureList.dart';

class AddAlarmByList extends StatefulWidget {
  final Function onLectureSelect;

  AddAlarmByList({this.onLectureSelect});

  @override
  _AddAlarmByListState createState() => _AddAlarmByListState();
}

class _AddAlarmByListState extends State<AddAlarmByList> {
  String campusSelect = '서울';
  String courseSelect = '전공';
  String departmentSelect = 'ATMB3_H1';
  String lectureSelect = '';
  String error = '';

  List<Lecture> lectures = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLectures(departmentSelect);
    });
  }

  resetState() {
    setState(() {
      lectureSelect = '';
      error = '';
      lectures = [];
    });

    widget.onLectureSelect('');
  }

  onCampusSelect(String campus) {
    setState(() {
      campusSelect = campus;
      departmentSelect = Courses.courses[campusSelect + courseSelect][0][1];
    });
    fetchLectures(departmentSelect);
  }

  onCourseSelect(String course) {
    setState(() {
      courseSelect = course;
      departmentSelect = Courses.courses[campusSelect + courseSelect][0][1];
    });
    fetchLectures(departmentSelect);
  }

  onDepartmentSelect(String department) {
    setState(() {
      departmentSelect = department;
    });
    fetchLectures(departmentSelect);
  }

  fetchLectures(courseId) {
    resetState();

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
    print(lectureId);

    setState(() {
      lectureSelect = lectureSelect == lectureId ? '' : lectureId;
    });

    widget.onLectureSelect(lectureSelect);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(30),
      children: <Widget>[
        Center(
          child: Text(
            '알람을 추가할 강의를 선택하세요.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }
}
