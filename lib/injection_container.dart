import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';
import 'features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/bloc.dart';
/*
Using get_it, class types can be registered in 3 ways.

1. Factory: When you request an instance of the type from the SL, you'll get a new instance every time.
2. Non-lazy Singleton: Create the instance on registration at app start-up.
3. LazySingleton: Create the instance on the first time in which the object is requested, as creating the instance on registration can be
   time consuming at app start-up.

In 2 & 3, The SL keeps a single instance of your registered type and will always return you that instance.

We're going to register everything as a singleton, which means that only one instance of a class will be created per the app's lifetime.
There will be only one exception to this rule - the NumberTriviaBloc. Presentation logic holders such as Bloc shouldn't be registered as singletons.
They are very close to the UI and if your app has multiple pages between which you navigate, you probably want to do some cleanup
(like closing Streams of a Bloc) from the dispose() method of a StatefulWidget.

Having a singleton for classes with this kind of a disposal would lead to trying to use a presentation logic holder (such as Bloc) with closed Streams,
instead of creating a new instance with opened Streams whenever you'd try to get an object of that type from GetIt.
 */

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia
  //Bloc
  sl.registerFactory(() =>
      NumberTriviaBloc(concrete: sl(), random: sl(), inputConverter: sl()));
  // Use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // Repository
  // We cannot instantiate a contract (which is an abstract class). Instead, we have to instantiate the implementation of the repository.
  // This is possible by specifying a type parameter on the registerLazySingleton method.
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
      () => NumberTriviaRemoteDataSourceImpl(client: sl()));

  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
      () => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()));

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
}
