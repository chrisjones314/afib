import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/af_standard_configs.dart';
import 'package:afib/src/flutter/utils/af_log_printer.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class AFibD<AppState> {
    static final AFConfig _afConfig = AFConfig();
    static final configEntries = <AFConfigurationItem>[];
    static final standardSizes = <String, AFFormFactorSize>{};
    static final libraries = <AFLibraryID>[];
    static final logs = <String, Logger>{};
    static final codeGenerationOverrides = <AFSourceTemplateInsertion, Object>{};
    static String? cwd;
    
    /// Register an entry in the configuration file.
    static void registerConfigEntry(AFConfigurationItem entry) {
      configEntries.add(entry);
    }

    static void registerLibrary(AFLibraryID id) {
      if(!libraries.contains(id)) {
        libraries.add(id);
      }
    }

    static void setCurrentWorkingDirectory(String current) {
      cwd = current;
    }

    static void establishCurrentWorkingDirectory(String proposed) {
      if(proposed.isNotEmpty) {
        cwd = proposed;
      }
    }

    static String get currentWorkingDirectory {
      return cwd ?? Directory.current.path;
    }

    static AFLibraryID? findLibraryWithPrefix(String prefix) {
      return libraries.firstWhereOrNull((id) => id.codeId == prefix);
    }

    static AFConfigurationItem? findConfigEntry(String name) {
      final result = configEntries.firstWhereOrNull((e) => e.name == name);
      return result;
    }

    static void registerGlobals() {
      registerStandardSizes();
      registerDefaultConfigEntries();
    }

    static void registerStandardSizes() {
      registerStandardSize(AFFormFactorSize.sizePhoneStandard);
      registerStandardSize(AFFormFactorSize.sizePhoneLarge);
      registerStandardSize(AFFormFactorSize.sizeTabletSmall);
      registerStandardSize(AFFormFactorSize.sizeTabletStandard);
      registerStandardSize(AFFormFactorSize.sizeTabletLarge);
    }

    static void registerStandardSize(AFFormFactorSize size) {
      standardSizes[size.identifier] = size;
    }

    static AFFormFactorSize? findSize(String identifier) {
      return standardSizes[identifier];
    }

    static void registerDefaultConfigEntries() {
      registerConfigEntry(AFConfigEntries.appNamespace);
      registerConfigEntry(AFConfigEntries.packageName);
      registerConfigEntry(AFConfigEntries.baseSimulatedLatency);
      registerConfigEntry(AFConfigEntries.strictTranslationMode);
      registerConfigEntry(AFConfigEntries.forceDarkMode);
      registerConfigEntry(AFConfigEntries.enableGenerateAugment);
      registerConfigEntry(AFConfigEntries.absoluteBaseYear);
      registerConfigEntry(AFConfigEntries.environment);
      registerConfigEntry(AFConfigEntries.testsEnabled);
      registerConfigEntry(AFConfigEntries.testsRecent);
      registerConfigEntry(AFConfigEntries.logsEnabled);
      registerConfigEntry(AFConfigEntries.testSize);
      registerConfigEntry(AFConfigEntries.testOrientation);
      registerConfigEntry(AFConfigEntries.widgetTesterContext);
      registerConfigEntry(AFConfigEntries.generateBeginnerComments);
      registerConfigEntry(AFConfigEntries.generatedFileHeader);
      registerConfigEntry(AFConfigEntries.generateUIPrototypes);

    }

    static void initialize<AppState>(AFDartParams? p) {
      //Logger.root.level = Level.ALL;
      //Logger.root.onRecord.listen((LogRecord rec) {
      //  print('${rec.level.name}: ${rec.time}: ${rec.message}');
      //});  

      // the params are null when we run the bin/afib.dart command, which doesn't have any configuration information.
      if(p != null) {
        // first do the separate initialization that just says what environment it is, since this
        config.establishDefaults();
        p.configureAfib(AFibD.config);
        if(p.forceEnv != null) {
          AFibD.config.setValue(AFConfigEntryEnvironment.optionName, p.forceEnv);
        }
        p.configureAppConfig(AFibD.config);
        final env = AFibD.config.environment;
        if(env == AFEnvironment.debug) {
          p.configureDebugConfig(AFibD.config);
        } else if(env == AFEnvironment.production) {
          p.configureProductionConfig(AFibD.config);
        } else if(AFibD.config.isPrototypeEnvironment) {
          p.condfigurePrototypeConfig(AFibD.config);
        } else if(env == AFEnvironment.test) {
          p.configureTestConfig(AFibD.config);
        }
      }

      var logsEnabled = AFibD.config.logsEnabled;
      for(final area in logsEnabled) {
        if(area == AFConfigEntryLogArea.commentOption) {
          break;
        }
        final logger = Logger(printer: AFLogPrinter(area));
        logs[area] = logger;
      }

      final configLog = AFibD.logConfigAF;
      if(configLog != null) {
        for(final item in AFibD.configEntries) {
          configLog.d("${item.name} = ${AFibD.config.valueFor(item)}");
        }
      }

  }

  static Logger? log(String area) {
    final all = logs[AFConfigEntryLogArea.all];
    if(all != null) {
      return all;
    }
    return logs[area]; 
  }

  static Logger? get logUIApp {
    return log(AFConfigEntryLogArea.ui);
  }

  static Logger? get logQueryApp {
    return log(AFConfigEntryLogArea.query);
  }

  static Logger? get logQueryAF {
    return log(AFConfigEntryLogArea.afQuery);
  }

  static Logger? get logRouteAF {
    return log(AFConfigEntryLogArea.afRoute);
  }

  static Logger? get logStateAF {
    return log(AFConfigEntryLogArea.afState);
  }

  static Logger? get logUIAF {
    return log(AFConfigEntryLogArea.afUI);
  }

  static Logger? get logConfigAF {
    return log(AFConfigEntryLogArea.afConfig);
  }

  static Logger? get logTestAF {
    return log(AFConfigEntryLogArea.afTest);
  }

  static Logger? get logThemeAF {
    return log(AFConfigEntryLogArea.afTheme);
  }

  /// Contains configuration data for the app, specific to test, production, etc.
  static AFConfig get config {
    return _afConfig;
  }
}