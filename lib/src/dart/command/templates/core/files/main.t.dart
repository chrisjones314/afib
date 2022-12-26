import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class MainT extends AFFileSourceTemplate {
  static const insertBeforeMain = AFSourceTemplateInsertion("before_main");
  static const insertMainImpl = AFSourceTemplateInsertion("main_impl");
  static const insertAfterMain = AFSourceTemplateInsertion("after_main");

  MainT({
    required String templateFileId,
    required List<String> templateFolder,
    Object? mainImpl,
    Object? beforeMain,
    Object? afterMain,
    Object? insertExtraImports,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: AFSourceTemplateInsertions(insertions: {
      insertBeforeMain: beforeMain ?? AFSourceTemplate.empty,
      insertAfterMain: afterMain ?? AFSourceTemplate.empty,
      AFSourceTemplate.insertExtraImportsInsertion: insertExtraImports ?? AFSourceTemplate.empty,
      insertMainImpl: mainImpl ?? '''
    final paramsDart = createDartParams();
    afMainApp(
      paramsDart: paramsDart, 
      installBase: installBase, 
      installBaseLibrary: installBaseLibrary, 
      installCoreApp: installCoreApp, 
      installCoreLibrary: installCoreLibrary, 
      installTest: installTest
    );
''',
    })    
  );  

  factory MainT.core() {
    return MainT(
      templateFileId: "main",
      templateFolder: AFProjectPaths.pathGenerateCoreFiles,
    );
  }

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/initialization/create_dart_params.dart';
import 'package:$insertPackagePath/initialization/install/install_core_app.dart';
import 'package:$insertPackagePath/initialization/install/install_base.dart';
import 'package:$insertPackagePath/initialization/install/install_base_library.dart';
import 'package:$insertPackagePath/initialization/install/install_test.dart';
$insertExtraImports

void main() {  
  afMainWrapper(() {
    $insertBeforeMain
    $insertMainImpl
    $insertAfterMain
  });
}''';

}





