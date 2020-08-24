

import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';
import 'package:afib/src/dart/command/generator_code/af_id_code_generator.dart';
import 'package:afib/src/dart/command/generator_steps/af_file_generator_step.dart';

class AFIDGenerator extends AFSourceGenerator {
  static const cmdKey = "id";
  static const validKinds = ['screen', 'widget', 'query'];
  
  AFIDGenerator() : super(AFConfigEntries.afNamespace, cmdKey, "Generate an id in the ${AFProjectPaths.relativePathFor(AFProjectPaths.idPath)} file.") {
    final genAfib = AFFileGeneratorStep(AFProjectPaths.idPath);
    addStep(genAfib);
  }

  /// Validates that all the steps are valid.
  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
    if(!files.exists(AFProjectPaths.idPath)) {
      return super.validateBefore(ctx, files);
    }

    /// otherwise, this should be an explicit generate command
    if(ctx.args.count != 3) {
      ctx.output.writeErrorLine("Expected arguments: generate id id_kind id_constant");
      return false;
    }

    final kind = ctx.args.second;
    if(!validKinds.contains(kind)) {
      ctx.output.writeErrorLine("identifer kind $kind must be one of $validKinds");
      return false;
    }

    final insert = AFInsertionPoint.create(kind);
    final file = files.fileFor(ctx.templates, AFProjectPaths.idPath);    
    if(!file.containsInsertionPoint(insert)) {
      ctx.output.writeErrorLine("Expected insertion point $insert in ${AFProjectPaths.relativePathFor(AFProjectPaths.idPath)}");
    }


    return true;
  }

  void execute(AFCommandContext ctx, AFGeneratedFiles files) {
    if(!files.exists(AFProjectPaths.idPath)) {
      super.execute(ctx, files);
      return;
    }

    final kind = ctx.args.second;
    final id = ctx.args.third;
    final file = files.fileFor(ctx.templates, AFProjectPaths.idPath);    
    final insert = AFInsertionPoint.create(kind);
    file.appendBeforeInsertionPoint(ctx, insert, AFIDCodeGenerator(kind, id));
  }

}