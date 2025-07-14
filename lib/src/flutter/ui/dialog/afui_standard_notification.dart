
import 'package:afib/afib_flutter.dart';
import 'package:flutter/material.dart';

class AFUIStandardNotification extends StatelessWidget {
  final VoidCallback? onAction;
  final Color colorBackground;
  final Color colorForeground;
  final AFRichTextBuilder title;
  final AFRichTextBuilder? body;
  final AFRichTextBuilder? actionText;

  const AFUIStandardNotification({
    super.key, 
    required this.onAction, 
    required this.body, 
    required this.title,
    required this.colorBackground,
    required this.colorForeground,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    
    final flatButtonStyle = OutlinedButton.styleFrom(
      foregroundColor: colorForeground,
      side: BorderSide(color: colorForeground),
    );

    var trailing;
    final at = actionText;
    if(at != null) {
      trailing = OutlinedButton(
                style: flatButtonStyle,
                child: at.toRichText(),
                onPressed: () {
                  final onD = onAction;
                  if (onD != null) onD();
                }     

      ); 
    }

    return Card(
      color: colorBackground,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 15.0),
          child: ListTile(          
            title: title.toRichText(),
            subtitle: body?.toRichText(),
            trailing: trailing),
        ),
      ),
    );
  }
}