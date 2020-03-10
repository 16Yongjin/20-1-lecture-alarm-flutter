import 'package:flutter/material.dart';

import 'package:lecture_alarm_20_1/provider/alarmProvider.dart';
import 'package:provider/provider.dart';

import 'package:lecture_alarm_20_1/data/courses.dart';
import 'package:lecture_alarm_20_1/model/lecture.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:lecture_alarm_20_1/widgets/addAlarm/bottomAppBar.dart';
import 'package:toast/toast.dart';
import 'departmentDropdown.dart';
import 'lectureList.dart';
import 'radioWidget.dart';

class AddAlarmModal extends StatefulWidget {
  @override
  _AddAlarmModalState createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  String lectureSelect = '';
  bool search = false;

  resetState() {
    setState(() {
      lectureSelect = '';
    });
  }

  switchAddMethod() {
    resetState();
    setState(() {
      search = !search;
    });
  }

  onLectureSelect(String lectureId) {
    setState(() {
      lectureSelect = lectureId;
    });
  }

  onAddAlarm() async {
    final alarm = Provider.of<Alarm>(context, listen: false);

    try {
      await alarm.addAlarm(lectureSelect);
      Navigator.of(context).pop('알람 등록 성공!!');
    } catch (e) {
      Toast.show(
        e.toString(),
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false, // 키보드 입력 시 fab 뜨는 거 방지
      appBar: AppBar(
        title: Text('알람 추가하기'),
        automaticallyImplyLeading: false,
      ),
      body: search
          ? AddAlarmBySearch(onLectureSelect: onLectureSelect)
          : AddAlarmByList(onLectureSelect: onLectureSelect),
      bottomNavigationBar: AddModalBottomAppBar(
        actionIcon: search ? Icons.list : Icons.search,
        onActionPress: switchAddMethod,
      ),
      floatingActionButton: AddModalFloatingActionButton(
        disabled: lectureSelect.isEmpty,
        onPress: onAddAlarm,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class AddAlarmBySearch extends StatefulWidget {
  final Function onLectureSelect;

  AddAlarmBySearch({this.onLectureSelect});

  @override
  _AddAlarmBySearchState createState() => _AddAlarmBySearchState();
}

class _AddAlarmBySearchState extends State<AddAlarmBySearch> {
  bool searching = false;

  String lectureSelect = '';
  String error = '';

  List<Lecture> lectures = [];

  onLectureSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      searching = true;
    });

    AlarmProvider.searchLectures(query).then((l) {
      setState(() {
        lectures = l;
      });
    }).catchError((err) {
      setState(() {
        error = err.toString();
      });
    }).whenComplete(() {
      setState(() {
        searching = false;
      });
    });
  }

  onLectureSelect(String lectureId) {
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
            '알람을 추가할 강의를 검색하세요.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          onFieldSubmitted: onLectureSearch,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
            hintText: '강의명을 입력하세요.',
          ),
        ),
        LectureList(
          searching: searching,
          lectures: lectures,
          selectedLectureId: lectureSelect,
          onLectureSelect: onLectureSelect,
          error: error,
        ),
      ],
    );
  }
}

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
