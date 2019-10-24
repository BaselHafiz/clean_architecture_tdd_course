import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  NetworkInfoImpl networkInfo;
  MockDataConnectionChecker mockDataConnectionChecker;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfo = NetworkInfoImpl(mockDataConnectionChecker);
  });

  group('isConnected', () {
    test(
      // We can check if the call to 'NetworkInfo().isConnected' is forwarded by checking if the Future object
      // returned by isConnected is exactly the same as the one returned by 'DataConnectionChecker().hasConnection'.
      'should forward the call to DataConnectionChecker.hasConnection',
          () async {
        // arrange
        // It's value is an 'instance of Future<bool>'
        final tHasConnectionFuture = Future.value(true);

        when(mockDataConnectionChecker.hasConnection)
            .thenAnswer((_) => tHasConnectionFuture);
        // act
        // NOTICE: We're NOT awaiting the result.
        // It's value is an 'instance of Future<bool>'
        final result = networkInfo.isConnected;

        // assert
        verify(mockDataConnectionChecker.hasConnection);
        // Utilizing Dart's default referential equality.
        // Only references to the same object are equal.
        expect(result, tHasConnectionFuture);
      },
    );
  });
}