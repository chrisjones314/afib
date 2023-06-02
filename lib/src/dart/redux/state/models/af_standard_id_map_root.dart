
import 'package:meta/meta.dart';

/// The superclass used when --add-standard-root is specified on the command line.
/// 
/// The idea is that your state may have a root object like "users" or "todoItems",
/// which is just a mapping of unique identifiers to users or todo items.   This superclass
/// provides functionality for accessing and manipulating that map.
@immutable
abstract class AFStandardIDMapRoot<TSubclass, TModel> {
  final Map<String, TModel> items;

  AFStandardIDMapRoot({
    required this.items,
  });

  /// Access the unique identifier of an item (usually from your persistent store).
  String itemId(TModel item);

  /// Replace all the existing items with these new items.
  TSubclass reviseItems(Map<String, TModel> items);

  /// Find an item with the specified unqieu id.
  TModel? findById(String id) => items[id];

  /// Return a list of items with the specified unique ids.
  Iterable<TModel> findByIds(List<String> ids) => items.values.where((e) {
    return ids.contains(itemId(e)); 
  });

  /// Find all the items that satisfy somoe criteria.
  Iterable<TModel> findWhere(bool Function(TModel e) fn) => items.values.where(fn);

  /// All the ids of items.
  Iterable<String> get findIds => items.keys;

  /// All the items.
  Iterable<TModel> get findAll => items.values;

  /// How many items there are.
  int get length => items.length;

  /// Add a single item.
  TSubclass reviseSetItem(TModel item) {
    final revised = Map<String, TModel>.from(items);
    final id = itemId(item);
    revised[id] = item;
    return reviseItems(revised);
  }

  /// Adds all the items, replacing items that already exist, preserving other items.
  TSubclass reviseSetItems(Iterable<TModel> newItems) {
    final revised = Map<String, TModel>.from(items);
    for(final item in newItems) {
      final id = itemId(item);
      revised[id] = item;
    }
    return reviseItems(revised);
  }

  /// Adds all the items that are not already present, but does not replace existing items.
  TSubclass reviseAugmentItems(Iterable<TModel> newItems) {
    final revised = Map<String, TModel>.from(items);
    for(final item in newItems) {
      final id = itemId(item);
      if(!revised.containsKey(id)) {
        revised[id] = item;
      }
    }
    return reviseItems(revised);
  }

  /// Removes the item with the specified id.
  TSubclass reviseRemoveItemById(String id) {
    final revised = Map<String, TModel>.from(items);
    revised.remove(id);
    return reviseItems(revised);
  }

  /// Resets the items to empty.
  TSubclass reviseRemoveAllItems() {
    final revised = <String, TModel>{};
    return reviseItems(revised);
  }

  /// Removes all items for which the callback returns true
  TSubclass reviseRemoveItemsWhere(
    bool Function(String, TModel) removeWhere 
  ) {
    final revised = Map<String, TModel>.from(items);
    revised.removeWhere(removeWhere);
    return reviseItems(revised);
  }

} 