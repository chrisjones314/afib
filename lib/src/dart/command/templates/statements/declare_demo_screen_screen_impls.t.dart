


import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDemoScreenScreenImplsT extends AFSourceTemplate {
  final String template = '''
  /// This method creates the UI card which displays the route parameter
  /// count.
  /// 
  /// In online examples, you will frequently see flutter UI declared
  /// in large, inline static data structures.   I prefer decomposing
  /// the UI build into subprocedures.   The SPI makes this easier, as
  /// it is a single value you can pass down that contains everything you
  /// need to render the UI.
  Widget _buildIncrementParamCard(StartupScreenSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childMargin(
      margin: t.margin.b.standard,
      child: t.childText("Route parameter count", style: t.styleOnCard.bodyText1)
    ));

    rows.add(t.childText(
      spi.clickCountParam.toString(),
      wid: [!af_app_namespace(upper)]WidgetID.textCountRouteParam,
      style: t.styleOnCard.headline2
    ));

    rows.add(t.childMargin(
      margin: t.margin.b.biggest,
      child: t.childButtonPrimaryText(
        wid: [!af_app_namespace(upper)]WidgetID.buttonIncrementRouteParam,
        text: "Increment Route Parameter Count", 
        onPressed: spi.onIncrementParamCount
      )
    ));

    return Card(
      child: t.childMargin(
        margin: t.margin.standard,
        child: Column(children: rows)
      )
    );
  }

  /// This method creates the UI card that displays the state count.
  ///
  /// This method could have been been consolidated with the method above using a few parameters,
  /// but I left them separate to make debugging the example easier and clearer.
  Widget _buildIncrementStateCard(StartupScreenSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childMargin(
      margin: t.margin.b.standard,
      child: t.childText("State count", style: t.styleOnCard.bodyText1)
    ));

    rows.add(t.childText(spi.clickCountState.toString(), style: t.styleOnCard.headline2));

    rows.add(t.childMargin(
      margin: t.margin.b.biggest,
      child: t.childButtonPrimaryText(
        text: "Increment State Count", 
        onPressed: spi.onIncrementStateCount
      )
    ));

    return Card(
      child: t.childMargin(
        margin: t.margin.standard,
        child: Column(children: rows)
      )
    );    
  }

''';
}


  