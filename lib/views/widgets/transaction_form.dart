import 'dart:convert';

import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:redux/redux.dart';

import '../../app_localizations.dart';

class TransactionForm extends StatefulWidget {
  final Transaction transaction;
  final Store<AppState> store;

  final String primaryActionText;
  final String secondaryActionText;

  final Function(Transaction) primaryAction;

  //// No form checks are performed before this action is called.
  final Function(Transaction) secondaryAction;

  factory TransactionForm.empty(
      {Key key,
      @required Store store,
      @required Function(Transaction) primaryAction,
      Function(Transaction) secondaryAction,
      @required String primaryText,
      String secondaryText}) {
    Transaction transaction = new Transaction(
      id: 0, // keep 0 as default id so the backend can recognize it as new
      category: null,
      description: null,
      amount: null,
      dateTime: DateTime.now(),
    );

    return TransactionForm.filled(
      key: key,
      store: store,
      transaction: transaction,
      primaryAction: primaryAction,
      secondaryAction: secondaryAction,
      primaryActionText: primaryText,
      secondaryActionText: secondaryText,
    );
  }

  TransactionForm.filled({
    Key key,
    @required this.store,
    @required this.transaction,
    @required this.primaryAction,
    this.secondaryAction,
    @required this.primaryActionText,
    @required this.secondaryActionText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new TransactionFormState(transaction);
  }
}

class TransactionFormState extends State<TransactionForm> {
  DateTime selectedDate = DateTime.now();

  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  TextEditingController _categoryController = new TextEditingController();

  Category _selectedCategory;
  List<Category> _categories = List();
  IconData _selectedIcon = Icons.category;

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();

  final Transaction transaction;

  final GlobalKey<FormState> _formKey = GlobalKey();

  final _prefixMoneyRegex = new RegExp(r'^-?(([1-9][0-9]*|0)(\,|\.)?)?([0-9]{1,2})?$');
  String previousAmountText;
  TextSelection previousAmountSelection;

  TransactionFormState(this.transaction) {
    _amountController.addListener(() {
      final String currentValue = _amountController.text;

      if (currentValue.length > 0 && _prefixMoneyRegex.matchAsPrefix(currentValue) == null) {
        _amountController.value = TextEditingValue(text: previousAmountText, selection: previousAmountSelection);
      } else {
        previousAmountText = currentValue;
        previousAmountSelection = _amountController.selection;
      }
    });

    previousAmountText = _amountController.text;
    previousAmountSelection = _amountController.selection;

    _setDate(transaction.date);
    _amountController.text = transaction.amount?.formatMoneyToEdit();
    _descriptionController.text = transaction.description;

    getCategories().then((value) {
      Iterable list = json.decode(utf8.decode(value.bodyBytes));
      setState(() {
        _categories = list.map((model) => Category.fromJson(model)).toList();

        if (transaction.category != null) {
          _selectCategory(transaction.category);
        } else if (_categories.isNotEmpty) {
          _selectCategory(_categories.first);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_selectedIcon),
                    padding: const EdgeInsets.only(right: 8),
                    iconSize: 48,
                    color: Colors.white,
                    onPressed: _pickIcon,
                  ),
                  Expanded(
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalizations.of(context).translate('category'),
                        ),
                      ),
                      itemBuilder: (context, suggestion) => ListTile(
                        title: Text(suggestion.name),
                        leading: Icon(suggestion.icon),
                      ),
                      suggestionsCallback: (pattern) {
                        List<Category> suggestions = List.from(_categories);
                        suggestions
                            .retainWhere((element) => element.name.toLowerCase().startsWith(pattern.toLowerCase()));

                        return suggestions;
                      },
                      onSuggestionSelected: (suggestion) {
                        setState(() {
                          _selectCategory(suggestion);
                        });
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      getImmediateSuggestions: true,
                      loadingBuilder: (context) => null,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return AppLocalizations.of(context).translate('category-required');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextFormField(
                controller: _dateController,
                focusNode: _dateFocus,
                onTap: () => _selectDate(context),
                keyboardType: TextInputType.number,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate('date'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('date-required');
                  }
                  return null;
                },
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLength: 9,
                focusNode: _amountFocus,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _amountFocus, _descriptionFocus);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate('amount'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('amount-required');
                  }

                  if (!text.isMoney()) {
                    return AppLocalizations.of(context).translate('amount-invalid');
                  }

                  return null;
                },
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextFormField(
                controller: _descriptionController,
                textInputAction: TextInputAction.next,
                focusNode: _descriptionFocus,
                maxLength: 255,
                minLines: 1,
                maxLines: 5,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _descriptionFocus, _categoryFocus);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context).translate('description'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('description-required');
                  }
                  return null;
                },
              ),
              padding: const EdgeInsets.all(8),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: new RaisedButton(
                      onPressed: submitPrimaryAction,
                      child: Text(widget.primaryActionText),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.secondaryAction != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: new RaisedButton(
                        color: Colors.red,
                        onPressed: submitSecondaryAction,
                        child: Text(widget.secondaryActionText),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void submitPrimaryAction() {
    if (_formKey.currentState.validate() &&
        _categoryController.text != null &&
        _categoryController.text.trim().isNotEmpty) {
      int categoryId = 0;
      if (_selectedCategory != null && _categoryController.text == _selectedCategory.name) {
        categoryId = _selectedCategory.id;
      }

      Category category = Category(id: categoryId, name: _categoryController.text, icon: _selectedIcon);

      final Transaction transaction = Transaction(
        id: widget.transaction.id,
        category: category,
        description: _descriptionController.text.trim(),
        amount: _amountController.text.parseMoney(),
        dateTime: selectedDate,
      );

      widget.primaryAction(transaction);
    }
  }

  void submitSecondaryAction() {
    widget.secondaryAction(transaction);
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2200));

    if (picked != null && picked != selectedDate) {
      setState(() {
        _setDate(picked);
      });
    }

    _fieldFocusChange(context, _dateFocus, _amountFocus);
  }

  void _setDate(DateTime date) {
    selectedDate = date;
    _dateController.text = date.toDateFormat();
  }

  void _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context, iconPackMode: IconPack.material);

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;

        if (_selectedCategory != null) {
          _selectCategory(Category(id: _selectedCategory.id, name: _selectedCategory.name, icon: icon));
        }
      });
    }
  }

  void _selectCategory(Category category) {
    if (category != null) {
      _selectedCategory = category;
      _categoryController.text = category.name;
      _selectedIcon = category.icon;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
