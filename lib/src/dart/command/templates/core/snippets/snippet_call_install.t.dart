import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetCallInstallT extends AFSourceTemplate {
  static const insertPackageCode = AFSourceTemplateInsertion("package_code");
  static const insertInstallKind = AFSourceTemplateInsertion("install_kind");

  String get template => '  ${insertPackageCode}Install$insertInstallKind(context);';
}
