import 'package:auto_size_text/auto_size_text.dart';
import 'package:financeplanner/dependency_injection_config.dart';
import 'package:financeplanner/extensions/extensions.dart';
import 'package:financeplanner/models/transaction.dart';
import 'package:financeplanner/views/widgets/logout_button.dart';
import 'package:financeplanner/views/widgets/transaction_list/transaction_list_viewmodel.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../app_localizations.dart';
import '../../detail_transaction_screen.dart';

class TransactionList extends StatelessWidget {
  final ScrollController scrollController;

  TransactionList({
    this.scrollController,
  });

  final OverlayEntry entry = OverlayEntry(builder: (context) {
    return Center(child: CircularProgressIndicator());
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TransactionListViewModel>.reactive(
      builder: (context, model, child) {
        if (model.busy(model.transactions)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return RefreshIndicator(
            child: CustomScrollView(
              controller: scrollController,
              semanticChildCount: model.amtTransactions,
              physics: AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 220.0,
                  flexibleSpace: FlexibleSpaceBar(
                      title: Transform.translate(
                        offset: const Offset(-40, 0),
                        child: Text(AppLocalizations.of(context).translate('overview')),
                      ),
                      background: Stack(
                        children: [
                          Positioned(
                            left: 16,
                            top: 16,
                            child: Container(
                              width: 128,
                              height: 48,
                              child: Hero(
                                tag: 'wallet',
                                child: FlareActor(
                                  'assets/animations/wallet.flr',
                                  animation: 'Idle',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  AppLocalizations.of(context).translate('balance'),
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.left,
                                  minFontSize: 30,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AutoSizeText(
                                  model.balance,
                                  style: TextStyle(color: model.balanceColor),
                                  textAlign: TextAlign.left,
                                  minFontSize: 50,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            child: LogoutButton(),
                            right: 8,
                            top: 8,
                          ),
                        ],
                      )),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return _TransactionListItem(index, model.transactions);
                    },
                    childCount: model.amtTransactions,
                  ),
                ),
              ],
            ),
            onRefresh: model.updateTransactionList,
          );
        }
      },
      viewModelBuilder: () => locator<TransactionListViewModel>(),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final int index;
  final List<Transaction> transactions;

  _TransactionListItem(this.index, this.transactions);

  @override
  Widget build(BuildContext context) {
    int current = index;
    int previous = index - 1;

    Transaction transaction = transactions[current];
    if (_isOnDifferentDayToPredecessor(transactions, current, previous)) {
      return _DividerTransactionItem(transaction);
    } else {
      return new _TransactionItem(transaction);
    }
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
}

class _DividerTransactionItem extends StatelessWidget {
  final Transaction transaction;

  _DividerTransactionItem(this.transaction);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            child: Text(
              _getDate(context, transaction.date),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
          ),
          const Divider(
            color: Colors.grey,
            height: 12,
            thickness: 1,
            indent: 4,
            endIndent: 16,
          ),
          Padding(
            child: _TransactionItem(transaction),
            padding: const EdgeInsets.only(top: 8),
          )
        ],
      ),
    );
  }

  String _getDate(BuildContext context, DateTime date) {
    DateTime now = DateTime.now();
    if (date.isAtSameMomentAs(new DateTime(now.year, now.month, now.day))) {
      return AppLocalizations.of(context).translate('today');
    }

    return date.toDateFormat();
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  _TransactionItem(this.transaction);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        transaction.category.icon,
        color: Colors.white,
        size: 30.0,
      ),
      title: AutoSizeText(
        transaction.description,
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.left,
        minFontSize: 14,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AutoSizeText(
        transaction.amount.toMoneyFormatWithSign(),
        style: TextStyle(fontWeight: FontWeight.bold, color: transaction.amount.toMoneyColor()),
        textAlign: TextAlign.right,
        minFontSize: 8,
        maxLines: 1,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailTransactionScreen(transaction: transaction),
          ),
        );
      },
    );
  }
}