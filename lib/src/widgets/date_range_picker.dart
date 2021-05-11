import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatefulWidget {
  final String labelText;
  final bool hasInitialDate;
  final String Function(String) validator;
  final void Function(String) onSaved;
  final void Function(DateTimeRange) onDateChanged;
  final DateTimeRange initialDateRange;

  DateRangePicker({
    this.labelText = 'Rango de fechas',
    this.validator,
    this.onSaved,
    this.hasInitialDate = false,
    @required this.onDateChanged,
    this.initialDateRange,
  });

  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  TextEditingController textController = TextEditingController();
  DateTimeRange _selectedDateRange;
  DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _dateFormat = DateFormat('dd/MM/yyyy');
    _selectedDateRange = !widget.hasInitialDate
        ? null
        : widget.initialDateRange ??
            DateTimeRange(
              start: DateTime.now(),
              end: (DateTime.now()).add(
                Duration(days: 7),
              ),
            );
    textController.text = widget.hasInitialDate
        ? '${_dateFormat.format(_selectedDateRange.start)} - ${_dateFormat.format(_selectedDateRange.end)}'
        : '';
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
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange picked = await showDateRangePicker(
      locale: const Locale("es", "PE"),
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      _selectedDateRange = picked;
      textController.text =
          '${_dateFormat.format(picked.start)} - ${_dateFormat.format(picked.end)}';
      widget.onDateChanged(DateTimeRange(start: picked.start, end: picked.end));
    }
  }
}
