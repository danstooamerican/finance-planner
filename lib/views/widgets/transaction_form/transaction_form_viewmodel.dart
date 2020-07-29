import 'dart:async';

import 'package:financeplanner/dependency_injection_config.dart';
import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransactionFormViewModel {
  final Transaction _startTransaction;
  int get _transactionId => _startTransaction?.id ?? 0;

  Function(Transaction) primaryAction;

  //// No form checks are performed before this action is called.
  Function(Transaction) secondaryAction;

  TransactionService _transactionService;

  List<Category> _categories;
  List<Category> get categories => _categories;

  String _categoryName;
  String get categoryName => _categoryName;
  StreamController<String> _categoryNameController = StreamController<String>.broadcast();
  Sink<String> get inputCategoryName => _categoryNameController;
  Stream<String> get outputCategoryName => _categoryNameController.stream;
  bool get categoryEntered {
    return _categoryName != null && _categoryName.trim().isNotEmpty;
  }

  IconData _selectedIcon;
  IconData get selectedIcon => _selectedIcon;
  StreamController<IconData> _iconController = StreamController<IconData>.broadcast();
  Sink<IconData> get inputIcon => _iconController;
  Stream<IconData> get outputIcon => _iconController.stream;

  DateTime _selectedDate;
  DateTime get selectedDate => _selectedDate;
  StreamController<DateTime> _dateController = StreamController<DateTime>.broadcast();
  Sink<DateTime> get inputDate => _dateController;
  Stream<DateTime> get outputDate => _dateController.stream;

  String _description;
  String get description => _description;
  StreamController<String> _descriptionController = StreamController<String>.broadcast();
  Sink<String> get inputDescription => _descriptionController;

  String _amount;
  String get amount => _amount;
  StreamController<String> _amountController = StreamController<String>.broadcast();
  Sink<String> get inputAmount => _amountController;

  TransactionFormViewModel(
    this._startTransaction,
    Function(Transaction) primaryAction,
    Function(Transaction) secondaryAction,
  ) {
    this._transactionService = locator<TransactionService>();

    _initStreams();

    this.primaryAction = primaryAction;
    this.secondaryAction = secondaryAction;
    _categories = List();
    _updateCategories();
  }

  void _initStreams() {
    _description = _startTransaction?.description ?? "";
    _categoryName = _startTransaction?.category?.name ?? "";
    _selectedIcon = _startTransaction?.category?.icon ?? Icons.category;
    _amount = _startTransaction?.amount?.formatMoneyToEdit() ?? null;
    _selectedDate = _startTransaction?.date ?? DateTime.now();

    _categoryNameController.stream.listen((event) {
      _categoryName = event;

      Category existingCategory =
          _categories.firstWhere((element) => element.name == _categoryName, orElse: () => null);

      if (existingCategory != null) {
        inputIcon.add(existingCategory.icon);
      }
    });

    _iconController.stream.listen((event) {
      _selectedIcon = event;
    });

    _dateController.stream.listen((event) {
      _selectedDate = event;
    });

    _amountController.stream.listen((event) {
      _amount = event;
    });

    _descriptionController.stream.listen((event) {
      _description = event;
    });
  }

  void _updateCategories() async {
    _transactionService.getCategories().then((value) => _categories = value);
  }

  Future<void> submitPrimaryAction() async {
    if (categoryEntered) {
      int categoryId = 0;

      Category existingCategory =
          _categories.firstWhere((element) => element.name == _categoryName, orElse: () => null);
      if (existingCategory != null) {
        categoryId = existingCategory.id;
      }

      Category category = Category(id: categoryId, name: _categoryName, icon: selectedIcon);

      final Transaction transaction = Transaction(
        id: _transactionId,
        category: category,
        description: description,
        amount: amount.parseMoney(),
        dateTime: selectedDate,
      );

      primaryAction(transaction);
    }
  }

  void submitSecondaryAction() {
    secondaryAction(_startTransaction);
  }

  void dispose() {
    _descriptionController.close();
    _amountController.close();
    _dateController.close();
    _iconController.close();
    _categoryNameController.close();
  }
}
