import 'package:afib/src/dart/utils/af_exception.dart';
import 'package:afib/src/flutter/af_screen_map.dart';
import 'package:logging/logging.dart';
import 'package:afib/src/dart/utils/af_config.dart';

/// A class for finding accessing global utilities in AFib. 
/// 
/// Never use the globals to track or change state in your
/// application.  Globals contain debugging utilities (e.g. logging)
/// and configuration that is immutable after startup (e.g. configuration).
class AF {

  static bool postStartup = false;
  static final AFConfig gConfig = AFConfig();
  static Logger gLogger;
  static final AFScreenMap gScreenMap = AFScreenMap();

  static AFConfig get config {
    return gConfig;
  }

  static Logger get logger {
    return gLogger;
  }

  static AFScreenMap get screenMap {
    return gScreenMap;
  }

  /// Prepends "AF: " to a fine level log message.
  /// 
  /// Meant to be used only within the AF framework itself.  Apps should use
  /// AF.logger.fine(...)
  static void fine(String msg) {
    logger.fine("AF: " + msg);
  }

  /// Do not call this method, see AFApp.initialize instead.
  static void setLogger(Logger logger) {
    if(logger != null) {
      throw AFException("If you want to specify your own logger instance, pass it into AFApp.initialize");
    }
    AF.verifyNotImmutable();
    gLogger = logger;
  }

  /// Throws an exception if called after the startup process completes.  
  /// 
  /// Used to enforce immutability post startup.
  static void verifyNotImmutable() {
    if(postStartup) {
      throw AFException("You cannot perform this operation after startup is complete.  Put mutible state in the application state/store using actions");
    }
  }

  static void finishStartup() {
    postStartup = true;
  }
  


}