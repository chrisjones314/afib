

import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/dart/utils/afib_d.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

enum AFTimeStateUpdateSpecificity {
  day,
  hour,
  minute,
  second,
  millisecond
}

enum AFTimeZone {
  utc,
  local
}

class AFTimeState {
  static const missingNowError = "You must start a AFTimeUpdateListenerQuery before attempting to access the time.";
  static const updateSpecificityOrder = [
    AFTimeStateUpdateSpecificity.day,
    AFTimeStateUpdateSpecificity.hour,
    AFTimeStateUpdateSpecificity.minute,
    AFTimeStateUpdateSpecificity.second,
    AFTimeStateUpdateSpecificity.millisecond,
  ];
  final DateTime? actualNow;
  final DateTime? pauseTime;
  final Duration simulatedOffset;
  final Duration pushUpdateFrequency;
  final AFTimeStateUpdateSpecificity pushUpdateSpecificity;
  final AFTimeZone timeZone;

  AFTimeState({
    required this.actualNow,
    required this.simulatedOffset,
    required this.pushUpdateFrequency,
    required this.pushUpdateSpecificity,
    required this.pauseTime,
    required this.timeZone,
  });

  bool get isInitialized {
    return actualNow != null;
  }

  factory AFTimeState.initialState() {
    return AFTimeState(actualNow: null, pauseTime: null, simulatedOffset: Duration(milliseconds: 0), pushUpdateFrequency: Duration(days: 1), pushUpdateSpecificity: AFTimeStateUpdateSpecificity.second, timeZone: AFTimeZone.local);
  }

  factory AFTimeState.createNow({ Duration updateFrequency = const Duration(milliseconds: 250),  AFTimeStateUpdateSpecificity updateSpecificity = AFTimeStateUpdateSpecificity.second }) {
    return AFTimeState.createBaseTime(
      actualNow: DateTime.now(),
      simulatedOffset: Duration(days: 0),
      updateFrequency: updateFrequency,
      updateSpecificity: updateSpecificity,
      timeZone: AFTimeZone.local,
    );   
  }


  factory AFTimeState.createBaseTime({
    required DateTime actualNow,
    Duration simulatedOffset = Duration.zero,
    required Duration updateFrequency,
    required AFTimeStateUpdateSpecificity updateSpecificity,
    required AFTimeZone timeZone,
  }) {
    return AFTimeState(
      actualNow: actualNow,
      simulatedOffset: simulatedOffset,
      pushUpdateFrequency: updateFrequency,
      pushUpdateSpecificity: updateSpecificity,
      pauseTime: null,
      timeZone: timeZone,
    );
  }

  factory AFTimeState.createLocalFromAbsoluteDay({
    required int absoluteDay,
    required AFTimeZone sourceTimeZone,
    AFTimeStateUpdateSpecificity updateSpecificity = AFTimeStateUpdateSpecificity.second,
  }) {
    final offset = Duration(days: absoluteDay);
    return _createLocalFromOffset(offset: offset, sourceTimeZone: sourceTimeZone, updateSpecificity: updateSpecificity);
  }

  factory AFTimeState.createLocalFromAbsoluteMinute({
    required int absoluteMinute,
    required AFTimeZone sourceTimeZone,
    AFTimeStateUpdateSpecificity updateSpecificity = AFTimeStateUpdateSpecificity.second,
  }) {
    final offset = Duration(minutes: absoluteMinute);
    return _createLocalFromOffset(offset: offset, sourceTimeZone: sourceTimeZone, updateSpecificity: updateSpecificity);
  }

  factory AFTimeState.createLocalFromAbsoluteSecond({
    required int absoluteSecond,
    required AFTimeZone sourceTimeZone,
    AFTimeStateUpdateSpecificity updateSpecificity = AFTimeStateUpdateSpecificity.second,
  }) {
    final offset = Duration(seconds: absoluteSecond);
    return _createLocalFromOffset(offset: offset, sourceTimeZone: sourceTimeZone, updateSpecificity: updateSpecificity);
  }

