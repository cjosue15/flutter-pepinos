import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class PriceRange extends StatefulWidget {
  final void Function(double) onChangedMin;
  final void Function(double) onChangedMax;
  final double initialValueMin;
  final double initialValueMax;

  PriceRange(
      {this.onChangedMin,
      this.onChangedMax,
      this.initialValueMax,
      this.initialValueMin});

  @override
  _PriceRangeState createState() => _PriceRangeState();
}

class _PriceRangeState extends State<PriceRange> {
  final _minController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: 'S/ ',
  );

  final _maxController = MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    leftSymbol: 'S/ ',
    initialValue: 0,
  );

  final _minFocusNode = FocusNode();

  final _maxFocusNode = FocusNode();

  String minErrorText;
  String maxErrorText;

  @override
  void initState() {
    super.initState();
    _minController.updateValue(widget.initialValueMin ?? 0);
    _maxController.updateValue(widget.initialValueMax ?? 0);

    _minFocusNode.addListener(() {
      final max = _maxController.numberValue;
      final min = _minController.numberValue;
      if (!_minFocusNode.hasFocus) {
        if (max != 0 && min > max) {
          minErrorText = 'Menor al máximo';
          _minController.updateValue(0);
        } else {
          minErrorText = null;
        }
        setState(() {});
      }
    });

    _maxFocusNode.addListener(() {
      final max = _maxController.numberValue;
      final min = _minController.numberValue;
      if (!_maxFocusNode.hasFocus) {
        if (min != 0 && max < min) {
          _maxController.updateValue(0);
          maxErrorText = 'Mayor al mínimo';
        } else {
          maxErrorText = null;
        }

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _minFocusNode?.dispose();
    _maxFocusNode?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 10.0),
            child: TextFormField(
              focusNode: _minFocusNode,
              controller: _minController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Min',
                errorText: minErrorText,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.onChangedMin(_minController.numberValue);
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 10.0),
            child: TextFormField(
              focusNode: _maxFocusNode,
              controller: _maxController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Max',
                errorText: maxErrorText,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.onChangedMax(_maxController.numberValue);
              },
            ),
          ),
        ),
      ],
    );
  }
}
