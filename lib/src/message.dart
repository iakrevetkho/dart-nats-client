/// External packages
import 'dart:convert';
import 'dart:typed_data';

/// Internal packages

/// Local packages
import 'client.dart';

/// Message class
class Message {
  ///constructure
  Message(this.subject, this.sid, this.data, this._client, {this.replyTo});

  ///subscriber id auto generate by client
  final int sid;

  /// subject  and replyto
  final String subject, replyTo;
  final Client _client;

  ///payload of data in byte
  final Uint8List data;

  ///payload in string
  String get string => utf8.decode(data);

  ///Repond to message
  bool respond(Uint8List data) {
    if (replyTo == null || replyTo == '') return false;
    _client.pub(replyTo, data);
    return true;
  }

  ///Repond to string message
  bool respondString(String str) {
    return respond(utf8.encode(str));
  }
}
