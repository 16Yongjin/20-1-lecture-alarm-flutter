import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:lecture_alarm_20_1/widgets/home/SecretCodeButton.dart';

class RewardAd {
  final BuildContext context;
  final Function beforeLoading;
  final Function afterLoading;
  final Function afterReward;
  final dialogTitle;
  final dialogText;

  RewardAd({
    this.context,
    this.beforeLoading,
    this.afterLoading,
    this.afterReward,
    this.dialogTitle = '알람을 더 많이 등록하세요!',
    this.dialogText = '알람 개수를 7개까지 늘릴 수 있어요.',
  });

  showErrorToast() {
    Toast.show(
      '광고 불러오기 실패...',
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.TOP,
    );
  }

  errorGuard(Function func) {
    try {
      func();
    } catch (e) {
      print(e);
      showErrorToast();
    }
  }

  loadRewardedVideo() {
    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
        testDevices: ['1C8F235CDB9E582FD41E7A89887A3F5A']);

    RewardedVideoAd.instance.load(
      adUnitId: 'ca-app-pub-9040837646422745/5731188034',
      targetingInfo: targetingInfo,
    );

    RewardedVideoAd.instance.listener = rewardedVideoListner;

    errorGuard(beforeLoading);
  }

  void rewardedVideoListner(RewardedVideoAdEvent event,
      {String rewardType, int rewardAmount}) async {
    print("**************** event: $event *********************");

    errorGuard(afterLoading);

    if (event == RewardedVideoAdEvent.loaded) {
      RewardedVideoAd.instance.show();
    } else if (event == RewardedVideoAdEvent.rewarded) {
      final alarm = Provider.of<Alarm>(context, listen: false);
      await alarm.incrementAlarmLimit(1);

      errorGuard(afterReward);
    } else if (event == RewardedVideoAdEvent.failedToLoad) {
      showErrorToast();
    }
  }

  buildRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogText),
        actions: <Widget>[
          SecretCodeButton(),
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
      if (adAccepted != null && adAccepted)
        loadRewardedVideo();
      else
        errorGuard(afterLoading);
    });
  }
}
