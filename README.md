# 💸 Expense Tracker App

A full-featured personal finance mobile app built with **Flutter & Dart**, designed to help users track expenses, manage category budgets, and visualize spending patterns — all stored locally with **SQLite**.

---

## ✨ Key Features

- 📊 **Interactive Analytics** — Pie chart & weekly bar chart powered by `fl_chart`
- 💰 **Budget Tracking** — Set a monthly budget with color-coded progress indicators (On Track / Warning / Over Budget)
- 🗂️ **Category Management** — 8 built-in categories + create custom ones with icon & color picker
- 📝 **Full CRUD** — Add, edit (tap), and delete (swipe) expenses
- ↩️ **Undo Delete** — Swipe-to-delete with confirmation dialog and SnackBar undo
- 🔍 **Filterable History** — Search by title/notes, filter by category, sort by date or amount
- 💾 **Local SQLite Storage** — All data persists across app restarts using `sqflite`
- 🌙 **Dark & Light Mode** — Full Material 3 theming with auto system theme detection

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.24 / Dart 3.5 |
| State Management | Provider |
| Local Database | sqflite (SQLite) |
| Charts | fl_chart |
| Date/Currency Formatting | intl |
| Architecture | MVVM-like (Provider + Repository) |

---

## 📁 Project Structure

```
lib/
├── database/
│   └── database_helper.dart    # SQLite singleton, CRUD & GROUP BY queries
├── models/
│   ├── expense.dart            # Expense model with toMap/fromMap
│   └── category.dart           # Category model with icon/color palettes
├── providers/
│   └── expense_provider.dart   # ChangeNotifier state + DB sync
├── screens/
│   ├── dashboard_screen.dart   # Main dashboard with budget card
│   ├── summary_screen.dart     # Charts & analytics
│   ├── history_screen.dart     # Filterable transaction history
│   └── main_navigation_screen.dart
├── theme/
│   └── app_theme.dart          # Material 3 light & dark themes
└── widgets/
    ├── hero_budget_card.dart
    ├── transaction_card.dart
    ├── add_expense_modal.dart
    ├── add_category_dialog.dart
    ├── category_manager_sheet.dart
    └── set_budget_dialog.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.24
- Dart SDK ≥ 3.5
- Android Studio / VS Code

### Run the App

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/expense_tracker.git
cd expense_tracker

# 2. Install dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run
```

---

## 📸 Screenshots

> *(Add your screenshots here after running the app)*

---

## 📄 License

This project was developed as part of an internship task.
