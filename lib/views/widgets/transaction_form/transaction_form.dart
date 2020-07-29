import 'package:financeplanner/app_localizations.dart';
import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TransactionForm extends StatefulWidget {
  final Function(Transaction) primaryAction;
  final String primaryActionText;

  final Function(Transaction) secondaryAction;
  final String secondaryActionText;

  final Transaction transaction;

  TransactionForm({
    this.transaction,
    this.primaryAction,
    this.primaryActionText,
    this.secondaryAction,
    this.secondaryActionText,
  });

  @override
  State<StatefulWidget> createState() {
    return new TransactionFormState(
      new TransactionFormViewModel(
        transaction,
        primaryAction,
        secondaryAction,
      ),
    );
  }
}

class TransactionFormState extends State<TransactionForm> {
  final TransactionFormViewModel viewModel;

  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();

  final TextEditingController _amountController = new TextEditingController();
  final TextEditingController _descriptionController = new TextEditingController();
  final TextEditingController _categoryController = new TextEditingController();
  final TextEditingController _dateController = new TextEditingController();

  TransactionFormState(this.viewModel);

  @override
  void initState() {
    _descriptionController.text = viewModel.description;
    _descriptionController.addListener(() => viewModel.inputDescription.add(_descriptionController.text));

    _amountController.text = viewModel.amount;
    _amountController.addListener(() => viewModel.inputAmount.add(_amountController.text));

    _dateController.text = viewModel.selectedDate.toDateFormat();

    viewModel.outputDate.listen((event) {
      _dateController.text = event.toDateFormat();
    });

    _categoryController.text = viewModel.categoryName;
    _categoryController.addListener(() => viewModel.inputCategoryName.add(_categoryController.text));

    super.initState();
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
                  StreamBuilder(
                    builder: (context, snapshot) {
                      return IconButton(
                        icon: Icon(viewModel.selectedIcon),
                        padding: const EdgeInsets.only(right: 8),
                        iconSize: 48,
                        color: Colors.white,
                        onPressed: () => _pickIcon(context),
                      );
                    },
                    stream: viewModel.outputIcon,
                  ),
                  Expanded(
                    child: StreamBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.data != _categoryController.text) {
                          _categoryController.text = snapshot.data;
                        }

                        return TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: AppLocalizations.of(context)?.translate('category'),
                            ),
                          ),
                          itemBuilder: (context, suggestion) => ListTile(
                            title: Text(suggestion.name),
                            leading: Icon(suggestion.icon),
                          ),
                          suggestionsCallback: (pattern) {
                            List<Category> suggestions = List.from(viewModel.categories);
                            suggestions
                                .retainWhere((element) => element.name.toLowerCase().startsWith(pattern.toLowerCase()));

                            return suggestions;
                          },
                          onSuggestionSelected: (suggestion) {
                            _categoryController.text = suggestion.name;
                            viewModel.inputIcon.add(suggestion.icon);
                          },
                          transitionBuilder: (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          getImmediateSuggestions: true,
                          loadingBuilder: (context) => null,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return AppLocalizations.of(context)?.translate('category-required');
                            }
                            return null;
                          },
                        );
                      },
                      stream: viewModel.outputCategoryName,
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
                  labelText: AppLocalizations.of(context)?.translate('date'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context)?.translate('date-required');
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
                  labelText: AppLocalizations.of(context)?.translate('amount'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context)?.translate('amount-required');
                  }

                  if (!text.isMoney()) {
                    return AppLocalizations.of(context)?.translate('amount-invalid');
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
                  labelText: AppLocalizations.of(context)?.translate('description'),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return AppLocalizations.of(context)?.translate('description-required');
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
                      onPressed: viewModel.submitPrimaryAction,
                      child: Text(widget.primaryActionText),
                    ),
                  ),
                ),
              ],
            ),
            if (viewModel.secondaryAction != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: new RaisedButton(
                        color: Colors.red,
                        onPressed: viewModel.submitSecondaryAction,
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

  void submitPrimaryAction(TransactionFormViewModel model) {
    if (_formKey.currentState.validate()) {
      model.submitPrimaryAction();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );

    viewModel.inputDate.add(picked);

    _fieldFocusChange(context, _dateFocus, _amountFocus);
  }

  void _pickIcon(BuildContext context) async {
    IconData icon = await FlutterIconPicker.showIconPicker(context, iconPackMode: IconPack.material);

    viewModel.inputIcon.add(icon);
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();

    super.dispose();
  }
}
