import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/eval_demo/files/model_example_start_here.t.dart';

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
static const notSpecified = "__not_specified__";
final String userId;
final String token;
final String storedEmail;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.userId,
required this.token,
required this.storedEmail,
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
String? userId,
String? token,
String? storedEmail,
}''',
      AFSourceTemplate.insertCopyWithCallInsertion: '''      
userId: userId ?? this.userId,
token: token ?? this.token,
storedEmail: storedEmail ?? this.storedEmail,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
bool get isSignedIn => userId != notSpecified;

String get validStoredEmailOrEmpty {
  if(storedEmail == notSpecified) {
    return "";
  } else {
    return storedEmail;
  }
}

static UserCredentialRoot createNotSignedIn() {
  return UserCredentialRoot.initialState();
}

factory UserCredentialRoot.initialState() {
  // Note: Using flag values here, rather than null, works better with copyWith,
  // which in its default syntax is not good at setting values to null.
  return UserCredentialRoot(
    userId: notSpecified,
    token: notSpecified,
    storedEmail: notSpecified
  );
}
''',
    }));
  }
}