
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_declare_model_accessor.t.dart';

class SnippetDeclareActiveUserAccessorT extends SnippetDeclareModelAccessorT {
  static const insertExtraStateViewMethods = AFSourceTemplateInsertion("extra_state_view_methods");

  SnippetDeclareActiveUserAccessorT(): super(
    templateFolder: AFProjectPaths.pathGenerateStarterSigninSnippets,
    embeddedInsertions: null,
  );

  @override
  List<String> get extraImports {
    return <String>[
"import 'package:${AFSourceTemplate.insertPackagePathInsertion}/state/models/user.dart';"
    ];
  }

  @override
  String get template {
    final result = StringBuffer(super.template);
    result.write('''

  User get activeUser {
    final active = users.findById(userCredential.userId);
    if(active == null) {
      throw AFException("No active user!?");
    }    
    return active;
  }
''');

    return result.toString();
  }
}

