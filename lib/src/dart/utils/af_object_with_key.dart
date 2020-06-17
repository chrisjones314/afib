
import 'package:afib/src/dart/utils/af_id.dart';

/// Superclass that allows AFIb to identify objects using their type by default,
/// and an optional identifier descriminate.
/// 
/// In several cases, AFib will build a map to keep track of application provided
/// objects.  For example, it does so for objects at the root of the state, it does
/// so for ongoing 'listener' queries, and it does so in many test contexts.   By default,
/// AFib will assume that objects are uniquely identified by their class name (e.g. runtimeType.toString()).
/// However, there might be cases where an application wants to have afib track to distinct
/// objects with the same type.   Perhaps there are two listener queries of the same type, but for
/// different user.   In that case, you can differentiate them by deriving them from this
/// class, and passing them a distinguishing id in the constructor.
class AFObjectWithKey {
  final AFID id;

  /// Creates an object that is uniquely idenfified by its [Object.runtimeType], unless the optional
  /// [id] parameter is specified, in which case it is identified by the runtimeType plus the id.
  AFObjectWithKey({this.id});
  
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