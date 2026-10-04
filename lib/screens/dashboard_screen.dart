import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/hero_budget_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/add_expense_modal.dart';
import '../widgets/set_budget_dialog.dart';
import '../widgets/category_manager_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final currentMonthStr = DateFormat('MMMM yyyy').format(provider.selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Tracker',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              currentMonthStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Manage Categories',
            icon: const Icon(Icons.category_outlined, size: 22),
            onPressed: () => CategoryManagerSheet.show(context),
          ),
          IconButton(
            tooltip: 'Select Month',
            icon: const Icon(Icons.calendar_today_rounded, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: provider.selectedMonth,
                firstDate: DateTime(2022),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                provider.changeMonth(picked);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddExpenseModal.show(
            context,
            onSave: (expense) {
              provider.addExpense(expense);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "${expense.title}" successfully!'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hero Budget Card section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: HeroBudgetCard(
                totalSpent: provider.totalSpent,
                budgetLimit: provider.monthlyBudget,
                onEditBudget: () {
                  SetBudgetDialog.show(
                    context,
                    currentBudget: provider.monthlyBudget,
                    onSave: (newBudget) {
                      provider.setMonthlyBudget(newBudget);
                    },
                  );
                },
              ),
            ),
          ),

          // Categories Horizontal Filter Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      if (provider.selectedCategoryFilter != null)
                        TextButton(
                          onPressed: () => provider.filterByCategory(null),
                          child: const Text('Reset', style: TextStyle(fontSize: 13)),
                        ),
                      TextButton.icon(
                        onPressed: () => CategoryManagerSheet.show(context),
                        icon: const Icon(Icons.tune_rounded, size: 14),
                        label: const Text('Manage', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Category Chips List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isAll = provider.selectedCategoryFilter == null;
                    return FilterChip(
                      selected: isAll,
                      label: const Text('All Categories'),
                      selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF10B981),
                      onSelected: (_) => provider.filterByCategory(null),
                    );
                  }
                  final cat = provider.categories[index - 1];
                  final isSelected = provider.selectedCategoryFilter == cat.id;
                  final spent = provider.getCategoryTotal(cat.id);
                  return FilterChip(
                    selected: isSelected,
                    avatar: Icon(cat.icon, size: 16, color: cat.color),
                    label: Text(
                      spent > 0 ? '${cat.name} (\$${spent.toStringAsFixed(0)})' : cat.name,
                    ),
                    selectedColor: cat.color.withOpacity(0.2),
                    checkmarkColor: cat.color,
                    onSelected: (_) => provider.filterByCategory(cat.id),
                  );
                },
              ),
            ),
          ),

          // Recent Expenses Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.expenses.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Swipe left to delete',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Transactions List or Empty State
          if (provider.expenses.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Expenses Found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No expenses match this filter or month.\nTap the + button below to add your first expense!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = provider.expenses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TransactionCard(
                        expense: expense,
                        onTap: () {
                          // Tap to edit
                          AddExpenseModal.show(
                            context,
                            initialExpense: expense,
                            onSave: (updated) {
                              provider.updateExpense(updated);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Expense updated!'),
                                  backgroundColor: Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            onDelete: () {
                              if (expense.id != null) {
                                provider.deleteExpense(expense.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Deleted "${expense.title}"'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: Colors.white,
                                      onPressed: () => provider.addExpense(expense),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        onDelete: () {
                          if (expense.id != null) {
                            provider.deleteExpense(expense.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${expense.title}"'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: Colors.white,
                                  onPressed: () => provider.addExpense(expense),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  childCount: provider.expenses.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
