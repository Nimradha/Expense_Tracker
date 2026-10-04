import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expense_tracker/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App launches and displays dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });
}
