/// AFib code used in the bin/xxx_afib.dart command for your project.
/// 
/// This code is separated out because it cannot reference flutter UI,
/// or the command won't load properly.  When creating an AFib command,
/// you should import this library, not afib_flutter.
library;

export 'afib_uiid.dart'; // ok
export 'src/dart/command/af_args.dart'; // ok
export "src/dart/command/af_command.dart";
export "src/dart/command/af_command_enums.dart";
export 'src/dart/command/af_command_error.dart';
export 'src/dart/command/af_command_output.dart';
export 'src/dart/command/af_project_paths.dart';
export 'src/dart/command/af_source_template.dart';
export "src/dart/command/af_standard_commands.dart";
export 'src/dart/command/code_generation/af_code_buffer.dart';
export 'src/dart/command/code_generation/af_code_generator.dart';
export 'src/dart/command/code_generation/af_generated_file.dart';
export 'src/dart/command/commands/af_generate_command.dart';
export 'src/dart/command/commands/af_generate_command_command.dart';
export 'src/dart/command/commands/af_generate_override_command.dart';
export 'src/dart/command/commands/af_generate_query_command.dart';
export 'src/dart/command/commands/af_generate_state_command.dart';
export 'src/dart/command/commands/af_generate_ui_command.dart';
export 'src/dart/command/templates/core/files/queries.t.dart';
export 'src/dart/redux/state/models/af_standard_id_map_root.dart';
export 'src/dart/redux/state/models/af_time_state.dart';
export "src/dart/utils/af_config.dart";
export 'src/dart/utils/af_config_entries.dart';
export "src/dart/utils/af_dart_params.dart";
export 'src/dart/utils/af_document_id_generator.dart';
export "src/dart/utils/af_exception.dart"; // ok
export 'src/dart/utils/af_id.dart';
export "src/dart/command/af_command_lpi.dart";
export 'src/dart/utils/af_firestore_document.dart';
export 'src/flutter/test/af_test_utils.dart';
