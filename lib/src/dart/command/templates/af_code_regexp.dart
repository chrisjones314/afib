

class AFCodeRegExp {
  static final startMixinStateAccess = RegExp(r"mixin\s*.*StateModelAccess\s+on\s+AFStateModelAccess\s+{");
  static final startShortcutsClass = RegExp(r"class\s+.*StateTestShortcuts\s+{");
  static final startDefineUIProtoypesFunction = RegExp(r'void\s+defineUIPrototypes\(AFUIPrototypeDefinitionContext\s+context\)\s+{');
  static final startPrototypeID = RegExp(r"class\s+.*PrototypeID\s+extends\s+AFPrototypeID\s+{");
  static final startDefineScreenTestFunction = RegExp(r"void\s+define.*Prototypes\(AFUIPrototypeDefinitionContext\s+context\)\s+{");
  static final startScreenMap = RegExp(r"void\s+defineScreens\(AFCoreDefinitionContext\s+context\)\s+{");
  static final startDefineStateClass = RegExp(r"class\s+.*State\s+extends\s+AFComponentState\s+with\s+.*StateModelAccess\s+{");
  static final startReturnInitialState = RegExp(r"return\s+.*State.fromList\(\s*\[");
  static final startExtendLibraryBase = RegExp(r"void\s+installBaseLibrary\(AFBaseExtensionContext\s+context\)\s+{");
  static final startExtendLibraryCommand = RegExp(r"void\s+installCommandLibrary\(AFCommandLibraryExtensionContext\s+context\)\s+{");
  static final startExtendLibraryUI = RegExp(r"void\s+installCoreLibrary\(AF.*?LibraryExtensionContext\s+context\)\s+{");
  static final startDefineThemes = RegExp(r"void\s+defineFunctionalThemes\(AFCoreDefinitionContext\s+context\)\s+{");
  static final startDefineScreens = RegExp(r"void\s+defineScreens\(AFCoreDefinitionContext\s+context\)\s+{");
  static final startDefineCore = RegExp(r"void\s+defineCore\(AFCoreDefinitionContext\s+context\)\s+{");
  static final startExtendCommand = RegExp(r"void\s+installCommand\(AFCommand.*ExtensionContext\s+context\)\s+{");
  static final startDefineTestData = RegExp(r"void\s+defineTestData\(AFDefineTestDataContext\s+context\)\s+{");
  static final startDeclareTestData = RegExp(r"final\s+stateFullLogin\s+=\s+<Object>\[");
  static final startDeclareTestDataID = RegExp(r"class\s+.*TestDataID\s+{");
  static final startDefineLPI = RegExp(r"void\s+defineLibraryProgrammingInterfaces\(AFCoreDefinitionContext\s+context\)\s+{");
  static final startDeclareLPI = RegExp(r"class\s+.*LPI\s+extends\s+.*LPI\s+{");
  static final afTag = RegExp(r".*\[!af_.*\].*");
  static final startImportLine = RegExp(r"import\s+.*;");
  static final defineStartupScreen = RegExp(r"\s+context.defineStartupScreen\(");
  static final isIntId = RegExp(r"int.tryParse\(item.id\)");

  static RegExp startDefineTestsFunction(String suffix) {
    return RegExp("void\\s+define${suffix}s\\(AF${suffix}DefinitionContext\\s+context\\)\\s+{");
  }

  static RegExp startUIID(String kind, String kindSuper) {
    return RegExp("class\\s+.*${kind}ID\\s+extends\\s+AF${kindSuper}ID\\s+{");
  }
    
}
