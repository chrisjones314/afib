import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/project_styles/app-eval-demo/files/model_example_start_here.t.dart';

class ModelReferencedUsersRootT extends ModelExampleStartHereT {
  
  ModelReferencedUsersRootT({
    List<String>? templatePath,
    AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: "model_referenced_users_root",
    embeddedInsertions: embeddedInsertions,
  );  

  factory ModelReferencedUsersRootT.example() {
    return ModelReferencedUsersRootT(embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      AFSourceTemplate.insertExtraImportsInsertion: '''
import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/referenced_user.dart';
''',
      AFSourceTemplate.insertAdditionalMethodsInsertion: '''
factory ReferencedUsersRoot.initialState() {
  return ReferencedUsersRoot(
    users: const <String, ReferencedUser>{},
  );
}

ReferencedUser? findById(String userId) {
  return users[userId];
}

ReferencedUsersRoot reviseUser(ReferencedUser user) {
  // make a copy of the map.
  final revisedUsers = Map<String, ReferencedUser>.from(users);

  // update the user within it.
  revisedUsers[user.id] = user;

  // return a copy of this object with the revised map.
  return copyWith(users: revisedUsers);
}
''',
    }));
  }
}