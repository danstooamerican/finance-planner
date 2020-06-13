import 'package:meta/meta.dart';

@immutable
class AppState {
  final int counter;

  const AppState({
    @required this.counter,
  });
}
