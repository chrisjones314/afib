
import 'package:afib/src/dart/utils/af_route_param.dart';
import 'package:afib/src/flutter/screen/af_connected_screen.dart';
import 'package:afib/src/flutter/utils/af_typedefs_flutter.dart';
import 'package:flutter/widgets.dart';

class AFBuilder<TData extends AFStoreConnectorData, TRouteParam extends AFRouteParam> extends StatelessWidget {
  final AFBuildContext<TData, TRouteParam> parentContext;
  final AFWidgetBuilderDelegate<TData, TRouteParam> builder;

  AFBuilder({
    @required this.parentContext,
    @required this.builder
  });

  Widget build(BuildContext childContext) {
    final childContextAF = AFBuildContext<TData, TRouteParam>(
      childContext,
      parentContext.d,
      parentContext.s,
      parentContext.p);
      
    return builder(childContextAF);
  }
}