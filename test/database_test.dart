import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  // Setup sqflite ffi for headless test runner
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;

  setUp(() async {
    // Open in-memory database for clean isolated testing
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Create expenses and categories tables
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconCode INTEGER NOT NULL,
        colorValue INTEGER NOT NULL,
        budgetLimit REAL,
        isCustom INTEGER NOT NULL DEFAULT 0
      )
    ''');
  });

  tearDown(() async {
    await db.close();
  });

  test('SQLite: Insert, Read, Update, Delete Expense records', () async {
    final expense = Expense(
      title: 'Coffee at Cafe',
      amount: 4.75,
      categoryId: 'food',
      date: DateTime.now(),
      notes: 'Morning espresso',
    );

    // 1. Insert
    final id = await db.insert('expenses', expense.toMap());
    expect(id, isPositive);

    // 2. Read
    final records = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    expect(records.length, 1);
    final fetched = Expense.fromMap(records.first);
    expect(fetched.title, 'Coffee at Cafe');
    expect(fetched.amount, 4.75);

    // 3. Update
    final updated = fetched.copyWith(amount: 5.50, notes: 'Double shot');
    final updateCount = await db.update(
      'expenses',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    expect(updateCount, 1);

    final updatedRecords = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    expect((updatedRecords.first['amount'] as num).toDouble(), 5.50);

    // 4. Delete
    final deleteCount = await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    expect(deleteCount, 1);

    final remaining = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    expect(remaining, isEmpty);
  });

  test('SQLite: Monthly aggregation query sums amounts per category', () async {
    final now = DateTime.now();
    final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Insert multiple records across categories
    await db.insert('expenses', {
      'title': 'Dinner',
      'amount': 50.0,
      'categoryId': 'food',
      'date': now.toIso8601String(),
    });
    await db.insert('expenses', {
      'title': 'Lunch',
      'amount': 25.0,
      'categoryId': 'food',
      'date': now.toIso8601String(),
    });
    await db.insert('expenses', {
      'title': 'Metro Card',
      'amount': 30.0,
      'categoryId': 'transport',
      'date': now.toIso8601String(),
    });

    // Execute GROUP BY aggregation query
    final result = await db.rawQuery('''
      SELECT categoryId, SUM(amount) as total
      FROM expenses
      WHERE date LIKE ?
      GROUP BY categoryId
    ''', ['$yearMonth%']);

    final Map<String, double> totals = {};
    for (final row in result) {
      totals[row['categoryId'] as String] = (row['total'] as num).toDouble();
    }

    expect(totals['food'], 75.0); // 50 + 25
    expect(totals['transport'], 30.0);
  });

  test('SQLite: Insert and Read Categories with colors and icons', () async {
    final cat = ExpenseCategory.defaultCategories.first;
    await db.insert('categories', cat.toMap());

    final result = await db.query('categories', where: 'id = ?', whereArgs: [cat.id]);
    expect(result.length, 1);
    final loaded = ExpenseCategory.fromMap(result.first);
    expect(loaded.name, cat.name);
    expect(loaded.icon.codePoint, cat.icon.codePoint);
  });
}
