import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String labelTextField;
  final TextInputType keyboardTextField;
  final Function validator;
  final TextEditingController controller;
  final String initValue;
  bool obscureText = false;

  InputField(
      {this.labelTextField,
      this.keyboardTextField,
      this.validator,
      this.controller,
      this.initValue,
      this.obscureText});

  @override
  _InputField createState() => _InputField();
}

/* Create a text field widget with pre-defined label text name and type of keyboard
*  initialized through constructor
* */
class _InputField extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: TextFormField(
          validator: widget.validator,
          initialValue: widget.initValue,
          decoration: InputDecoration(
              labelText: widget.labelTextField,
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0)),
          keyboardType: widget.keyboardTextField,
          controller: widget.controller,
          obscureText: widget.obscureText,
        ));
  }
}