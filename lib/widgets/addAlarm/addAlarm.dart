import 'package:flutter/material.dart';
import 'package:lecture_alarm_20_1/ads/rewardAd.dart';
import 'package:lecture_alarm_20_1/widgets/common/AdLoadingIndicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'package:lecture_alarm_20_1/widgets/addAlarm/addAlarmBySeaerch.dart';
import 'package:lecture_alarm_20_1/provider/provider.dart';
import 'package:lecture_alarm_20_1/widgets/addAlarm/bottomAppBar.dart';
import 'addAlarmByList.dart';

class AddAlarmModal extends StatefulWidget {
  @override
  _AddAlarmModalState createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  String lectureSelect = '';
  bool search = false;
  bool loadingAd = false;

  switchAddMethod() {
    if (loadingAd) return;

    setState(() {
      lectureSelect = '';
      search = !search;
    });
  }

  onLectureSelect(String lectureId) {
    setState(() {
      lectureSelect = lectureId;
    });
  }

  addAlarm(String lectureSelect) async {
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

  onAddAlarm() async {
    final alarm = Provider.of<Alarm>(context, listen: false);
    final _lectureSelect = lectureSelect;
    if (!alarm.hitAlarmLimit) {
      addAlarm(_lectureSelect);
    } else if (alarm.canGetReward) {
      final rewardAd = RewardAd(
        context: context,
        dialogTitle: '등록가능한 알람 개수 초과!',
        dialogText: '알람 등록 가능 개수를 늘릴까요?',
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
        afterReward: () {
          addAlarm(_lectureSelect);
        },
      );

      rewardAd.buildRewardDialog();
    }
  }

  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomPadding: false, // 키보드 입력 시 fab 뜨는 거 방지
      appBar: AppBar(
        title: Text('알람 추가하기'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          search
              ? AddAlarmBySearch(onLectureSelect: onLectureSelect)
              : AddAlarmByList(onLectureSelect: onLectureSelect),
          if (loadingAd) AdLoadingIndicator(),
        ],
      ),
      bottomNavigationBar: AddModalBottomAppBar(
        actionIcon: search ? Icons.list : Icons.search,
        onActionPress: switchAddMethod,
      ),
      floatingActionButton: AddModalFloatingActionButton(
        disabled: loadingAd || lectureSelect.isEmpty,
        onPress: alarm.canGetReward ? onAddAlarm : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
