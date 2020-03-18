import 'package:flutter/material.dart';
import 'package:lecture_alarm_20_1/model/lecture.dart';
import 'package:lecture_alarm_20_1/provider/alarmProvider.dart';
import 'lectureList.dart';

class AddAlarmBySearch extends StatefulWidget {
  final Function onLectureSelect;

  AddAlarmBySearch({@required this.onLectureSelect});

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
        searching = false;
      });
    }).catchError((err) {
      setState(() {
        error = err.toString();
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
          autofocus: true,
          onFieldSubmitted: onLectureSearch,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            hintText: '강의명 또는 교수명을 입력하세요.',
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
