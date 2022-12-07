
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/example/start_here/files/model_example_start_here.t.dart';

class ModelReferencedUserT extends ModelExampleStartHereT {
  
  ModelReferencedUserT({
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_referenced_user",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelReferencedUserT.example() {
    return ModelReferencedUserT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: AFSourceTemplate.empty,
      AFSourceTemplate.insertMemberVariablesInsertion: '''
// Note: even if have integer ID values on the server, you should
// convert them to String ids within AFib.   Doing so allows you to
// use String test ids, which are vastly clearer in debugging contexts.
final String id;
final String firstName;
final String lastName;
final String email;
''',
      AFSourceTemplate.insertConstructorParamsInsertion: '''{
required this.id,
required this.firstName,
required this.lastName,
required this.email,
}''',
      AFSourceTemplate.insertCopyWithParamsInsertion: '''{
String? id,
String? firstName,
String? lastName,
String? email,
}''',
    AFSourceTemplate.insertCopyWithCallInsertion: '''      
id: id ?? this.id,
firstName: firstName ?? this.firstName,
lastName: lastName ?? this.lastName,
email: email ?? this.email,
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: AFSourceTemplate.empty,
    }));
  }
}