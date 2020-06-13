import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/reducers/app_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'middleware/middleware.dart';

void main() {
  final store = Store<AppState>(appReducer,
      initialState: AppState(counter: 0), middleware: [thunkMiddleware]);

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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Tichy announces:',
                  style: Theme.of(context).textTheme.headline3.merge(
                        TextStyle(color: Colors.white),
                      ),
                  textAlign: TextAlign.center,
                ),
                StoreConnector<AppState, String>(
                  converter: (Store<AppState> store) =>
                      store.state.counter.toString(),
                  builder: (BuildContext context, String counter) {
                    return Text(
                      "SWT " + '$counter',
                      style: Theme.of(context).textTheme.headline4.merge(
                            TextStyle(color: Colors.grey),
                          ),
                    );
                  },
                )
              ],
            ),
          ),
          floatingActionButton: StoreConnector<AppState, VoidCallback>(
            converter: (store) {
              return () {
                store.dispatch(accessDatabase(store.state.counter));
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
