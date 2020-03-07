import 'package:flutter/material.dart';

class RadioWidget extends StatefulWidget {
  final String label;
  final List<String> values;
  final Function onSelect;

  const RadioWidget({this.label, this.values, this.onSelect});

  @override
  _RadioState createState() => _RadioState();
}

class _RadioState extends State<RadioWidget> {
  String selected;
  List<String> values;

  @override
  void initState() {
    super.initState();

    values = widget.values;
    selected = widget.values[0];
  }

  void onChanged(String value) {
    widget.onSelect(value);
    setState(() {
      selected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(widget.label),
        ...widget.values
            .expand((value) => [
                  Radio<String>(
                    value: value,
                    groupValue: selected,
                    onChanged: onChanged,
                  ),
                  Text(value),
                ])
            .toList(),
      ],
    );
  }
}
