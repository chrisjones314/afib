import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart/redux/state/af_theme_state.dart';

class AFUpdateThemeStateAction {
  final AFThemeState themes;
  AFUpdateThemeStateAction(this.themes);
}

/// This action is only meant to be used by prototype mode.
/// 
/// Apps do not need this, your theme will get rebuild anytime
/// the device characteristics or relevant app state changes.
@immutable
class AFOverrideThemeValueAction {
  final AFThemeID id;
  final dynamic value;
  AFOverrideThemeValueAction({
    required this.id,
    required this.value,
  });
}

/// This action rebuilds the entire theme state. 
/// 
/// This action should almost never be used, if you are using
/// it regularly, something is wrong.   It should be used only if
/// 1. Your fundamental theme state depends on some setting in your application state (for example, a compact mode setting)
/// 2. The user has just changed that value in the application state (e.g. from the settings are of the app)
/// In that case, the theme state won't refresh automatically.   Instead, you need to dispatch this action 
/// or more likely call [AFBuildContext.dispatchRebuildThemeState].
@immutable
class AFRebuildThemeState {

}

class AFRebuildFunctionalThemes {
  
}