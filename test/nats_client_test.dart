/// External packages
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

/// Internal packages
import 'package:dart_nats_client/dart_nats_client.dart';

/// Local packages

void main() {
  group('all', () {
    test('simple', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      client.pub(subject, Uint8List.fromList('message1'.codeUnits));
      var msg = await sub.poll();
      client.close();
      expect(String.fromCharCodes(msg.data), equals('message1'));
    });
    test('newInbox', () {
      //just loop generate with out error
      var nuid = Nuid();
      var i = 0;
      for (i = 0; i < 100000; i++) {
        nuid.next();
        newInbox();
      }
      expect(i, 100000);
    });
    test('pub with Uint8List', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      var msgByte = Uint8List.fromList([1, 2, 3, 129, 130]);
      client.pub(subject, msgByte);
      var msg = await sub.poll();
      client.close();
      print(msg.data);
      expect(msg.data, equals(msgByte));
    });
    test('pub with Uint8List include return and  new line', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      var msgByte = Uint8List.fromList(
          [1, 10, 3, 13, 10, 13, 130, 1, 10, 3, 13, 10, 13, 130]);
      client.pub(subject, msgByte);
      var msg = await sub.poll();
      client.close();
      print(msg.data);
      expect(msg.data, equals(msgByte));
    });
    test('byte huge data', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      var msgByte = Uint8List.fromList(
          List<int>.generate(1024 + 1024 * 4, (i) => i % 256));
      client.pub(subject, msgByte);
      var msg = await sub.poll();
      client.close();
      print(msg.data);
      expect(msg.data, equals(msgByte));
    });
    test('UTF8', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      var thaiString = utf8.encode('ทดสอบ');
      client.pub(subject, thaiString);
      var msg = await sub.poll();
      client.close();
      print(msg.data);
      expect(msg.data, equals(thaiString));
    });
    test('pubString ascii', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      client.pubString(subject, 'testtesttest');
      var msg = await sub.poll();
      client.close();
      print(msg.data);
      expect(msg.string, equals('testtesttest'));
    });
    test('pubString Thai', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      client.pubString(subject, 'ทดสอบ');
      var msg = await sub.poll();
      client.close();
      print(msg.data);
      expect(msg.string, equals('ทดสอบ'));
    });
    test('pub with no buffer ', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      await Future.delayed(Duration(seconds: 1));
      client.pubString(subject, 'message1', buffer: false);
      var msg = await sub.poll();
      client.close();
      expect(msg.string, equals('message1'));
    });
    test('multiple sub ', () async {
      // Generate random subject
      var subject1 = Uuid().v4();
      var subject2 = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub1 = client.sub(subject1);
      var sub2 = client.sub(subject2);
      await Future.delayed(Duration(seconds: 1));
      client.pubString(subject1, 'message1');
      client.pubString(subject2, 'message2');
      var msg1 = await sub1.poll();
      var msg2 = await sub2.poll();
      client.close();
      expect(msg1.string, equals('message1'));
      expect(msg2.string, equals('message2'));
    });
    test('Wildcard sub * ', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub('$subject.*');
      client.pubString('$subject.1', 'message1');
      client.pubString('$subject.2', 'message2');
      var msgStream = sub.getStream().asBroadcastStream();
      var msg1 = await msgStream.first;
      var msg2 = await msgStream.first;
      client.close();
      expect(msg1.string, equals('message1'));
      expect(msg2.string, equals('message2'));
    });
    test('Wildcard sub > ', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub('$subject.>');
      client.pubString('$subject.a.1', 'message1');
      client.pubString('$subject.b.2', 'message2');
      var msgStream = sub.getStream().asBroadcastStream();
      var msg1 = await msgStream.first;
      var msg2 = await msgStream.first;
      client.close();
      expect(msg1.string, equals('message1'));
      expect(msg2.string, equals('message2'));
    });
    test('unsub after connect', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      client.pubString(subject, 'message1');
      var msg = await sub.poll();
      client.unSub(sub);
      expect(msg.string, equals('message1'));

      sub = client.sub(subject);
      client.pubString(subject, 'message1');
      msg = await sub.poll();
      sub.unSub();
      expect(msg.string, equals('message1'));

      client.close();
    });
    test('unsub before connect', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      client.unSub(sub);

      sub = client.sub(subject);
      sub.unSub();
      client.close();
      expect(1, 1);
    });
    test('get max payload', () async {
      var client = Client();
      await client.connect('localhost');

      //todo wait for connected
      await Future.delayed(Duration(seconds: 2));
      var max = client.maxPayload();
      client.close();

      expect(max, isNotNull);
    });
    test('sub continuous msg', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      var r = 0;
      var iteration = 100;
      sub.getStream().listen((msg) {
        print(msg.string);
        r++;
      });
      for (var i = 0; i < iteration; i++) {
        client.pubString(subject, i.toString());
        // await Future.delayed(Duration(milliseconds: 10));
      }
      await Future.delayed(Duration(seconds: 1));
      client.close();
      expect(r, equals(iteration));
    });
    test('sub defect 13 binary', () async {
      // Generate random subject
      var subject = Uuid().v4();

      var client = Client();
      await client.connect('localhost');
      var sub = client.sub(subject);
      var r = 0;
      var iteration = 100;
      sub.getStream().listen((msg) {
        print(msg.string);
        r++;
      });
      for (var i = 0; i < iteration; i++) {
        client.pub(subject, Uint8List.fromList([10, 13, 10]));
        // await Future.delayed(Duration(milliseconds: 10));
      }
      await Future.delayed(Duration(seconds: 1));
      client.close();
      expect(r, equals(iteration));
    });
  });
}
