import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lecture_alarm_20_1/ads/rewardAd.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:lecture_alarm_20_1/utils/lifecycleListener.dart';
import 'package:lecture_alarm_20_1/widgets/addAlarm/addAlarm.dart';
import 'package:lecture_alarm_20_1/widgets/common/AdLoadingIndicator.dart';
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
  bool loadingAd = false;

  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('수강신청 빈자리 알람'),
        actions: <Widget>[
          Visibility(
            visible: !loadingAd && alarm.canGetReward,
            child: RewardButton(onPressed: showRewardAdDialog),
          )
        ],
      ),
      body: Stack(
        children: [
          AlarmListView(alarm: alarm),
          if (loadingAd) AdLoadingIndicator(),
        ],
      ),
      bottomNavigationBar: HomeBottomAppBar(),
      floatingActionButton: HomeFAB(alarm: alarm, disabled: loadingAd),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  showRewardAdDialog() {
    final rewardAd = RewardAd(
      context: context,
      beforeLoading: () {
        setState(() {
          loadingAd = true;
        });
      },
      afterLoading: () {
        setState(() {
          loadingAd = false;
        });
      },
      afterReward: () {},
    );

    rewardAd.buildRewardDialog();
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
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(resumeCallBack: () => alarm.loadMyAlarms()),
    );

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
              child: Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });

    // FCM 토큰 가져오기, 실패하면 알람 등록 불가!
    _firebaseMessaging.getToken().then((token) {
      print(token);
      alarm.setUserId(token);
      alarm.loadMyAlarms();
    }).catchError((e) {
      print('************* Firebase messaging Error!! ************');
      print(e.toString());
      Toast.show(
        '알람 메시지용 토큰 가져오기 실패!! 알람등록이 불가합니다...',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
    });

    // 애드몹 설정
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-9040837646422745~1053576428');
  }
}

class AlarmListView extends StatelessWidget {
  const AlarmListView({@required this.alarm});

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(12.0),
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15),
          child: Text(
            '내가 등록한 알람 ${alarm.myAlarms.length} / ${alarm.alarmLimit}개',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        ...alarm.myAlarms.map((lecture) => AlarmCard(lecture: lecture))
      ],
    );
  }
}

class HomeBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[SizedBox(height: 48)],
      ),
    );
  }
}

class HomeFAB extends StatelessWidget {
  final Alarm alarm;
  final bool disabled;

  HomeFAB({this.alarm, this.disabled});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: !disabled && alarm.canGetReward
          ? Theme.of(context).primaryColor
          : Colors.grey[300],
      elevation: 4.0,
      icon: const Icon(Icons.add),
      label:
          const Text('알람 추가하기', style: TextStyle(fontWeight: FontWeight.bold)),
      onPressed: !disabled && alarm.canGetReward ? goAddAlarm(context) : null,
    );
  }

  goAddAlarm(BuildContext context) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute<String>(
          builder: (BuildContext context) => AddAlarmModal(),
          fullscreenDialog: true,
        ),
      ).then((message) {
        if (message == null || message.isEmpty) return;

        Toast.show(
          message,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
      });
    };
  }
}

class RewardButton extends StatelessWidget {
  RewardButton({@required this.onPressed});

  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.card_giftcard),
      onPressed: onPressed,
    );
  }
}
