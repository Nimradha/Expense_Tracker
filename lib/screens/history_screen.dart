import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/add_expense_modal.dart';

enum HistorySortOption {
  newestFirst,
  oldestFirst,
  highestAmount,
  lowestAmount,
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  HistorySortOption _sortOption = HistorySortOption.newestFirst;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _sortOption = HistorySortOption.newestFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final hasActiveFilters = _searchQuery.isNotEmpty || _selectedCategory != null;

    // 1. Filter by search query and category
    List<Expense> filteredList = provider.allExpenses.where((exp) {
      // Search match
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matches = exp.title.toLowerCase().contains(query) ||
            exp.notes.toLowerCase().contains(query);
        if (!matches) return false;
      }
      // Category match
      if (_selectedCategory != null) {
        if (exp.categoryId != _selectedCategory) return false;
      }
      return true;
    }).toList();

    // 2. Sort
    switch (_sortOption) {
      case HistorySortOption.newestFirst:
        filteredList.sort((a, b) => b.date.compareTo(a.date));
        break;
      case HistorySortOption.oldestFirst:
        filteredList.sort((a, b) => a.date.compareTo(b.date));
        break;
      case HistorySortOption.highestAmount:
        filteredList.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case HistorySortOption.lowestAmount:
        filteredList.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    final totalFound = filteredList.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<HistorySortOption>(
            tooltip: 'Sort Records',
            icon: const Icon(Icons.sort_rounded),
            onSelected: (option) => setState(() => _sortOption = option),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: HistorySortOption.newestFirst,
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Newest First'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: HistorySortOption.oldestFirst,
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Oldest First'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: HistorySortOption.highestAmount,
                child: Row(
                  children: [
                    Icon(Icons.attach_money_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Highest Amount'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: HistorySortOption.lowestAmount,
                child: Row(
                  children: [
                    Icon(Icons.money_off_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Lowest Amount'),
                  ],
                ),
              ),
            ],
          ),
          if (hasActiveFilters)
            IconButton(
              tooltip: 'Reset Filters',
              icon: const Icon(Icons.filter_alt_off_rounded),
              onPressed: _clearFilters,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search by title or notes...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Horizontal Category Filter Chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategory == null;
                  return ChoiceChip(
                    selected: isSelected,
                    label: const Text('All Categories'),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  );
                }
                final cat = provider.categories[index - 1];
                final isSelected = _selectedCategory == cat.id;
                return ChoiceChip(
                  selected: isSelected,
                  avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                  label: Text(cat.name),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : null,
                  ),
                  selectedColor: cat.color,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = selected ? cat.id : null);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Search Stats Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredList.length} transactions found',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  'Total: ${currencyFormat.format(totalFound)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 12),

          // Filtered Transactions List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 56,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No matching transactions found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        if (hasActiveFilters)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Reset All Filters'),
                          ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exp = filteredList[index];
                      return TransactionCard(
                        expense: exp,
                        onTap: () {
                          AddExpenseModal.show(
                            context,
                            initialExpense: exp,
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
                              if (exp.id != null) {
                                provider.deleteExpense(exp.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Deleted "${exp.title}"'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: Colors.white,
                                      onPressed: () => provider.addExpense(exp),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        onDelete: () {
                          if (exp.id != null) {
                            provider.deleteExpense(exp.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${exp.title}"'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: Colors.white,
                                  onPressed: () => provider.addExpense(exp),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
