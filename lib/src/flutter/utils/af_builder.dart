import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/ui/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/widgets.dart';

class AFBuilder<TBuildContext extends AFBuildContext> extends StatelessWidget {
  final TBuildContext parentContext;
  final AFWidgetBuilderDelegate<TBuildContext> builder;

  AFBuilder({
    required this.parentContext,
    required this.builder,
  });

  Widget build(BuildContext childContext) {
    final standard = AFStandardBuildContextData(
      screenId: parentContext.standard.screenId,
      context: childContext,
      dispatcher: parentContext.d,
      container: parentContext.container,
      themes: parentContext.standard.themes
    );
    final childContextAF = parentContext.container?.createContext(
      standard,
      parentContext.s,
      parentContext.p,
      parentContext.children,
      parentContext.t,
    );
      
    return builder(childContextAF as TBuildContext);
  }
}