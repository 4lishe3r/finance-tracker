import 'package:cloud_firestore/cloud_firestore.dart';

class SharedExpense {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String paidBy;
  final List<String> splitWith;
  final DateTime date;
  final String? householdId;

  const SharedExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.paidBy,
    required this.splitWith,
    required this.date,
    this.householdId,
  });

  factory SharedExpense.fromJson(Map<String, dynamic> json, String id) =>
      SharedExpense(
        id: id,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        paidBy: json['paidBy'] as String,
        splitWith: List<String>.from(json['splitWith'] as List? ?? []),
        date: DateTime.parse(json['date'] as String),
        householdId: json['householdId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'currency': currency,
        'paidBy': paidBy,
        'splitWith': splitWith,
        'date': date.toIso8601String(),
        'householdId': householdId,
      };
}

abstract interface class SharedExpenseDataSource {
  Stream<List<SharedExpense>> watchSharedExpenses(String householdId);
  Future<void> addSharedExpense(SharedExpense expense);
  Future<void> deleteSharedExpense(String id, String householdId);
}

class SharedExpenseDataSourceFirestore implements SharedExpenseDataSource {
  final FirebaseFirestore _firestore;

  SharedExpenseDataSourceFirestore(this._firestore);

  CollectionReference<Map<String, dynamic>> _col(String householdId) =>
      _firestore
          .collection('households')
          .doc(householdId)
          .collection('expenses');

  @override
  Stream<List<SharedExpense>> watchSharedExpenses(String householdId) {
    return _col(householdId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SharedExpense.fromJson(d.data(), d.id))
            .toList());
  }

  @override
  Future<void> addSharedExpense(SharedExpense expense) =>
      _col(expense.householdId!).add(expense.toJson());

  @override
  Future<void> deleteSharedExpense(String id, String householdId) =>
      _col(householdId).doc(id).delete();
}

