
import 'package:afib/src/dart/command/templates/statements/declare_create_screen_prototype.t.dart';

class DeclareCreateScreenPrototypeStartupT extends DeclareCreateScreenPrototypeT {
  DeclareCreateScreenPrototypeStartupT({
    required String pushParams,
  }): super(pushParams: pushParams);

  factory DeclareCreateScreenPrototypeStartupT.forStartup() {
    return DeclareCreateScreenPrototypeStartupT(pushParams: 'clickCount: 3');
  }
} 