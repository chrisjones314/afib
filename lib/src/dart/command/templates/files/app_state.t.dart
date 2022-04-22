import 'package:afib/src/dart/command/af_source_template.dart';

class AFAppStateT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state_model_access.dart';
import 'package:meta/meta.dart';

@immutable
class [!af_app_namespace(upper)]State extends AFFlexibleState with [!af_app_namespace(upper)]StateModelAccess {

  [!af_app_namespace(upper)]State(Map<String, Object> models): super(models: models, create: [!af_app_namespace(upper)]State.create);

  factory [!af_app_namespace(upper)]State.create(Map<String, Object> models) {
      return [!af_app_namespace(upper)]State(models);
  }

  factory [!af_app_namespace(upper)]State.fromList(List<Object> toIntegrate) {
    final models = AFFlexibleState.integrate(AFFlexibleState.empty(), toIntegrate);
    return [!af_app_namespace(upper)]State(models);
  }

  @override
  AFFlexibleState createWith(Map<String, Object> models) {
    return [!af_app_namespace(upper)]State(models);
  }

  factory [!af_app_namespace(upper)]State.initial() {
    return [!af_app_namespace(upper)]State.fromList([
    ]);
  }
}''';

}



