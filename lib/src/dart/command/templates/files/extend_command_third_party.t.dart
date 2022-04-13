import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendCommandThirdPartyT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';

// You can use this function to add your own commands, or to
// import AFib-aware third party commands.
void extendCommandThirdParty(AFCommandThirdPartyExtensionContext definitions) {
}
''';

}
