class ExpenseEntity {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String currency;
  final String? note;
  final DateTime date;

  const ExpenseEntity({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.currency,
    this.note,
    required this.date,
  });

  ExpenseEntity copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? currency,
    String? note,
    DateTime? date,
  }) =>
      ExpenseEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        currency: currency ?? this.currency,
        note: note ?? this.note,
        date: date ?? this.date,
      );
}
