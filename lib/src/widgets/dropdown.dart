import 'package:flutter/material.dart';

class AppDropdownInput<T> extends StatelessWidget {
  final String hintText;
  final List<T> options;
  final T value;
  final String Function(T) getLabel;
  final String Function(T) validator;
  final void Function(T) onChanged;

  AppDropdownInput({
    this.hintText = 'Please select an Option',
    this.options = const [],
    this.getLabel,
    this.value,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(builder: (FormFieldState<T> state) {
      return InputDecorator(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        isEmpty: value == null || value == '',
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(border: InputBorder.none),
            value: value,
            onChanged: onChanged,
            validator: validator,
            items: options.map((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(getLabel(value)),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
