import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/views/add_transaction_screen.dart';
import 'package:financeplanner/views/widgets/transaction_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class MainScreen extends StatelessWidget {
  final Store<AppState> store;

  MainScreen({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StoreProvider<AppState>(
        store: store,
        child: Scaffold(
          body: StoreConnector<AppState, List<Transaction>>(
            converter: (Store<AppState> store) {
              List<Transaction> sorted = store.state.transactions;
              sorted.sort((t1, t2) {
                int dateCompare = t2.dateTime.compareTo(t1.dateTime);

                if (dateCompare == 0) {
                  return t2.id.compareTo(t1.id);
                }

                return dateCompare;
              });

              return sorted;
            },
            builder: (BuildContext context, List<Transaction> transactions) {
              return TransactionList(
                store: store,
                transactions: transactions,
                onRefresh: updateTransactionList,
              );
            },
          ),
          floatingActionButton: (FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTransactionScreen(store: store)),
              );
            },
            tooltip: 'Add Transaction',
            child: Icon(Icons.add),
          )),
        ),
      ),
    );
  }

  Future<Null> updateTransactionList() async {
    store.dispatch(fetchTransactions());

    return null;
  }
}