  factory AFTimeState.createLocalFromAbsoluteDayHourMinute({
    required int absoluteDay,
    required int hourInDay,
    required int minuteInHour,
    required AFTimeZone sourceTimeZone,
    AFTimeStateUpdateSpecificity updateSpecificity = AFTimeStateUpdateSpecificity.second,
  }) {
    final offset = Duration(days: absoluteDay, hours: hourInDay, minutes: minuteInHour);
    return _createLocalFromOffset(offset: offset, sourceTimeZone: sourceTimeZone, updateSpecificity: updateSpecificity);
  }

  factory AFTimeState.createLocalFromAbsoluteDayMinute({
    required int absoluteDay,
    required int minuteInDay,
    required AFTimeZone sourceTimeZone,
    AFTimeStateUpdateSpecificity updateSpecificity = AFTimeStateUpdateSpecificity.second,
  }) {
    final offset = Duration(days: absoluteDay, minutes: minuteInDay);
    return _createLocalFromOffset(offset: offset, sourceTimeZone: sourceTimeZone, updateSpecificity: updateSpecificity);
  }

  factory AFTimeState.createLocalFromAbsoluteMonth({
    required int absoluteMonth,
    required AFTimeZone sourceTimeZone,
    AFTimeStateUpdateSpecificity updateSpecificity = AFTimeStateUpdateSpecificity.second,
  }) {
    final abd = AFibD.config.absoluteBaseDate;
    final yearOffset = absoluteMonth ~/ 12;
    final monthOffset = absoluteMonth % 12;
    final actualNow = DateTime(abd.year+yearOffset, monthOffset, 1);
    return AFTimeState.createBaseTime(
      actualNow: actualNow,
      updateFrequency: Duration.zero,
      updateSpecificity: updateSpecificity,
      timeZone: AFTimeZone.local,
    );
  }


  static AFTimeState _createLocalFromOffset({
    required Duration offset,
    required AFTimeZone sourceTimeZone,
    required AFTimeStateUpdateSpecificity updateSpecificity
  }) {
    final abd = AFibD.config.absoluteBaseDate;
    var actualNow = abd.add(offset);
    if(sourceTimeZone == AFTimeZone.utc) {
      actualNow = actualNow.add(abd.timeZoneOffset);
    }
    
    return AFTimeState.createBaseTime(
      actualNow: actualNow,
      updateFrequency: Duration.zero,
      updateSpecificity: updateSpecificity,
      timeZone: AFTimeZone.local,
    );

  }

  factory AFTimeState.createForDay({
    required AFTimeState baseTime,
    required int absoluteDay,
    int minuteInDay = 0
  }) {
    return baseTime.reviseForAbsoluteDay(
      absoluteDay: absoluteDay, minuteInDay: minuteInDay
    );
  }

  Duration get timeZoneOffset {
    return AFibD.config.absoluteBaseDate.timeZoneOffset;
  }

  AFTimeState reviseForTimeOnDay(
    int hour,
    int minute,
  ) {
    final ct = currentPushTime;
    final revisedNow = DateTime(ct.year, ct.month, ct.day, hour, minute);
    return copyWith(actualNow: revisedNow);
  }
  

  AFTimeState reviseForDateTime(DateTime revisedNow) {
    return copyWith(actualNow: revisedNow);
  }

  AFTimeState reviseToAbsoluteTime(DateTime revisedNow) {
    final actualNow = DateTime.now();
    final offset = revisedNow.difference(actualNow);
    return copyWith(
      actualNow: actualNow,
      simulatedOffset: offset,
    );
  }

  int absoluteMinuteLocalToUTC(int absoluteMinuteLocal) {
    final offset = currentPushTime.timeZoneOffset.inMinutes;
    return absoluteMinuteLocal - offset;
  }

  int absoluteSecondLocalToUTC(int absoluteSecondLocal) {
    final offset = currentPushTime.timeZoneOffset.inSeconds;
    return absoluteSecondLocal - offset;
  }

  AFTimeState reviseForAbsoluteDay({
    required int absoluteDay,
    int minuteInDay = 0
  }) {
  
    // an absolute day is just that, absolute, so it doesn't make sense to 
    // adjust it by the simulated offset.
    final actualNow = absoluteBaseDate.add(Duration(days: absoluteDay, minutes: minuteInDay));
    return copyWith(
      actualNow: actualNow
    );
  }

