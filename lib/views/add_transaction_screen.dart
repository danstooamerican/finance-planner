import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../app_localizations.dart';
import '../dependency_injection_config.dart';

class AddTransactionScreen extends StatefulWidget {
  AddTransactionScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new AddTransactionState();
  }
}

class AddTransactionState extends State<AddTransactionScreen> {
  final TransactionService _transactionService = locator<TransactionService>();

  TransactionFormViewModel _transactionFormViewModel;

  AddTransactionState() {
    _transactionFormViewModel = locator<TransactionFormViewModel>();
    _transactionFormViewModel.initialize(
        Transaction(
          id: 0,
          amount: 0,
          category: null,
          dateTime: DateTime.now(),
          description: null,
        ),
        submitAction,
        null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('add-transaction')),
      ),
      body: Padding(
        child: ViewModelBuilder.nonReactive(
          viewModelBuilder: () => _transactionFormViewModel,
          builder: (context, model, child) {
            return TransactionForm.empty(
              primaryActionText: AppLocalizations.of(context).translate('save'),
            );
          },
        ),
        padding: const EdgeInsets.only(top: 16),
      ),
    );
  }

  void submitAction(Transaction transaction) {
    _transactionService.createTransaction(transaction);

    Navigator.pop(context);
  }
}
