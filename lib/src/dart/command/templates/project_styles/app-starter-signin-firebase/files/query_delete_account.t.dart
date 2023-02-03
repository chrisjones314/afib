

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/queries.t.dart';

class QueryDeleteAccountT extends SimpleQueryT {
  QueryDeleteAccountT({
    required Object insertExtraImports,
    required Object insertStartImpl,
    required Object insertFinishImpl,
    required Object insertAdditionalMethods,
  }): super(
    templateFileId: "query_delete_account",
    templateFolder: AFProjectPaths.pathGenerateStarterSigninFirebaseFiles,
    insertExtraImports: insertExtraImports,
    insertStartImpl: insertStartImpl,
    insertFinishImpl: insertFinishImpl,
    insertAdditionalMethods: insertAdditionalMethods,
  );

  factory QueryDeleteAccountT.example() {
    return QueryDeleteAccountT(
      insertExtraImports: '''
import 'package:afib_signin/afsi_flutter.dart';
import 'package:afib_signin/afsi_id.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
''',
      insertStartImpl: '''
user.delete().then((result) {
  context.onSuccess(AFUnused.unused);    
}, onError: (err) {
  context.onError(AFQueryError.createMessage(err.toString()));
});
''',
      insertFinishImpl: AFSourceTemplate.empty,
      insertAdditionalMethods: '''
@override
void finishAsyncWithError(AFFinishQueryErrorContext context) {    
  final lpi = context.accessLPI<AFSIManipulateStateLPI>(AFSILibraryProgrammingInterfaceID.manipulateState);
  lpi.updateProcessDeleteAcountScreenStatus(status: AFSISigninStatus.error, message: context.e.message);
}
'''
    );
  }



  
}