

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A control similar to Flutter's [TextField], which hides
/// the details of the text controller and makes it easier to
/// manage the text edit in a redux-y way.
class AFTextField extends StatefulWidget {
  final Key key;
  final String text;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final bool autofocus;
  final TextAlign textAlign;
  final InputDecoration decoration;

  AFTextField({
    this.key,
    this.text,
    this.onChanged,
    this.obscureText,
    this.autofocus,
    this.textAlign,
    this.decoration
    });
 
   @override
  _AFTextFieldState createState() => _AFTextFieldState();

}


class _AFTextFieldState extends State<AFTextField> {

  final textController = TextEditingController();


  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(textController.text != widget.text) {
      textController.text = widget.text;
    }
    return TextField(
      key: widget.key,
      controller: textController,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      textAlign: widget.textAlign,
      decoration: widget.decoration,
    );
  }


}