
/// Superclass for all objects that are returned from queries or that reside
/// in the application state.
/// 
/// 
abstract class AFModel<TQuery> {
  AFModel();

  /// Convert the model to the data type that is used in queries (e.g. JSON)
  TQuery toQuery();

  /// Create a new model from the source data (e.g. JSON)
  AFModel fromQuery(TQuery source);
}