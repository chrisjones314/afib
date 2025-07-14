/// A future holding place for constants specifying langauge IDs.
/// 
/// When I looked at the time, it did not seem that Flutter itself provided constants for known language ids,
/// or even for common language IDs.   Maybe there is a good reason for that, or maybe I missed it, but it seems
/// to me like something that should be standardized.  So, this is a holding places for that future standardization.
library;

import 'dart:ui';


class AFUILocaleID {
  static const universal = Locale.fromSubtags(languageCode: "und");
  static const englishUS = Locale.fromSubtags(languageCode: 'en', countryCode: 'us');
  static const spanish = Locale.fromSubtags(languageCode: 'sp');
}
