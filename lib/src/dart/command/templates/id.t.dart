

import 'package:afib/src/dart/command/af_template_source.dart';

class IdentifierT extends AFTemplateSource {

  IdentifierT(): super(AFTemplateSourceCreationRule.updateInPlace);

  @override
  String template() {
    return '''
AfibReplacementPoint(import_afib_dart)

// IDs will often be created for you as part of the generate command.
// If you need to generate additional ids, you can do so by hand, or by
// using the sub-command 'generate id widget my_widget_id', 
// 'generate id screen screen_id', etc.

class AFibReplacementPoint(UppercaseAppAbbrev)ScreenID {
  // Screen IDs
  // AFibInsertionPoint(ScreenID)
}

class AFibReplacementPoint(UppercaseAppAbbrev)WidgetID {
  // Widget IDs
  static final waitingCircle     = AFWidgetID("waiting_circle");
  static final loginButton       = AFWidgetID("login_button");
  static final loginButtonWelcome       = AFWidgetID("login_button_welcome");
  static final signUpButton      = AFWidgetID("signup_button");
  static final whatIsDFLink      = AFWidgetID("what_is_df");
  static final emailEdit         = AFWidgetID("email_edit");
  static final passwordEdit      = AFWidgetID("password_edit");
  static final signoutTile       = AFWidgetID("signout_tile");
  static final backText          = AFWidgetID("back_text");
  static final searchIcon        = AFWidgetID("search_icon");
  static final backIcon          = AFWidgetID("back_icon");
  static final loginErrorText    = AFWidgetID("login_error_text");
  // AFibInsertionPoint(WidgetID)
}

class AFibReplacementPoint(UppercaseAppAbbrev)QueryID {
  static final waitForRebuildStats = AFQueryID("wait_for_rebuild_stats");  
  // AFibInsertionPoint(QueryID)
}
''';
  }
}

