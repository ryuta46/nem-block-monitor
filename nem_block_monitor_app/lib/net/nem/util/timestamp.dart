import 'package:intl/intl.dart';

class Timestamp {
  static DateTime get nemesisDate {
    return DateTime.utc(2015, 3, 29, 0, 6, 25);
  }
  static DateTime dateFromNemesis(int seconds) {
    return nemesisDate.add(Duration(seconds: seconds)).toLocal();
  }
  static String dateStringFromNemesis(int seconds) {
    final format = DateFormat('yyyy/MM/dd HH:mm:ss');
    return format.format(dateFromNemesis(seconds));
  }

}