import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/views/add_transaction_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class MainScreen extends StatelessWidget {
  final Store<AppState> store;

  MainScreen({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Overview"),
        ),
        body: StoreConnector<AppState, List<Transaction>>(
          converter: (Store<AppState> store) {
            List<Transaction> sorted = store.state.transactions;
            sorted.sort((t1, t2) => t2.dateTime.compareTo(t1.dateTime));

            return sorted;
          },
          builder: (BuildContext context, List<Transaction> transactions) {
            return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: transactions.length,
                itemBuilder: (BuildContext context, int index) {
                  int current = index;
                  int previous = index - 1;

                  Transaction transaction = transactions[current];
                  if (_isOnDifferentDayToPredecessor(transactions, current, previous)) {
                    return new Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              child: Text(
                                _getDate(transaction.date),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0)),
                          const Divider(
                            color: Colors.grey,
                            height: 12,
                            thickness: 1,
                            endIndent: 8,
                          ),
                          Padding(
                            child: TransactionItem(transaction),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          )
                        ],
                      ),
                    );
                  } else {
                    return new TransactionItem(transaction);
                  }
                });
          },
        ),
        floatingActionButton: (FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTransactionScreen(store: store)),
            );
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        )),
      ),
    );
  }

  bool _isOnDifferentDayToPredecessor(List<Transaction> transactions, int currentIndex, int previousIndex) {
    if (currentIndex == 0) {
      return true;
    }

    if (currentIndex < 0 ||
        currentIndex >= transactions.length ||
        previousIndex < 0 ||
        previousIndex >= transactions.length) {
      return false;
    }

    Transaction current = transactions[currentIndex];
    Transaction previous = transactions[previousIndex];

    return current.date.isOnDifferentDay(previous.date);
  }

  String _getDate(DateTime date) {
    DateTime now = DateTime.now();
    if (date.isAtSameMomentAs(new DateTime(now.year, now.month, now.day))) {
      return "Today";
    }

    return date.toDateFormat();
  }
}

class TransactionItem extends StatelessWidget {
  TransactionItem(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
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
                  child: AutoSizeText(
                    transaction.description,
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.left,
                    minFontSize: 14,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                AutoSizeText(
                  transaction.amount.toMoneyFormatWithSign(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: _getAmountColor(transaction.amount)),
                  textAlign: TextAlign.right,
                  minFontSize: 8,
                  maxLines: 1,
                )
              ],
            ),
            flex: 4,
          )
        ],
      ),
    );
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
