import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';

class TransactionCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.expense,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    ExpenseCategory category;
    try {
      category = context.watch<ExpenseProvider>().getCategory(expense.categoryId);
    } catch (_) {
      category = ExpenseCategory.getById(expense.categoryId);
    }
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM d, yyyy');

    final cardContent = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon with colored background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Expense Title & Category Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•  ${dateFormat.format(expense.date)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount Display
            Text(
              '-${currencyFormat.format(expense.amount)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444), // Expense red
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );

    if (onDelete == null) return cardContent;

    return Dismissible(
      key: Key(expense.id?.toString() ?? expense.hashCode.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                SizedBox(width: 10),
                Text('Delete Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text('Are you sure you want to delete "${expense.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.delete_sweep_rounded,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: cardContent,
    );
  }
}
