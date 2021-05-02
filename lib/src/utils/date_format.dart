import 'package:intl/intl.dart';

/// This function recives date dd/MM/yyyy and return yyyy-MM-dd
String dateFormatToDatabase(String dateWithOutFormatInString) {
  DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  DateFormat _dateFormatToDatabase = DateFormat('yyyy-MM-dd');

  final date = _dateFormat.parse(dateWithOutFormatInString);

  return _dateFormatToDatabase.format(date);
}

String dateTimeToString(String date) {
  DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  DateFormat _dateFormatFromDatabase = DateFormat('yyyy-MM-dd');
  return _dateFormat.format(_dateFormatFromDatabase.parse(date));
}
