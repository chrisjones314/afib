import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class AppStateT extends AFCoreFileSourceTemplate {

  AppStateT(): super(
    templateFileId: "app_state",
  );

  @override
  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/state/${insertAppNamespace}_state_model_access.dart';
import 'package:meta/meta.dart';

@immutable
class ${insertAppNamespaceUpper}State extends AFComponentState with ${insertAppNamespaceUpper}StateModelAccess {

  ${insertAppNamespaceUpper}State(Map<String, Object> models): super(models: models, create: ${insertAppNamespaceUpper}State.create);

  factory ${insertAppNamespaceUpper}State.create(Map<String, Object> models) {
      return ${insertAppNamespaceUpper}State(models);
  }

  factory ${insertAppNamespaceUpper}State.fromList(List<Object> toIntegrate) {
    final models = AFComponentState.integrate(AFComponentState.empty(), toIntegrate);
    return ${insertAppNamespaceUpper}State(models);
  }

  @override
  AFComponentState createWith(Map<String, Object> models) {
    return ${insertAppNamespaceUpper}State(models);
  }

  factory ${insertAppNamespaceUpper}State.initial() {
    // ignore: prefer_const_literals_to_create_immutables
    return ${insertAppNamespaceUpper}State.fromList([
    ]);
  }
}''';

}



