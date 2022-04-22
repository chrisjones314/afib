
import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareWidgetParamsConstructorT extends AFSourceTemplate {
  final String template = '''{
    required AFScreenID screenId,
    required AFWidgetID wid,
    AFWidgetParamSource paramSource = AFWidgetParamSource.child,
}''';  
}
