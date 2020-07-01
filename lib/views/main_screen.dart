import 'package:financeplanner/app_localizations.dart';
import 'package:financeplanner/middleware/middleware.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/views/add_transaction_screen.dart';
import 'package:financeplanner/views/widgets/transaction_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class MainScreen extends StatefulWidget {
  final Store<AppState> store;

  MainScreen({Key key, this.store}) : super(key: key) {
    store.dispatch(fetchTransactions());
  }

  @override
  State<StatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Offset> _offsetAnimation;
  ScrollController _scrollController = ScrollController();
  bool _fabIsVisible = true;

  @override
  void initState() {
    super.initState();

    this._animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    this._offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  MainScreenState() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_fabIsVisible == true && !_animationController.isAnimating) {
          _animationController.forward();
          _fabIsVisible = false;
        }
      } else {
        if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (_fabIsVisible == false && !_animationController.isAnimating) {
            _animationController.reverse();
            _fabIsVisible = true;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StoreProvider<AppState>(
        store: widget.store,
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
                store: widget.store,
                transactions: transactions,
                onRefresh: updateTransactionList,
                scrollController: _scrollController,
              );
            },
          ),
          floatingActionButton: SlideTransition(
            position: _offsetAnimation,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTransactionScreen(store: widget.store)),
                );
              },
              tooltip: AppLocalizations.of(context).translate('add-transaction'),
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> updateTransactionList() async {
    widget.store.dispatch(fetchTransactions());

    return null;
  }
}
