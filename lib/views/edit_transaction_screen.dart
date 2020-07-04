import 'package:financeplanner/dependency_injection_config.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/services/transactions_service.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'file:///C:/Users/danie/Documents/Projekte/finance-planner/lib/views/main_view/main_screen.dart';
import 'file:///C:/Users/danie/Documents/Projekte/finance-planner/lib/views/widgets/transaction_form/transaction_form.dart';

import '../app_localizations.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  EditTransactionScreen({Key key, this.transaction}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new EditTransactionState(transaction);
  }
}

class EditTransactionState extends State<EditTransactionScreen> {
  final TransactionService _transactionService = locator<TransactionService>();

  TransactionFormViewModel _transactionFormViewModel;

  EditTransactionState(Transaction transaction) {
    _transactionFormViewModel = locator<TransactionFormViewModel>();
    _transactionFormViewModel.initialize(transaction, editTransactionAction, deleteTransactionAction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('edit-transaction')),
      ),
      body: Padding(
        child: ViewModelBuilder.nonReactive(
          viewModelBuilder: () => _transactionFormViewModel,
          builder: (context, model, child) {
            return TransactionForm.filled(
              primaryActionText: AppLocalizations.of(context).translate('edit'),
              secondaryActionText: AppLocalizations.of(context).translate('delete'),
            );
          },
        ),
        padding: const EdgeInsets.only(top: 16),
      ),
    );
  }

  void editTransactionAction(Transaction transaction) {
    _transactionService.editTransaction(transaction);

    Navigator.pop(context, transaction);
  }

  void deleteTransactionAction(Transaction transaction) {
    _transactionService.deleteTransaction(transaction.id);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
        (Route<dynamic> route) => false);
  }
}
