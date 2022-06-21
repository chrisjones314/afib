import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareCreateWidgetPrototypeT extends AFSourceTemplate {
  final String template = '''
  var prototype = definitions.define[!af_control_type_suffix]Prototype(
    id: [!af_app_namespace(upper)]PrototypeID.[!af_screen_test_id],
    models: [!af_app_namespace(upper)]TestDataID.[!af_full_test_data_id],
    param: [!af_screen_name]RouteParam.create(id: [!af_app_namespace(upper)]WidgetID.[!af_screen_id]),
    render: (screenId, wid) {
      return [!af_screen_name](
        screenId: screenId, 
        wid: wid
      );
    },
  );
  ''';
}

