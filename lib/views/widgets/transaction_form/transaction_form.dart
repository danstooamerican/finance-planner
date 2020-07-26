import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/category.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../../../app_localizations.dart';

class TransactionForm extends HookViewModelWidget<TransactionFormViewModel> {
  final String primaryActionText;
  final String secondaryActionText;

  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey();

  TransactionForm.empty({
    Key key,
    @required this.primaryActionText,
    this.secondaryActionText,
  }) : super(key: key);

  TransactionForm.filled({
    Key key,
    @required this.primaryActionText,
    this.secondaryActionText,
  }) : super(key: key);

  @override
  Widget buildViewModelWidget(BuildContext context, TransactionFormViewModel model) {
    var description = useTextEditingController(text: model.description);
    var selectedDate = useTextEditingController(text: model.selectedDate.toDateFormat());
    var categoryName = useTextEditingController(text: model.categoryName);
    var amount = useTextEditingController(text: model.amount);

    useEffect(() {
      categoryName.text = model.categoryName;

      return null;
    }, [model.categoryName]);

    useEffect(() {
      selectedDate.text = model.selectedDate.toDateFormat();

      return null;
    }, [model.selectedDate]);

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
                    icon: Icon(model.selectedIcon),
                    padding: const EdgeInsets.only(right: 8),
                    iconSize: 48,
                    color: Colors.white,
                    onPressed: () => _pickIcon(context, model),
                  ),
                  Expanded(
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: categoryName,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: AppLocalizations.of(context)?.translate('category'),
                          ),
                          onChanged: (text) {
                            model.categoryName = text;
                          }),
                      itemBuilder: (context, suggestion) => ListTile(
                        title: Text(suggestion.name),
                        leading: Icon(suggestion.icon),
                      ),
                      suggestionsCallback: (pattern) {
                        List<Category> suggestions = List.from(model.categories);
                        suggestions
                            .retainWhere((element) => element.name.toLowerCase().startsWith(pattern.toLowerCase()));

                        return suggestions;
                      },
                      onSuggestionSelected: (suggestion) {
                        model.selectedCategory = suggestion;
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
                    ),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
            ),
            Padding(
              child: TextFormField(
                controller: selectedDate,
                focusNode: _dateFocus,
                onTap: () => _selectDate(context, model),
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
                controller: amount,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                maxLength: 9,
                focusNode: _amountFocus,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _amountFocus, _descriptionFocus);
                },
                onChanged: (String value) {
                  model.amount = value;
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
                controller: description,
                textInputAction: TextInputAction.next,
                focusNode: _descriptionFocus,
                maxLength: 255,
                minLines: 1,
                maxLines: 5,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _descriptionFocus, _categoryFocus);
                },
                onChanged: (String value) {
                  model.description = value;
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
                      onPressed: model.submitPrimaryAction,
                      child: Text(primaryActionText),
                    ),
                  ),
                ),
              ],
            ),
            if (model.secondaryAction != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: new RaisedButton(
                        color: Colors.red,
                        onPressed: model.submitSecondaryAction,
                        child: Text(secondaryActionText),
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

  void _selectDate(BuildContext context, TransactionFormViewModel model) async {
    final DateTime picked = await showDatePicker(
        context: context, initialDate: model.selectedDate, firstDate: DateTime(1900), lastDate: DateTime(2200));

    model.selectedDate = picked;

    _fieldFocusChange(context, _dateFocus, _amountFocus);
  }

  void _pickIcon(BuildContext context, TransactionFormViewModel model) async {
    IconData icon = await FlutterIconPicker.showIconPicker(context, iconPackMode: IconPack.material);

    model.selectedIcon = icon;
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
