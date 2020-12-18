
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
    this.id,
    this.value,
  });
}
