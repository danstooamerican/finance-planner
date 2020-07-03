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
  final Function(Transaction) primaryAction;

  //// No form checks are performed before this action is called.
  final Function(Transaction) secondaryAction;

  final TransactionService _transactionService;
  final Transaction _transaction;

  List<Category> _categories;
  List<Category> get categories => _categories;

  String categoryName;

  Category _selectedCategory;
  Category get selectedCategory => _selectedCategory;
  set selectedCategory(Category category) {
    if (category != null) {
      _selectedCategory = category;
      _selectedIcon = category.icon;
      categoryName = category.name;

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

  String _title;
  String get title => _title;

  String _description;
  String get description => _description;

  double _amount;
  double get amount => _amount;
  String get amountString => _amount.formatMoneyToEdit();

  TransactionFormViewModel(this._transactionService, @factoryParam this._transaction, @factoryParam this.primaryAction,
      @factoryParam this.secondaryAction) {
    _categories = List();
    updateCategories();

    if (_transaction != null) {
      _selectedCategory = _transaction.category;
      _selectedIcon = _transaction.category.icon;
      _selectedDate = _transaction.date;
      _amount = _transaction.amount;
      _description = _transaction.description;
    } else {
      _selectedDate = DateTime.now();
      _selectedIcon = Icons.category;
    }
  }

  void updateCategories() async {
    _categories = await runBusyFuture(
      _transactionService.getCategories().then((value) {
        if (value != null && value.length > 0 && _selectedCategory == null) {
          _selectedCategory = value.first;
        }

        return value;
      }),
      busyObject: _categories,
    );

    notifyListeners();
  }

  void submitPrimaryAction() {
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
        amount: amount,
        dateTime: selectedDate,
      );

      primaryAction(transaction);
    }
  }

  void submitSecondaryAction() {
    secondaryAction(_transaction);
  }
}
