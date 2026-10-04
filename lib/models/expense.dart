class Expense {
  final int? id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String notes;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: (map['notes'] as String?) ?? '',
    );
  }

  Expense copyWith({
    int? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
