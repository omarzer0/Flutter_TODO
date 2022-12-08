class Task {
  int _id;
  String _title;
  String _date;
  String _time;
  String _status;

  Task(this._id, this._title, this._date, this._time, this._status);

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get title => _title;

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  set title(String value) {
    _title = value;
  }

  static Task convertMapToTask(Map map) {
    return Task(
      map['id'],
      map['title'],
      map['date'],
      map['time'],
      map['status'],
    );
  }

}
