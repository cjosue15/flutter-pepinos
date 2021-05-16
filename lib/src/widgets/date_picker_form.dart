import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DatePickerForm extends StatefulWidget {
  final String labelText;
  final String Function(String) validator;
  final void Function(String) onSaved;
  final void Function(String) onDateChanged;
  final DateTime firstDate;
  final DateTime initialDate;

  DatePickerForm({
    this.labelText = 'Fecha',
    this.validator,
    this.firstDate,
    this.onSaved,
    @required this.onDateChanged,
    this.initialDate,
  });

  @override
  _DatePickerFormState createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<DatePickerForm> {
  TextEditingController textController = TextEditingController();
  DateTime _selectedDate;
  DateFormat _dateFormat;
  // DateFormat _dateFormatToDataBase;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    // initializeDateFormatting('es', null).then((value) {
    //   print(DateFormat.yMMMMd('es').format(DateTime.now()));
    // });
    _dateFormat = DateFormat('dd/MM/yyyy');
    // return string for database
    // _dateFormatToDataBase = DateFormat('yyyy-MM-dd');
    // _dateFormat = DateFormat.yMd('ar');
    _selectedDate = widget.initialDate ?? DateTime.now();
    textController.text =
        widget.initialDate != null ? _dateFormat.format(_selectedDate) : '';
  }

  @override
  void dispose() {
    super.dispose();
    textController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selectDate(context);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.labelText,
      ),
      // onChanged: widget.onDateChanged
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime date =
        widget.firstDate != null && _selectedDate.isBefore(widget.firstDate)
            ? widget.firstDate
            : _selectedDate;
    final DateTime picked = await showDatePicker(
      locale: const Locale("es", "PE"),
      context: context,
      initialDate: date,
      firstDate: widget.firstDate ?? DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != widget.initialDate) {
      _selectedDate = picked;
      textController.text = _dateFormat.format(picked);
      widget.onDateChanged(_dateFormat.format(picked));
    }
  }
}

// import 'package:flutter/material.dart';
// //
//
//                 // Container(
//     margin: EdgeInsets.only(bottom: 20.0),
//     child: _getDatePickerEnabled()),
//                 MyTextFieldDatePicker(
//   labelText: "Date",
//   prefixIcon: Icon(Icons.date_range),
//   suffixIcon: Icon(Icons.arrow_drop_down),
//   lastDate: DateTime.now().add(Duration(days: 366)),
//   firstDate: DateTime.now(),
//   initialDate: DateTime.now().add(Duration(days: 1)),
//   onDateChanged: (selectedDate) {
//     // Do something with the selected date
//   },
// ),

// class MyTextFieldDatePicker extends StatefulWidget {
//   final ValueChanged<DateTime> onDateChanged;
//   final DateTime initialDate;
//   final DateTime firstDate;
//   final DateTime lastDate;
//   // final DateFormat dateFormat;
//   final FocusNode focusNode;
//   final String labelText;
//   final Icon prefixIcon;
//   final Icon suffixIcon;

//   MyTextFieldDatePicker({
//     Key key,
//     this.labelText,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.focusNode,
//     // this.dateFormat,
//     @required this.lastDate,
//     @required this.firstDate,
//     @required this.initialDate,
//     @required this.onDateChanged,
//   })  : assert(initialDate != null),
//         assert(firstDate != null),
//         assert(lastDate != null),
//         assert(!initialDate.isBefore(firstDate),
//             'initialDate must be on or after firstDate'),
//         assert(!initialDate.isAfter(lastDate),
//             'initialDate must be on or before lastDate'),
//         assert(!firstDate.isAfter(lastDate),
//             'lastDate must be on or after firstDate'),
//         assert(onDateChanged != null, 'onDateChanged must not be null'),
//         super(key: key);

//   @override
//   _MyTextFieldDatePicker createState() => _MyTextFieldDatePicker();
// }

// class _MyTextFieldDatePicker extends State<MyTextFieldDatePicker> {
//   TextEditingController _controllerDate;
//   // DateFormat _dateFormat;
//   DateTime _selectedDate;

//   @override
//   void initState() {
//     super.initState();

//     // if (widget.dateFormat != null) {
//     //   _dateFormat = widget.dateFormat;
//     // } else {
//     //   _dateFormat = DateFormat.MMMEd();
//     // }

//     _selectedDate = widget.initialDate;

//     _controllerDate = TextEditingController();
//     _controllerDate.text = _selectedDate.toIso8601String();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       focusNode: widget.focusNode,
//       controller: _controllerDate,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(),
//         prefixIcon: widget.prefixIcon,
//         suffixIcon: widget.suffixIcon,
//         labelText: widget.labelText,
//       ),
//       onTap: () => _selectDate(context),
//       readOnly: true,
//     );
//   }

//   @override
//   void dispose() {
//     _controllerDate.dispose();
//     super.dispose();
//   }

//   Future<Null> _selectDate(BuildContext context) async {
//     final DateTime pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: widget.firstDate,
//       lastDate: widget.lastDate,
//     );

//     if (pickedDate != null && pickedDate != _selectedDate) {
//       _selectedDate = pickedDate;
//       // _controllerDate.text = _dateFormat.format(_selectedDate);
//       _controllerDate.text = _selectedDate.toIso8601String();
//       widget.onDateChanged(_selectedDate);
//     }

//     // if (widget.focusNode != null) {
//     //   widget.focusNode.nextFocus();
//     // }
//   }
// }
