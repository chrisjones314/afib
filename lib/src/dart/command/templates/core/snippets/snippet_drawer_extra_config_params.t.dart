
import 'package:afib/afib_command.dart';

class SnippetDrawerExtraConfigParamsT extends AFCoreSnippetSourceTemplate {

  const SnippetDrawerExtraConfigParamsT();

  String get template => 'createDefaultRouteParam: (ref, state) => ${AFSourceTemplate.insertMainTypeInsertion}RouteParam.create(),';

}
