


import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDemoScreenScreenImplsT extends AFSourceTemplate {
  final String template = '''
  /// In online examples, you will frequently see flutter UI declared
  /// in large, inline static data structures.   I prefer decomposing
  /// the UI build into subprocedures.   The SPI makes this easier, as
  /// it is a single value you can pass down that contains everything you
  /// need to render the UI.
  Widget _buildIncrementCard(StartupScreenSPI spi) {
    final t = spi.t;
    final rows = t.column();
    rows.add(t.childMargin(
      margin: t.margin.b.standard,
      child: t.childText("Count of button clicks:", style: t.styleOnCard.bodyText1)
    ));

    rows.add(t.childText(spi.clickCount.toString(), style: t.styleOnCard.headline2));

    rows.add(t.childButtonPrimaryText(
      text: "Increment Count", 
      onPressed: spi.onIncrementCount
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


  