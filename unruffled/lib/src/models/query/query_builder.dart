part of unruffled;

/// Used to build GET query filters
/// It allows you to retrieve data according to applied filters offline or
/// online
class QueryBuilder<T extends DataModel<T>> {
  /// Filter operations (check [ConditionType])
  FilterGroup<T>? filterGroup;

  /// Sort results according to [SortType]
  SortCondition<T>? sort;

  /// Query page result
  int? page;

  /// Query page limit
  int? limit;

  QueryBuilder({
    this.filterGroup,
    this.sort,
    this.page,
    this.limit,
  });
}

abstract class FilterOperation<T extends DataModel<T>> {}

class FilterGroup<T extends DataModel<T>> extends FilterOperation<T> {
  /// The filter(s) to be grouped.
  final List<FilterOperation<T>> filters;

  /// Type of this group.
  final FilterGroupType type;

  /// Create a logical AND filter group.
  FilterGroup.and({required this.filters}) : type = FilterGroupType.and;

  /// Create a logical OR filter group.
  FilterGroup.or({required this.filters}) : type = FilterGroupType.or;
}

class FilterCondition<T extends DataModel<T>> extends FilterOperation<T> {
  /// Type of the filter condition.
  final ConditionType type;

  /// Property used for comparisons.
  final UnruffledField<T> property;

  /// Value used for comparisons.
  final dynamic value;

  /// Should `value` be part of the results.
  final bool include;

  /// Are string operations case sensitive.
  final bool caseSensitive;

  /// Used for [inRange] condition
  final List<dynamic> values;

  FilterCondition.equal({
    required this.property,
    this.value,
    this.caseSensitive = true,
  })  : type = ConditionType.equal,
        values = [],
        include = false;

  FilterCondition.notEqual({
    required this.property,
    this.value,
    this.caseSensitive = true,
  })  : type = ConditionType.notEqual,
        values = [],
        include = false;

  FilterCondition.greaterThan({
    required this.property,
    this.value,
    this.caseSensitive = true,
    this.include = false,
  })  : type = ConditionType.gt,
        values = [];

  FilterCondition.lowerThan({
    required this.property,
    this.value,
    this.caseSensitive = true,
    this.include = false,
  })  : type = ConditionType.lt,
        values = [];

  FilterCondition.inRange({
    required this.property,
    this.include = false,
    this.values = const [],
  })  : type = ConditionType.inRange,
        value = null,
        caseSensitive = false;
}

/// Property used to sort query results.
class SortCondition<T extends DataModel<T>> {
  /// Unruffled field used for sorting.
  final UnruffledField<T> property;

  /// Sort order.
  final SortType sort;

  const SortCondition({required this.property, required this.sort});
}

enum FilterGroupType { and, or }

enum ConditionType { equal, notEqual, gt, lt, inRange }

enum SortType { asc, desc }
