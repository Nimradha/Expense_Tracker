import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Expenses Table
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

    // 2. Categories Table
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

    // 3. Settings / Budget Table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Seed default categories
    final batch = db.batch();
    for (final cat in ExpenseCategory.defaultCategories) {
      batch.insert('categories', cat.toMap());
    }

    // Seed default monthly budget
    batch.insert('settings', {'key': 'monthly_budget', 'value': '2000.0'});

    // Seed initial demo expenses so the dashboard is immediately interactive
    final now = DateTime.now();
    final demoExpenses = [
      Expense(
        title: 'Weekly Supermarket Groceries',
        amount: 84.50,
        categoryId: 'food',
        date: now.subtract(const Duration(hours: 4)),
        notes: 'Organic fruits, vegetables and milk',
      ),
      Expense(
        title: 'Monthly Electric & Water Bill',
        amount: 125.00,
        categoryId: 'bills',
        date: now.subtract(const Duration(days: 1)),
        notes: 'Utility payment for current month',
      ),
      Expense(
        title: 'Gas Station Refill',
        amount: 55.20,
        categoryId: 'transport',
        date: now.subtract(const Duration(days: 2)),
        notes: 'Full tank unleaded',
      ),
      Expense(
        title: 'Cinema & Popcorn',
        amount: 32.00,
        categoryId: 'entertainment',
        date: now.subtract(const Duration(days: 3)),
        notes: 'Weekend movie with friends',
      ),
      Expense(
        title: 'Running Shoes Sale',
        amount: 110.00,
        categoryId: 'shopping',
        date: now.subtract(const Duration(days: 4)),
        notes: 'New training shoes',
      ),
    ];

    for (final exp in demoExpenses) {
      batch.insert('expenses', exp.toMap());
    }

    await batch.commit(noResult: true);
  }

  // ================= EXPENSE CRUD =================

  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<List<Expense>> getExpensesByMonth(DateTime month, {String? categoryId}) async {
    final db = await database;
    final yearMonthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';

    String whereClause = "date LIKE ?";
    List<dynamic> whereArgs = ['$yearMonthStr%'];

    if (categoryId != null) {
      whereClause += " AND categoryId = ?";
      whereArgs.add(categoryId);
    }

    final result = await db.query(
      'expenses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= CATEGORY CRUD =================

  Future<int> insertCategory(ExpenseCategory category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExpenseCategory>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories');
    if (result.isEmpty) {
      return ExpenseCategory.defaultCategories;
    }
    return result.map((json) => ExpenseCategory.fromMap(json)).toList();
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ? AND isCustom = 1',
      whereArgs: [id],
    );
  }

  // ================= BUDGET & AGGREGATIONS =================

  Future<double> getMonthlyBudget() async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['monthly_budget'],
    );
    if (result.isNotEmpty) {
      return double.tryParse(result.first['value'] as String) ?? 2000.0;
    }
    return 2000.0;
  }

  Future<void> setMonthlyBudget(double amount) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': 'monthly_budget', 'value': amount.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Aggregates monthly expenses by category using SQLite SUM() and GROUP BY
  Future<Map<String, double>> getMonthlyCategoryAggregation(DateTime month) async {
    final db = await database;
    final yearMonthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';

    final result = await db.rawQuery('''
      SELECT categoryId, SUM(amount) as total
      FROM expenses
      WHERE date LIKE ?
      GROUP BY categoryId
    ''', ['$yearMonthStr%']);

    final Map<String, double> totals = {};
    for (final row in result) {
      final catId = row['categoryId'] as String;
      final sum = (row['total'] as num).toDouble();
      totals[catId] = sum;
    }
    return totals;
  }

  /// Calculates total expenditure for a specific month
  Future<double> getTotalSpentForMonth(DateTime month) async {
    final db = await database;
    final yearMonthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';

    final result = await db.rawQuery('''
      SELECT SUM(amount) as grand_total
      FROM expenses
      WHERE date LIKE ?
    ''', ['$yearMonthStr%']);

    if (result.isNotEmpty && result.first['grand_total'] != null) {
      return (result.first['grand_total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
