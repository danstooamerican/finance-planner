// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:financeplanner/services/transactions_service.dart';
import 'package:financeplanner/views/widgets/transaction_form/transaction_form_viewmodel.dart';
import 'package:financeplanner/views/widgets/transaction_list/transaction_list_viewmodel.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  g.registerLazySingleton<TransactionService>(() => TransactionService());
  g.registerFactory<TransactionFormViewModel>(
      () => TransactionFormViewModel(g<TransactionService>()));
  g.registerFactory<TransactionListViewModel>(
      () => TransactionListViewModel(g<TransactionService>()));
}
