import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:lecture_alarm_20_1/utils/lifecycleListener.dart';
import 'package:lecture_alarm_20_1/widgets/addAlarm/addModal.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'alarmCard.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool loadingRewardedVideoAd = false;

  void loadRewardedVideo() {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo();

    RewardedVideoAd.instance.load(
        adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: targetingInfo);

    RewardedVideoAd.instance.listener = rewardedVideoListner;

    setState(() {
      loadingRewardedVideoAd = true;
    });
  }

  void rewardedVideoListner(RewardedVideoAdEvent event,
      {String rewardType, int rewardAmount}) async {
    print("**************** event: $event *********************");

    if (event == RewardedVideoAdEvent.loaded) {
      RewardedVideoAd.instance.show();
    } else if (event == RewardedVideoAdEvent.rewarded) {
      final alarm = Provider.of<Alarm>(context, listen: false);
      await alarm.incrementAlarmLimit(1);
    }

    setState(() {
      loadingRewardedVideoAd = false;
    });
  }

  @override
  void initState() {
    super.initState();

    final alarm = Provider.of<Alarm>(context, listen: false);

    // 알람 등록 가능개수 초기화
    alarm.initAlarmLimit();

    // 기기 방향 설정
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // onResume 시 알람 새로고침
    WidgetsBinding.instance
        .addObserver(LifecycleEventHandler(resumeCallBack: () {
      return alarm.loadMyAlarms();
    }));

    // 알람 수신 시 이벤트 등록
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      alarm.loadMyAlarms();

      print("onMessage: $message");

      FlutterRingtonePlayer.playNotification();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: ListTile(title: Text(message['notification']['title'])),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });

    _firebaseMessaging.getToken().then((token) {
      print(token);
      alarm.setUserId(token);
      alarm.loadMyAlarms();
    }).catchError((e) {
      print('************* Firebase messaging Error!! ************');
      print(e.toString());
    });

    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-9040837646422745~1053576428');

    RewardedVideoAd.instance.listener = rewardedVideoListner;
  }

  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('한국외대 수강신청 빈자리 알람'),
        actions: alarm.alarmLimit >= 5
            ? null
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.card_giftcard),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: ListTile(
                          title: Text('알람등록 가능개수를 늘릴까요?'),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            textColor: Colors.black,
                            child: Text('아뇨'),
                            onPressed: () => Navigator.of(
                              context,
                            ).pop(false),
                          ),
                          FlatButton(
                            child: Text('네 (광고 보기)'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    ).then((adAccepted) {
                      if (adAccepted != null && adAccepted) loadRewardedVideo();
                    });
                  },
                )
              ],
      ),
      body: loadingRewardedVideoAd
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('광고 불러오는 중..')
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(12.0),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                      '내가 등록한 알람 ${alarm.myAlarms.length} / ${alarm.alarmLimit}개',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                ...alarm.myAlarms.map((lecture) => AlarmCard(lecture: lecture))
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              height: 48,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: alarm.hitAlarmLimit
            ? Colors.grey[300]
            : Theme.of(context).primaryColor,
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text(
          '알람 추가하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: alarm.hitAlarmLimit
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute<String>(
                    builder: (BuildContext context) => AddAlarmModal(),
                    fullscreenDialog: true,
                  ),
                ).then((message) {
                  if (message == null || message.isEmpty) return;

                  showToast(message);
                });
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void showToast(String message) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.TOP,
    );
  }
}
