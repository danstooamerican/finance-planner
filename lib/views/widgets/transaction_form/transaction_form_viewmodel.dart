import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';

@injectable
class TransactionFormViewModel extends BaseViewModel {
  Function(Transaction) primaryAction;

  //// No form checks are performed before this action is called.
  Function(Transaction) secondaryAction;

  final TransactionService _transactionService;
  Transaction _transaction;

  List<Category> _categories;
  List<Category> get categories => _categories;

  String _categoryName;
  String get categoryName => _categoryName ?? '';
  set categoryName(String value) {
    _categoryName = value;
  }

  Category _selectedCategory;
  Category get selectedCategory => _selectedCategory;
  set selectedCategory(Category category) {
    if (category != null) {
      _selectedCategory = category;
      _selectedIcon = category.icon;
      _categoryName = category.name;

      notifyListeners();
    }
  }

  IconData _selectedIcon;
  IconData get selectedIcon => _selectedIcon;
  set selectedIcon(IconData icon) {
    if (icon != null) {
      _selectedIcon = icon;

      if (_selectedCategory != null) {
        _selectedCategory = Category(id: _selectedCategory.id, name: _selectedCategory.name, icon: icon);
      }

      notifyListeners();
    }
  }

  DateTime _selectedDate;
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime date) {
    if (date != null && date != selectedDate) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  String title;

  String description;

  double _amountValue;
  String get amount => _amountValue?.formatMoneyToEdit() ?? '';
  set amount(String value) => _amountValue = value.parseMoney();

  TransactionFormViewModel(this._transactionService);

  void initialize(Transaction transaction, Function(Transaction) primaryAction, Function(Transaction) secondaryAction) {
    _transaction = transaction;
    this.primaryAction = primaryAction;
    this.secondaryAction = secondaryAction;
    _categories = List();
    _updateCategories();

    if (_transaction != null && _transaction.id != 0) {
      selectedCategory = _transaction.category;
      selectedIcon = _transaction.category.icon;
      selectedDate = _transaction.date;
      _amountValue = _transaction.amount;
      description = _transaction.description;
    } else {
      selectedDate = DateTime.now();
      selectedIcon = Icons.category;
    }
  }

  void _updateCategories() async {
    _categories = await runBusyFuture(
      _transactionService.getCategories(),
      busyObject: _categories,
    ).then((value) {
      if (value != null && value.length > 0 && selectedCategory == null) {
        selectedCategory = value.first;
      }

      return value;
    });
  }

  void submitPrimaryAction() {
    print(categoryName);
    if (categoryName != null && categoryName.trim().isNotEmpty) {
      int categoryId = 0;
      if (_selectedCategory != null && categoryName == _selectedCategory.name) {
        categoryId = _selectedCategory.id;
      }

      Category category = Category(id: categoryId, name: categoryName, icon: selectedIcon);

      final Transaction transaction = Transaction(
        id: _transaction.id,
        category: category,
        description: description.trim(),
        amount: _amountValue,
        dateTime: selectedDate,
      );

      primaryAction(transaction);
    }
  }

  void submitSecondaryAction() {
    secondaryAction(_transaction);
  }
}
