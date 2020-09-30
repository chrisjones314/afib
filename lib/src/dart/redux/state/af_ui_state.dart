
import 'package:afib/src/dart/utils/af_id.dart';
import 'package:meta/meta.dart';
import 'package:afib/src/dart//utils/af_object_with_key.dart';

/// An object which keeps track of a message to be displayed to the user,
/// usually associated with a specific widget.
@immutable
class AFUIWidgetMessage {
  static const success = 0;
  static const error = 1;
  static const warning = 2;
  static const status = 3;

  /// The text of the message
  final String message;

  /// The message type.  
  /// 
  /// By default, this is one of AFUIWidgetMessage.error, AFUIWidgetMessage.warning, or AFUIWidgetMessage.success,
  /// but you can also use your own values.
  final int messageType;
  final AFWidgetID wid;

  AFUIWidgetMessage({this.message, this.messageType, this.wid});
}

/// A utility object which can be placed at the root of your application
/// state to track common error and message state.  
/// 
/// You don't need to use this, although it will integrate with certain
/// AFib error
@immutable
class AFUIState extends AFObjectWithKey {
  /// Indicates the app is currently loading data from somewhere.
  static const kIsLoading = 1;

  /// Indicates the app is idle.
  static const kIsNotLoading = 2;
  
  /// An integer value intended to indicate whether you are waiting on information
  /// from somewhere.  
  /// 
  /// By default, using [AFUIState.kIsLoading] and [AFUIState.kIsNotLoading],
  /// but you can also add your own values.
  final int loadingState;

  /// A primary message that should be displayed to the user.
  final AFUIWidgetMessage primaryMessage;

  /// A list of messages associated with widgets on the current screen.
  final List<AFUIWidgetMessage> messages;

  AFUIState({this.loadingState, this.primaryMessage, this.messages});

  bool get isLoading {
    return loadingState == kIsLoading;
  }

  String get primaryText {
    if(primaryMessage == null) {
      return "";
    }
    return primaryMessage.message;
  }

  factory AFUIState.loading() {
    return AFUIState(loadingState: kIsLoading, messages: <AFUIWidgetMessage>[]);
  }

  factory AFUIState.notLoading() {
    return AFUIState(loadingState: kIsNotLoading, messages: <AFUIWidgetMessage>[]);
  }

  factory AFUIState.loadingWithStatus(String status) {
    return AFUIState.withPrimaryMessage(kIsLoading, status, AFUIWidgetMessage.status);
  }

  factory AFUIState.notLoadingWithError(String err) {
    return AFUIState.withPrimaryMessage(kIsNotLoading, err, AFUIWidgetMessage.error);
  }

  factory AFUIState.withPrimaryMessage(int loading, String message, int messageType) {
    return AFUIState(loadingState: kIsLoading, primaryMessage: AFUIWidgetMessage(message: message, messageType: AFUIWidgetMessage.error));
  }

}