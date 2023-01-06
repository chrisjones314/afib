
import 'package:meta/meta.dart';

@immutable
abstract class AFStandardIDMapRoot<TSubclass, TModel> {
  final Map<String, TModel> items;

  AFStandardIDMapRoot({
    required this.items,
  });

  String itemId(TModel item);
  TSubclass reviseItems(Map<String, TModel> items);

  /// Add a single item.
  TSubclass reviseSetItem(TModel item) {
    final revised = Map<String, TModel>.from(items);
    final id = itemId(item);
    revised[id] = item;
    return reviseItems(revised);
  }

  /// Adds all the items, replacing items that already exist.
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