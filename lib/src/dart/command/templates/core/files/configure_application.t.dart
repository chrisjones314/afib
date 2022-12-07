
import 'package:afib/src/dart/command/af_source_template.dart';

class ConfigureApplicationT extends AFCoreFileSourceTemplate {

  ConfigureApplicationT(): super(
    templateFileId: "configure_application",
  );
  

  String get template => '''
import 'package:afib/afib_command.dart';

void configureApplication(AFConfig config) {
    
}
''';

}





