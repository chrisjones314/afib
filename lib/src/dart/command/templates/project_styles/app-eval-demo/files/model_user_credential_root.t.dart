import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/model.t.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_example_start_here.t.dart';

class ModelUserCredentialRootT extends ModelExampleStartHereT {
  
  ModelUserCredentialRootT({
    List<String>? templatePath,
    super.embeddedInsertions,
  }): super(
    templateFileId: "model_user_credential_root",
  );  

  factory ModelUserCredentialRootT.example() {
    return ModelUserCredentialRootT(embeddedInsertions: const AFSourceTemplateInsertions(insertions: {
      ModelT.insertInitialState: '''
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
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
static const notSpecified = "__not_specified__";

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
''',
    }));
  }
}