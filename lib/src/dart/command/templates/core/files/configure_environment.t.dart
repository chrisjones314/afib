
import 'package:afib/src/dart/command/af_source_template.dart';

class ConfigureEnvironmentT extends AFCoreFileSourceTemplate {
  static const insertEnvironmentName = AFSourceTemplateInsertion("environment_name");
  static const insertConfigureBody = AFSourceTemplateInsertion("configure_body");

  ConfigureEnvironmentT(): super(
    templateFileId: "configure_environment",
  );  

  String get template => '''
import 'package:afib/afib_command.dart';

void configure$insertEnvironmentName(AFConfig config) {   
   $insertConfigureBody
}
''';

}





