
import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/command/commands/af_config_command.dart';
import 'package:afib/src/dart/utils/af_config_entries.dart';
import 'package:afib/src/dart/utils/af_dart_params.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/flutter/utils/af_log_printer.dart';
import 'package:logger/logger.dart';

class AFibD<AppState> {
    static final AFConfig _afConfig = AFConfig();
    static Logger logAppQuery;
    static Logger logAppRender;
    static Logger logAppTest;
    static Logger logQuery;
    static Logger logConfig;
    static Logger logTest;

    /// Logger which is non-null if we should log changes to routing.
    static Logger logRoute;

    static _createLogger(String area, List<String> areas) {
      if(areas.contains(area) || areas.contains(AFConfigEntryLogArea.all)) {
        return Logger(
            printer: AFLogPrinter(area),
        );
      }
      return null;
    }

    static void initialize<AppState>(AFDartParams p) {
      //Logger.root.level = Level.ALL;
      //Logger.root.onRecord.listen((LogRecord rec) {
      //  print('${rec.level.name}: ${rec.time}: ${rec.message}');
      //});  

      // the params are null when we run the bin/afib.dart command, which doesn't have any configuration information.
      if(p != null) {
        // first do the separate initialization that just says what environment it is, since this
        p.initAfib(AFibD.config);
        if(p.forceEnv != null) {
          AFibD.config.setValue(AFConfigEntries.environment, p.forceEnv);
        }
        p.initAppConfig(AFibD.config);
        final env = AFibD.config.environment;
        if(env == AFEnvironment.debug) {
          p.initDebugConfig(AFibD.config);
        } else if(env == AFEnvironment.production) {
          p.initProductionConfig(AFibD.config);
        } else if(env == AFEnvironment.prototype) {
          p.initPrototypeConfig(AFibD.config);
        } else if(env == AFEnvironment.test) {
          p.initTestConfig(AFibD.config);
        }

      }

      final logAreas = AFibD.config.logAreas;    
      AFibD.logAppQuery = _createLogger(AFConfigEntryLogArea.appQuery, logAreas);
      AFibD.logAppRender= _createLogger(AFConfigEntryLogArea.appRender, logAreas);
      AFibD.logAppTest  = _createLogger(AFConfigEntryLogArea.appTest, logAreas);
      AFibD.logQuery   = _createLogger(AFConfigEntryLogArea.query, logAreas);
      AFibD.logConfig  = _createLogger(AFConfigEntryLogArea.config, logAreas);
      AFibD.logTest    = _createLogger(AFConfigEntryLogArea.test, logAreas);
      AFibD.logRoute   = _createLogger(AFConfigEntryLogArea.route, logAreas);
      AFibD.logConfig?.i("Environment: ${AFibD.config.environment}");

  }



  /// Contains configuration data for the app, specific to test, production, etc.
  static AFConfig get config {
    return _afConfig;
  }
}