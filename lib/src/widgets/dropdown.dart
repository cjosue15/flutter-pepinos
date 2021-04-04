import 'package:flutter/material.dart';

class AppDropdownInput<T> extends StatelessWidget {
  final String hintText;
  final List<T> options;
  final T value;
  final String Function(T) validator;
  final void Function(T) onChanged;

  AppDropdownInput({
    this.hintText = 'Please select an Option',
    this.options = const [],
    this.value,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: hintText,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      value: value,
      validator: validator,
      onChanged: onChanged,
      items: options
          .map((dynamic item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.text, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
    );
  }
}

// return FormField<T>(builder: (FormFieldState<T> state) {
//   return InputDecorator(
//     decoration: InputDecoration(
//       // errorText: 'asda',
//       contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
//       labelText: hintText,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
//     ),
//     isEmpty: value == null || value == '',
//     child: DropdownButtonHideUnderline(
//       child: DropdownButtonFormField<T>(
//         decoration: InputDecoration(border: InputBorder.none),
//         value: value,
//         onChanged: onChanged,
//         validator: validator,
//         items: options.map((T value) {
//           print(options);
//           return DropdownMenuItem<T>(
//             value: value,
//             child: Text(getLabel(value)),
//           );
//         }).toList(),
//       ),
//     ),
//   );
// }

//  DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 labelText: _currentItem,
//                 hintText: 'Option',
//                 border: OutlineInputBorder(),
//               ),
//               value: _currentItem,
//               validator: (value) => value == null ? 'Ingrese un invernadero' : null,
//               items: _currencies
//                   .map((label) => DropdownMenuItem(
//                         child: Text(label),
//                         value: label,
//                       ))
//                   .toList(),
//               onChanged: (value) {
//                 setState(() => _currentItem = value);
//               },
//             )