  DateTime get absoluteBaseDate {
    return DateTime(AFibD.config.absoluteBaseYear, DateTime.january, 1);
  }

  AFTimeState reviseToUTC() {
    return copyWith(timeZone: AFTimeZone.utc);
  }

  AFTimeState reviseToLocal() {
    return copyWith(timeZone: AFTimeZone.local);
  }

  AFTimeState reviseSubtractDays(int days) {
    return this.reviseAdjustOffset(Duration(days: -days));
  }

  AFTimeState reviseAddDays(int days) {
    return this.reviseAdjustOffset(Duration(days: days));
  }

  AFTimeState reviseSubtractMinutes(int minutes) {
    return this.reviseAdjustOffset(Duration(minutes: -minutes));
  }

  AFTimeState reviseAddMinutes(int minutes) {
    return this.reviseAdjustOffset(Duration(minutes: minutes));
  }

  AFTimeState reviseSubtractHours(int hours) {
    return this.reviseAdjustOffset(Duration(hours: -hours));
  }

  AFTimeState reviseAddHours(int hours) {
    return this.reviseAdjustOffset(Duration(hours: hours));
  }

  AFTimeState reviseSubtractSeconds(int seconds) {
    return this.reviseAdjustOffset(Duration(seconds: -seconds));
  }

  AFTimeState reviseAddSeconds(int seconds) {
    return this.reviseAdjustOffset(Duration(seconds: seconds));
  }

  bool get isUTC {
    return timeZone == AFTimeZone.utc;
  }

  int get year {
    return currentPushTime.year;
  }

  int get month {
    return currentPushTime.month;
  }

  int get day {
    return currentPushTime.day;
  }

  int get hour {
    return currentPushTime.hour;
  }

  int get minute {
    return currentPushTime.minute;
  }

  int get second {
    return currentPushTime.second;
  }

  static Duration parseDuration(String text) {
    final tokens = text.split(" ");
    var amounts = [0,0,0,0,0];
    var suffixes = ["d", "h", "m", "s", "ms"];
    for(final token in tokens) {
      final suffix = suffixes.firstWhereOrNull((suffix) => token.endsWith(suffix));
      if(suffix == null) {
        throw FormatException("Token $token does not have a recognized suffix");
      }
      final idxSuffix = suffixes.indexOf(suffix);
      final amountStr = token.substring(0, token.length-suffix.length);
      final amount = int.tryParse(amountStr);
      if(amount == null) {
        throw FormatException("Invalid amount $amountStr for token $token");
      }
      amounts[idxSuffix] = amount;
    }

    return Duration(
      days: amounts[0],
      hours: amounts[1],
      minutes: amounts[2],
      seconds: amounts[3],
      milliseconds: amounts[4]
    );
  }

  String format(DateFormat format) {
    return format.format(currentPushTime);
  }

  AFTimeState reviseForActualNow(DateTime actualNow) {
    return copyWith(actualNow: actualNow);
  }

  AFTimeState reviseForPause() {
    return copyWith(pauseTime: DateTime.now());
  }

  AFTimeState reviseAdjustOffset(Duration offset) {
    return copyWith(simulatedOffset: simulatedOffset + offset);
  }


  AFTimeState reviseForPlay() {
    final pt = pauseTime;
    if(pt == null) {
      return this;
    }

    final now = DateTime.now();
    final sincePause = now.difference(pt);
    final revisedOffset = simulatedOffset - sincePause;

    return copyWith(
      clearPauseTime: true,
      simulatedOffset: revisedOffset,
      actualNow: now
    );
  }

  AFTimeState reviseForDesiredNow(DateTime actualNow, DateTime desiredTime) {

    return copyWith(actualNow: actualNow,
        simulatedOffset: desiredTime.difference(actualNow));
  }

  AFTimeState reviseSpecificity(AFTimeStateUpdateSpecificity specificity) {
    if(this.pushUpdateSpecificity == specificity) {
      return this;
    }
    return copyWith(updateSpecificity: specificity);
  }

