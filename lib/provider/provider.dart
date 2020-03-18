import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:lecture_alarm_20_1/model/lecture.dart';
import 'package:lecture_alarm_20_1/provider/alarmProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const ALARM_LIMIT = 7;

class Alarm with ChangeNotifier {
  String _userId;
  List<Lecture> _myAlarms = [];
  int _alarmLimit = 2;

  String get userId => _userId;
  List<Lecture> get myAlarms => _myAlarms;
  int get alarmLimit => _alarmLimit;
  bool get hitAlarmLimit => _myAlarms.length >= _alarmLimit;
  bool get canGetReward => _alarmLimit < ALARM_LIMIT;

  Future<void> loadMyAlarms() async {
    _myAlarms = await AlarmProvider.loadMyAlarms(userId);
    notifyListeners();
  }

  Future<void> addAlarm(String lectureId) async {
    _myAlarms = await AlarmProvider.addAlarm(userId, lectureId);
    notifyListeners();
  }

  void removeAlarm(String lectureId) async {
    _myAlarms = await AlarmProvider.removeAlarm(userId, lectureId);
    notifyListeners();
  }

  void setUserId(String token) {
    _userId = token ?? '';
  }

  void initAlarmLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _alarmLimit = prefs.getInt('alarmLimit') ?? 2;
    notifyListeners();
  }

  incrementAlarmLimit(int n) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _alarmLimit = min(alarmLimit + n, ALARM_LIMIT);
    await prefs.setInt('alarmLimit', alarmLimit);
    print('incrementAlarmLimit $alarmLimit');
    notifyListeners();
  }
}
