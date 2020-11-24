import 'dart:typed_data';

import 'package:pedantic/pedantic.dart';
import 'package:test/test.dart';
import 'package:dart_nats_client/dart_nats_client.dart';

void main() {
  group('all', () {
    test('simple', () async {
      var client = Client();
      unawaited(client.connect('localhost', retryInterval: 1));
      var sub = client.sub('subject1');
      client.pub('subject1', Uint8List.fromList('message1'.codeUnits));
      var msg = await sub.poll();
      client.close();
      expect(String.fromCharCodes(msg.data), equals('message1'));
    });
    test('await', () async {
      var client = Client();
      await client.connect('localhost');
      var sub = client.sub('subject1');
      var result = client.pub(
          'subject1', Uint8List.fromList('message1'.codeUnits),
          buffer: false);
      expect(result, true);

      var msg = await sub.poll();
      client.close();
      expect(String.fromCharCodes(msg.data), equals('message1'));
    });
    test('retry failed', () async {
      var client = Client();
      bool errorCaught = false;
      // Await connection
      await client
          .connect('blabla', retriesCount: 3, timeout: 1, retryInterval: 1)
          .catchError((Object error) {
        errorCaught = true;
      });
      // Expect error
      expect(errorCaught, true);
    });
  });
}
