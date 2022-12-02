import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareCreateScreenPrototypeT extends AFSourceTemplate {
  final String pushParams;
  DeclareCreateScreenPrototypeT({
    required this.pushParams
  });

  factory DeclareCreateScreenPrototypeT.noPushParams() {
    return DeclareCreateScreenPrototypeT(pushParams: '');
  }


  String get template {
    return '''
  var prototype = context.define[!af_control_type_suffix]Prototype(
    id: [!af_app_namespace(upper)]PrototypeID.[!af_screen_test_id],
    stateView: [!af_app_namespace(upper)]TestDataID.[!af_full_test_data_id],
    navigate: [!af_screen_name].navigatePush($pushParams),
  );
  ''';
  }
}
