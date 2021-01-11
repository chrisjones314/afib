
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/widgets.dart';

class AFBuilder<TBuildContext extends AFBuildContext> extends StatelessWidget {
  final TBuildContext parentContext;
  final AFWidgetBuilderDelegate<TBuildContext> builder;

  AFBuilder({
    @required this.parentContext,
    @required this.builder,
  });

  Widget build(BuildContext childContext) {
    final childContextAF = parentContext.container.createContext(
      childContext,
      parentContext.d,
      parentContext.s,
      parentContext.p,
      parentContext.paramWithChildren,
      parentContext.t,
      parentContext.container);
      
    return builder(childContextAF);
  }
}