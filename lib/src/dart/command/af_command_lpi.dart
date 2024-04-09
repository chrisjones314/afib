
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/utils/af_id.dart';

class AFCommandLPI {
  final AFLibraryProgrammingInterfaceID id;
  final AFCommandContext context;

  AFCommandLPI({
    required this.id,
    required this.context,
  });
}