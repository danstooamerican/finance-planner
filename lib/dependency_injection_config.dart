import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependency_injection_config.iconfig.dart';

final locator = GetIt.instance;

@injectableInit
void setupLocator() => $initGetIt(locator);
