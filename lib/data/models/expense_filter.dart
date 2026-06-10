class ExpenseFilter {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<String>? categoryIds;
  final double? amountMin;
  final double? amountMax;
  final String? searchQuery;

  const ExpenseFilter({
    this.dateFrom,
    this.dateTo,
    this.categoryIds,
    this.amountMin,
    this.amountMax,
    this.searchQuery,
  });

  ExpenseFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<String>? categoryIds,
    double? amountMin,
    double? amountMax,
    String? searchQuery,
  }) {
    return ExpenseFilter(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      categoryIds: categoryIds ?? this.categoryIds,
      amountMin: amountMin ?? this.amountMin,
      amountMax: amountMax ?? this.amountMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      dateFrom != null ||
      dateTo != null ||
      (categoryIds != null && categoryIds!.isNotEmpty) ||
      amountMin != null ||
      amountMax != null ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}
