
import 'package:afib/src/dart/utils/af_id.dart';

/// Superclass of all AFib actions, which allows them
/// to be identified in testing.
/// 
/// By default, during testing, an AFib action will automatically
/// be identified by its class name.  However, if a single UI 
/// event spawns multiple actions of the same type, you can identify
/// and inspect them using the optional [wid] parameter in the constructor.
class AFActionWithKey {
  final AFID id;
  AFActionWithKey({this.id});
  
  String get key {
    final sb = StringBuffer();
    sb.write(runtimeType.toString());
    if(id != null) {
      sb.write("_");
      sb.write(id.code);
    }
    return sb.toString();
  }

}