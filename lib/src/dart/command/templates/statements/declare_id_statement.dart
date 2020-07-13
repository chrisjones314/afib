

import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';

class DeclareIDStatementT extends AFStatementSourceTemplate {

  DeclareIDStatementT(): super(AFConfigEntries.afNamespace, "declare_id_identifier");

  @override
  String get template {
    return 'static final AFRP(id_identifier) = AFAFRP(id_identifier_kind)ID("AFRP(id_identifier_snake)");';
  }
}
