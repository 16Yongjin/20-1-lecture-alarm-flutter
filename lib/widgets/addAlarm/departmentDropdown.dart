import 'package:flutter/material.dart';
import 'package:lecture_alarm_20_1/data/courses.dart';

class DepartmentDropdown extends StatelessWidget {
  final String courseSelect;
  final String departmentSelect;
  final Function onChange;

  const DepartmentDropdown(
      {this.departmentSelect, this.onChange, this.courseSelect});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: departmentSelect,
      onChanged: onChange,
      items: Courses.courses[courseSelect].map((List<String> value) {
        return DropdownMenuItem<String>(value: value[1], child: Text(value[0]));
      }).toList(),
    );
  }
}