  int get absoluteSecond {
    return absoluteDuration.inSeconds;
  }

  int get absoluteMinute {
    return absoluteDuration.inMinutes;
  }

  int get absoluteHour {
    return absoluteDuration.inHours;
  }

  int get absoluteDay  {
    return absoluteDuration.inDays;
  }

  int get absoluteMonth {
    final ct = currentPushTime;
    return (absoluteYear * 12) + (ct.month - 1);
  }

  int get absoluteYear {
    final ct = currentPushTime;
    final abd = absoluteBaseDate;
    return ct.year - abd.year;
  }

  Duration get absoluteDuration {
    final abd = absoluteBaseDate;
    final dur = currentPushTime.difference(abd);
    return dur;
  }

  AFTimeState copyWith({
    final DateTime? absoluteBaseDate,
    final DateTime? actualNow,
    final Duration? simulatedOffset,
    final Duration? updateFrequency,
    final AFTimeStateUpdateSpecificity? updateSpecificity,
    final DateTime? pauseTime,
    final AFTimeZone? timeZone,
    bool clearPauseTime = false
  }) {
    var pt = pauseTime ?? this.pauseTime;
    if(clearPauseTime) {
      pt = null;
    }

    return AFTimeState(
      actualNow: actualNow ?? this.actualNow,
      simulatedOffset: simulatedOffset ?? this.simulatedOffset,
      pushUpdateFrequency: updateFrequency ?? this.pushUpdateFrequency,
      pushUpdateSpecificity: updateSpecificity ?? this.pushUpdateSpecificity,
      pauseTime: pt,
      timeZone: timeZone ?? this.timeZone,
    );
  }

  static AFTimeStateUpdateSpecificity leastSpecificityOf(AFTimeStateUpdateSpecificity left, AFTimeStateUpdateSpecificity right) {
    final idxL = updateSpecificityOrder.indexOf(left);
    final idxR = updateSpecificityOrder.indexOf(right);
    if(idxL < idxR) {
      return left;
    } 
    return right;
  }

  bool operator==(Object other) {
    if(other is! AFTimeState) {
      return false;
    }

    if(other.timeZone != this.timeZone) {
      throw AFException("Do not compare two time states with different time zones");
    }

    final leastSpecificity = leastSpecificityOf(pushUpdateSpecificity, other.pushUpdateSpecificity);


    if(leastSpecificity == AFTimeStateUpdateSpecificity.second) {
      return this.absoluteSecond == other.absoluteSecond;
    } else if(leastSpecificity == AFTimeStateUpdateSpecificity.minute) {
      return this.absoluteMinute == other.absoluteMinute;
    } else if(leastSpecificity == AFTimeStateUpdateSpecificity.hour) {
      return this.absoluteHour == other.absoluteHour;
    } else if(leastSpecificity == AFTimeStateUpdateSpecificity.day) {
      return this.absoluteDay == other.absoluteDay;
    }
    return actualNow == other.actualNow;
  }

  int get hashCode {
    return currentPushTime.hashCode;
  }

  String toString() {
    if(actualNow == null) {
      return missingNowError;
    }
    final cur = currentPushTime;
    return cur.toString();
  }

  AFTimeState get currentPullTimeState {
    return copyWith(actualNow: DateTime.now());
  }

  int get milliInDay {
    var result = secondInDay * Duration.millisecondsPerSecond;
    result += DateTime.now().millisecond;
    return result;
  }

  int get secondInDay {
    final now = currentPullTime;
    final result = (now.hour*Duration.secondsPerMinute*Duration.minutesPerHour) + (now.minute*Duration.secondsPerMinute) + now.second;
    return result;
  }

  DateTime get currentPullTime {
    final ts = currentPullTimeState;
    return ts.currentPushTime;
  }


  AFTimeState get currentPushTimeState {
    return this;
  }

  DateTime get currentPushTime {
    final an = actualNow;
    if(an == null) {
      throw AFException(missingNowError);
    }

    var totalOffset = simulatedOffset;
    if(isUTC) {
      totalOffset -= an.timeZoneOffset;
    }
    return an.add(totalOffset);
  }
}