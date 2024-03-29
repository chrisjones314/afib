

import 'package:afib/afib_flutter.dart';

class AFRegisterListenerQueryAction {
  final AFAsyncListenerQuery query;
  AFRegisterListenerQueryAction(this.query);
}

class AFRegisterDeferredQueryAction {
  final AFDeferredQuery query;
  AFRegisterDeferredQueryAction(this.query);
}


class AFRegisterPeriodicQueryAction {
  final AFPeriodicQuery query;
  AFRegisterPeriodicQueryAction(this.query);
}



/// Shuts down outstanding deferred and listener queries.
class AFShutdownOngoingQueriesAction extends AFActionWithKey {
}


class AFShutdownDeferredQueryAction {
  final String key;
  AFShutdownDeferredQueryAction(this.key);
}

class AFShutdownListenerQueryAction {
  final String key;
  AFShutdownListenerQueryAction(this.key);
}

class AFShutdownPeriodicQueryAction {
  final String key;
  AFShutdownPeriodicQueryAction(this.key);
}