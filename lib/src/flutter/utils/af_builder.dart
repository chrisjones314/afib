
import 'package:afib/afib_flutter.dart';
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/widgets.dart';

class AFBuilder<TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam, TTheme extends AFConceptualTheme> extends StatelessWidget {
  final AFBuildContext<TData, TRouteParam, TTheme> parentContext;
  final AFWidgetBuilderDelegate<TData, TRouteParam, TTheme> builder;

  AFBuilder({
    @required this.parentContext,
    @required this.builder
  });

  Widget build(BuildContext childContext) {
    final childContextAF = AFBuildContext<TData, TRouteParam, TTheme>(
      childContext,
      parentContext.d,
      parentContext.s,
      parentContext.p,
      parentContext.paramWithChildren,
      parentContext.t);
      
    return builder(childContextAF);
  }
}