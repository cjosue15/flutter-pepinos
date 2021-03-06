import 'package:intl/intl.dart';

/// This function recives date dd/MM/yyyy and return yyyy-MM-dd
String dateFormatToDatabase(String dateWithOutFormatInString) {
  DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  DateFormat _dateFormatToDatabase = DateFormat('yyyy-MM-dd');

  final date = _dateFormat.parse(dateWithOutFormatInString);

  return _dateFormatToDatabase.format(date);
}

/// This function recives date yyyy-MM-dd and return dd/MM/yyyy
String dateFormFromDatabase(String date) {
  DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  DateFormat _dateFormatFromDatabase = DateFormat('yyyy-MM-dd');
  return _dateFormat.format(_dateFormatFromDatabase.parse(date));
}

String dateTimeToString({DateTime date, DateFormat dateFormat}) {
  DateFormat _dateFormat = dateFormat ?? DateFormat('dd/MM/yyyy');
  return _dateFormat.format(date);
}

DateTime dateStringToDateTime({String date, DateFormat dateFormat}) {
  DateFormat _dateFormat = dateFormat ?? DateFormat('dd/MM/yyyy');
  return _dateFormat.parse(date);
}
