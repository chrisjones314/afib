
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/define_core.t.dart';

class SigninStarterDefineCoreT {

  static DefineCoreT example() {
    return DefineCoreT(
      templateFileId: "define_core",
      templateFolder: AFProjectPaths.pathGenerateStarterSigninFiles,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:afib_signin/afsi_flutter.dart';
''',
        DefineCoreT.insertAddStateViewAugmentor: '''
context.addStateViewAugmentationHandler<AFSIDefaultStateView>((context, result) { 
  final ${AFSourceTemplate.insertAppNamespaceInsertion}State = context.accessComponentState<${AFSourceTemplate.insertAppNamespaceInsertion.upper}State>();
  result.add(${AFSourceTemplate.insertAppNamespaceInsertion}State.userCredential);
  result.add(${AFSourceTemplate.insertAppNamespaceInsertion}State.users);
});
'''
      })
    );
  }


}