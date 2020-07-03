
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:logging/logging.dart';
import 'package:afib/src/dart/utils/af_config.dart';

class AFibD<AppState> {
    static final AFConfig _afConfig = AFConfig();
    static Logger _afLogger;
    static Logger logInternal;

    static void initialize<AppState>(AFDartParams p) {
      Logger logger = p?.logger;
      if(logger == null) {
        logger = Logger("AF");
      }
      AFibD.setLogger(logger);

      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((LogRecord rec) {
        print('${rec.level.name}: ${rec.time}: ${rec.message}');
      });  

      // the params are null when we run the bin/afib.dart command, which doesn't have any configuration information.
      if(p != null) {
        // first do the separate initialization that just says what environment it is, since this
        p.initAfib(AFibD.config);
        if(p.forceEnv != null) {
          AFibD.config.setValue(AFConfigEntries.environment, p.forceEnv);
        }
        p.initAppConfig(AFibD.config);
        final String env = AFibD.config.environment;
        if(env == AFConfigEntryEnvironment.debug) {
          p.initDebugConfig(AFibD.config);
        } else if(env == AFConfigEntryEnvironment.production) {
          p.initProductionConfig(AFibD.config);
        } else if(env == AFConfigEntryEnvironment.prototype) {
          p.initPrototypeConfig(AFibD.config);
        } else if(env == AFConfigEntryEnvironment.testStore) {
          p.initTestConfig(AFibD.config);
        }

        bool verbose = AFibD.config.enableInternalLogging;
        if(verbose != null && verbose) {
          AFibD.logInternal = AFibD._afLogger;
        }

        AFibD.logInternal?.fine("Environment: " + AFibD.config.environment);
      }

  }

  /// Do not call this method, see AFApp.initialize instead.
  static void setLogger(Logger logger) {
    _afLogger = logger;
  }

  /// Contains configuration data for the app, specific to test, production, etc.
  static AFConfig get config {
    return _afConfig;
  }

  /// A logger for use throughout the app.
  static Logger get logger {
    return _afLogger;
  }
  /// Prepends "AF: " to a fine level log message.
  /// 
  /// Meant to be used only within the AF framework itself.  Apps should use
  /// AF.logger.fine(...)
  static void fine(String msg) {
    _afLogger.fine("AF: " + msg);
  }

  static void debug(String msg) {
    _afLogger.fine("AF: " + msg);
  }

}