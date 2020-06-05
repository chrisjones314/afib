
import 'package:afib/src/dart/utils/af_id.dart';

class AFActionWithKey {
  final AFID wid;
  AFActionWithKey({this.wid});
  
  String get key {
    final sb = StringBuffer();
    if(wid != null) {
      sb.write(wid.code);
    }
    sb.write("_");
    sb.write(runtimeType.toString());
    return sb.toString();
  }

}