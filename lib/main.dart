import 'package:financeplanner/models/app_state.dart';
import 'package:financeplanner/models/models.dart';
import 'package:financeplanner/reducers/app_reducer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'views/main_screen.dart';

void main() {
  final store =
      Store<AppState>(appReducer, initialState: AppState(transactions: new List()), middleware: [thunkMiddleware]);

  runApp(MaterialApp(
      title: 'Finance App',
      theme: ThemeData.dark(),
      home: MainScreen(
        store: store,
      )));
}
