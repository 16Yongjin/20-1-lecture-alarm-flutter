class Lecture {
  final String id;
  final String name;
  final String professor;
  final String time;
  final int index;

  Lecture({this.id, this.name, this.professor, this.time, this.index});

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      name: json['name'],
      professor: json['professor'],
      time: json['time'],
      index: json['index'],
    );
  }
}
