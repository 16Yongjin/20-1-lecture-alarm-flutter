import 'package:flutter/material.dart';
import 'package:lecture_alarm_20_1/model/lecture.dart';

class LectureList extends StatelessWidget {
  final List<Lecture> lectures;
  final String selectedLectureId;
  final Function onLectureSelect;
  final String error;
  final bool searching;

  const LectureList({
    this.searching = true,
    this.lectures,
    this.selectedLectureId,
    this.onLectureSelect,
    this.error,
  });

  Color getColor(String lectureId) => selectedLectureId == lectureId
      ? Color.fromRGBO(204, 213, 221, 1)
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty)
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Text(
          error,
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
          ),
        ),
      );
    else if (searching && lectures.length <= 0)
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("강의 목록 가져오는 중.."),
          ],
        ),
      );
    else if (lectures.length <= 0)
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text("검색된 강의가 없습니다."),
          ],
        ),
      );
    else
      return Column(
        children: <Widget>[
          ...lectures.map((lecture) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              child: Container(
                color: getColor(lecture.id),
                child: ListTile(
                  onTap: () {
                    onLectureSelect(lecture.id);
                  },
                  title: Text(lecture.name),
                  subtitle: Text('${lecture.professor}\n${lecture.time}'),
                ),
              ),
            );
          })
        ],
      );
  }
}
