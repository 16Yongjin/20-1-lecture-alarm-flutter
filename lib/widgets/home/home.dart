import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:lecture_alarm_20_1/utils/lifecycleListener.dart';
import 'package:lecture_alarm_20_1/widgets/addAlarm/addAlarm.dart';
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

  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('수강신청 빈자리 알람'),
        actions: <Widget>[
          Visibility(
            visible: alarm.canGetReward,
            child: RewardButton(onAccept: loadRewardedVideo),
          )
        ],
      ),
      body: loadingRewardedVideoAd
          ? AdLoadingIndicator()
          : AlarmListView(alarm: alarm),
      bottomNavigationBar: HomeBottomAppBar(),
      floatingActionButton: HomeFAB(alarm: alarm),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void loadRewardedVideo() {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
        testDevices: ['1C8F235CDB9E582FD41E7A89887A3F5A']);

    RewardedVideoAd.instance.load(
      adUnitId: 'ca-app-pub-9040837646422745/5731188034',
      targetingInfo: targetingInfo,
    );

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
    } else if (event == RewardedVideoAdEvent.failedToLoad) {
      Toast.show(
        '광고 불러오기 실패...',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP,
      );
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
              child: Text('Ok'),
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
          child:
              Text('내가 등록한 알람 ${alarm.myAlarms.length} / ${alarm.alarmLimit}개',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
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
  const HomeFAB({@required this.alarm});

  final Alarm alarm;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: alarm.hitAlarmLimit
          ? Colors.grey[300]
          : Theme.of(context).primaryColor,
      elevation: 4.0,
      icon: const Icon(Icons.add),
      label:
          const Text('알람 추가하기', style: TextStyle(fontWeight: FontWeight.bold)),
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

                Toast.show(
                  message,
                  context,
                  duration: Toast.LENGTH_LONG,
                  gravity: Toast.TOP,
                );
              });
            },
    );
  }
}

class AdLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('광고 불러오는 중..'),
        ],
      ),
    );
  }
}

class RewardButton extends StatelessWidget {
  RewardButton({this.onAccept});

  final Function onAccept;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.card_giftcard),
      onPressed: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('알람등록 가능개수를 늘릴까요?'),
            content: Text('한번에 1개씩 7개까지 늘릴 수 있어요.'),
            actions: <Widget>[
              FlatButton(
                splashColor: Colors.white,
                onPressed: null,
                textColor: Colors.black,
                child: SizedBox(),
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('비밀코드 입력'),
                      content: TextFormField(
                        onFieldSubmitted: (code) {
                          String hello = '땡';

                          if (code == '포어과') {
                            final alarm =
                                Provider.of<Alarm>(context, listen: false);
                            alarm.incrementAlarmLimit(7);
                            hello = '반가워요';
                          }

                          Toast.show(
                            hello,
                            context,
                            duration: Toast.LENGTH_LONG,
                            gravity: Toast.CENTER,
                          );

                          Navigator.popUntil(
                              context, (Route<dynamic> route) => route.isFirst);
                        },
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('닫기'),
                          onPressed: () => Navigator.of(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
              FlatButton(
                textColor: Colors.black,
                child: Text('아뇨'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text('네 (광고 보기)'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ).then((adAccepted) {
          if (adAccepted != null && adAccepted) onAccept();
        });
      },
    );
  }
}
