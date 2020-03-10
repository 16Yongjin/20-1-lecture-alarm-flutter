import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lecture_alarm_20_1/model/lecture.dart';

const String apiUrl = 'https://api.lecture.hufs.app';
const String userApiUrl = '$apiUrl/users';

class AlarmProvider {
  static Future<List<Lecture>> loadMyAlarms(String userId) async {
    print('loadMyAlarms');

    try {
      final response = await http.get('$userApiUrl/$userId');
      return parseLectures(response);
    } catch (e) {
      throw Exception('알람 가져오기에 실패했습니다.');
    }
  }

  static Future<List<Lecture>> addAlarm(String userId, String lectureId) async {
    print('userId: $userId');
    print('lectureId: $lectureId');

    if (userId.isEmpty) throw new Exception('알람 토큰이 없어서 알람을 등록할 수 없습니다.');
    if (lectureId.isEmpty) throw new Exception('강의를 선택해주세요');

    final body = json.encode({'userId': userId, 'lectureId': lectureId});

    final response = await http.post(
      userApiUrl,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      return parseLectures(response);
    } else {
      throw Exception('알람 등록에 실패했습니다.');
    }
  }

  static Future<List<Lecture>> removeAlarm(
      String userId, String lectureId) async {
    final response = await http.delete('$userApiUrl/$userId/$lectureId');

    if (response.statusCode == 200) {
      return parseLectures(response);
    } else {
      throw Exception('알람 삭제에 실패했습니다.');
    }
  }

  static Future<List<Lecture>> fetchLectures(String courseId) async {
    final response = await http.get('$apiUrl/lectures/$courseId');

    if (response.statusCode == 200) {
      return parseLectures(response);
    } else {
      throw Exception('강의를 가져오는데 실패했습니다.');
    }
  }

  static Future<List<Lecture>> searchLectures(String query) async {
    final response = await http.get('$apiUrl/lectures/search?name=$query');

    if (response.statusCode == 200) {
      return parseLectures(response);
    } else {
      throw Exception('강의를 가져오는데 실패했습니다.');
    }
  }

  static List<Lecture> parseLectures(http.Response response) {
    String body = utf8.decode(response.bodyBytes);

    List<Lecture> lectures = List();

    json.decode(body).forEach((v) {
      lectures.add(Lecture.fromJson(v));
    });

    return lectures;
  }
}
