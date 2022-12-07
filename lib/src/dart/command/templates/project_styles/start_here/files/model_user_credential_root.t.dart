import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/start_here/files/model_example_start_here.t.dart';

class ModelUserCredentialRootT extends ModelExampleStartHereT {
  
  ModelUserCredentialRootT({
    List<String>? templatePath,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_user_credential_root",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelUserCredentialRootT.example() {
    return ModelUserCredentialRootT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
      AFSourceTemplate.insertMemberVariablesInsertion: '''
static const notSignedIn = "__not_signed_in__";
final String userId;
final String token;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.userId,
required this.token,
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
String? userId,
String? token,
}''',
      AFSourceTemplate.insertCopyWithCallInsertion: '''      
userId: userId ?? this.userId,
token: token ?? this.token,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
bool get isSignedIn => userId != notSignedIn;

factory UserCredentialRoot.initialState() {
  // Note: Using flag values here, rather than null, works better with copyWith,
  // which in its default syntax is not good at setting values to null.
  return UserCredentialRoot(
    userId: notSignedIn,
    token: notSignedIn,
  );
}
''',
    }));
  }
}