import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A control similar to Flutter's [TextField], which hides
/// the details of the text controller and makes it easier to
/// manage the text edit in a redux-y way.
class AFTextField extends StatefulWidget {
  final Key? key;
  final String? text;
  final ValueChanged<String>? onChanged;
  final bool? obscureText;
  final bool? autofocus;
  final TextAlign? textAlign;
  final InputDecoration? decoration;
  final bool? autocorrect;

  AFTextField({
    this.key,
    this.text,
    this.onChanged,
    this.obscureText,
    this.autofocus,
    this.autocorrect,
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
    final widText = widget.text;
    if(textController.text != widText && widText != null) {
      textController.text = widText;
    }
    return TextField(
      key: Key("${widget.key}_text_field"),
      controller: textController,
      onChanged: widget.onChanged,
      obscureText: widget.obscureText ?? false,
      autofocus: widget.autofocus ?? false,
      textAlign: widget.textAlign ?? TextAlign.start,
      decoration: widget.decoration,
    );
  }


}