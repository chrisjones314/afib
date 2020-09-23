
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class AFLogPrinter extends LogPrinter {
  final DateFormat formatter = DateFormat('hh:mm:ss.');
  final String area;

  AFLogPrinter(this.area);

  @override
  List<String> log(LogEvent event) {
    final result = StringBuffer("[");
    result.write(getTime());
    result.write(", $area]: ");
    result.write(event.message);
        
    return [result.toString()];
  }

  String _threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';
    return '00$n';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  String getTime() {
    var now = DateTime.now();
    var h = _twoDigits(now.hour);
    var min = _twoDigits(now.minute);
    var sec = _twoDigits(now.second);
    var ms = _threeDigits(now.millisecond);
    return '$h:$min:$sec.$ms';
  }

}