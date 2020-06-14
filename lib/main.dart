import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/reducers/app_reducer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

void main() {
  final store = Store<AppState>(appReducer,
      initialState: AppState(transactions: new List()),
      middleware: [thunkMiddleware]);

  runApp(FinancePlanner(store: store, title: "Finance Planner"));
}

class FinancePlanner extends StatelessWidget {
  final Store<AppState> store;
  final String title;

  FinancePlanner({Key key, this.store, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: '$title',
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: StoreConnector<AppState, List<Transaction>>(
            converter: (Store<AppState> store) {
              return store.state.transactions;
            },
            builder: (BuildContext context, List<Transaction> transactions) {
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new TransactionItem(transactions[index]);
                  });
            },
          ),
          floatingActionButton: StoreConnector<AppState, VoidCallback>(
            converter: (store) {
              return () {
                store.dispatch(new IncrementAction());
              };
            },
            builder: (BuildContext context, VoidCallback callback) {
              return FloatingActionButton(
                onPressed: callback,
                tooltip: 'Increment',
                child: Icon(Icons.add),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  TransactionItem(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece of paper on which the UI appears.
    return Container(
      padding: const EdgeInsets.all(8),
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 30.0,
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  child: Text(
                    transaction.description,
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                )
              ],
            ),
            flex: 14,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getAmount(transaction.amount),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getAmountColor(transaction.amount)),
                  textAlign: TextAlign.right,
                )
              ],
            ),
            flex: 4,
          )
        ],
      ),
    );
  }

  String _getAmount(double amount) {
    NumberFormat f = NumberFormat.currency(locale: "de_DE", symbol: "€");

    return (amount > 0 ? "+" : "") + f.format(amount);
  }

  Color _getAmountColor(double amount) {
    if (amount < 0) {
      return Colors.red;
    } else if (amount == 0) {
      return Colors.white;
    } else {
      return Colors.green;
    }
  }
}
