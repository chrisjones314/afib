
import 'package:afib/src/dart/command/af_command.dart';
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/commands/af_generate_command.dart';

/// A step that generates an entire file, which can contain expandable
/// code segments within it.
class AFCreateFolderStep extends AFSourceGenerationStep {
  static const optionMustNotExist = 1;
  final int options;
  final List<String> projectPath;

  AFCreateFolderStep(this.projectPath, {this.options = 0});
  
  @override
  bool validateBefore(AFCommandContext ctx, AFGeneratedFiles files) {
    if(hasOption(optionMustNotExist)) {
      if(AFProjectPaths.projectFileExists(projectPath)) {
        ctx.o.writeErrorLine("The folder ${AFProjectPaths.relativePathFor(projectPath)} cannot already exist");
        return false;
      }
    }
    return true;
  }

  bool hasOption(int opt) {
    return (options & opt) != 0;
  }

  @override
  void execute(AFCommandContext ctx, AFGeneratedFiles files) {
    AFProjectPaths.createProjectFolder(projectPath);
    ctx.o.writeLine("Created folder ${AFProjectPaths.relativePathFor(projectPath)}");
  }
}


class AFCreateProjectFolderStep extends AFCreateFolderStep {
  AFCreateProjectFolderStep(List<String> projectPath): super(projectPath, options: AFCreateFolderStep.optionMustNotExist);

  @override
  void execute(AFCommandContext ctx, AFGeneratedFiles files) {
    super.execute(ctx, files);
    AFProjectPaths.setExtraParentFolder(projectPath);
  }

}
