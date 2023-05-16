import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetFundamentalThemeInitT extends AFSnippetSourceTemplate {
  static const insertExtraTranslations = AFSourceTemplateInsertion("extra_translations");

  SnippetFundamentalThemeInitT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions,
  );

   factory SnippetFundamentalThemeInitT.custom({
    required String templateFileId,
    required List<String> templateFolder,
    required Object extraTranslations,
  }) {
    return SnippetFundamentalThemeInitT(
      templateFileId: templateFileId,
      templateFolder: templateFolder,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {
        insertExtraTranslations: extraTranslations,
      })
    );

  }

  factory SnippetFundamentalThemeInitT.core() {
    return SnippetFundamentalThemeInitT.custom(
      templateFileId: "fundamental_theme_init",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      extraTranslations: AFSourceTemplate.empty,
    );
  }
 

  String get template => '''
  const colorPrimary = Color(0xFF344955);
  const colorSecondary = Color(0xFF5d4037);

  final colorsLight = ColorScheme(
    primary: colorPrimary,
    secondary: colorSecondary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
    error: Colors.red,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Colors.grey[200] ?? Colors.grey,
    onError: Colors.white,
    brightness: Brightness.light
  );


  const colorsDarkBase = ColorScheme.dark();  
  final colorsDark = ColorScheme(
    primary: colorPrimary,
    secondary: colorSecondary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: colorsDarkBase.onBackground,
    error: colorsDarkBase.error,
    surface: colorsDarkBase.surface,
    onSurface: colorsDarkBase.onSurface,
    background: colorsDarkBase.background,
    onError: colorsDarkBase.onError,
    brightness: Brightness.dark
  );

  const origDark = Typography.whiteCupertino;
  const origLight = Typography.blackCupertino;

  final themeDark = origDark.copyWith(
    bodyText1: origDark.bodyText1?.copyWith(fontWeight: FontWeight.bold)
  );

  final themeLight = origLight.copyWith(
    bodyText1: origLight.bodyText1?.copyWith(fontWeight: FontWeight.bold)
  );

  primary.setFlutterFundamentals(
    colorSchemeLight: colorsLight,
    colorSchemeDark: colorsDark,
    textThemeDark: themeDark,
    textThemeLight: themeLight,
  ); 

  // AFIB_TODO: This function takes many parameters with default values.   Look
  // at its documentation, and customize those values
  primary.setAfibFundamentals();

  // You can also create custom theme ids values of any type (not just colors),
  // and then access them from within your ${insertAppNamespaceUpper}DefaultTheme using 
  // fundamentals.findValue<YourType>(${insertAppNamespaceUpper}ThemeID.exampleCustom)
  primary.setValue(${insertAppNamespaceUpper}ThemeID.exampleCustom, Colors.yellow);
  

  primary.setTranslations(AFUILocaleID.englishUS, {
    AFUITranslationID.appTitle: "${insertPackageName.spaces}",
    $insertExtraTranslations
  });
''';
}