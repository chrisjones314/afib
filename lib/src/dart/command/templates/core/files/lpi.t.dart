import 'package:afib/src/dart/command/af_source_template.dart';

class LPIT extends AFCoreFileSourceTemplate {

  LPIT(): super(
    templateFileId: "lpi",
  );  

  String get template => '''
import 'package:afib/afib_flutter.dart';

class $insertMainType extends $insertMainParentType {

  $insertMainType(AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context): super(id, context);

  factory $insertMainType.create(AFLibraryProgrammingInterfaceID id, AFLibraryProgrammingInterfaceContext context) {
    return $insertMainType(id, context);
  }
}
''';

}






