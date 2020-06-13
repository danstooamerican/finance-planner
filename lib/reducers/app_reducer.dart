import 'package:financeplanner/actions/actions.dart';
import 'package:financeplanner/models/app_state.dart';
import 'package:redux/redux.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(counter: incrementReducer(state.counter, action));
}

final incrementReducer = TypedReducer<int, IncrementAction>(_incrementReducer);
int _incrementReducer(int counter, IncrementAction action) {
  return counter + 1;
}
