library http_mocks.tests.mock;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_mocks/http_mocks.dart';
import 'package:test/test.dart';

void main() {
  group('HttpResponseMock:', () {
    test('it can verify response status code', () {
      var request = new HttpRequestMock(Uri.parse('/users'), 'GET');
      request.response.statusCode = HttpStatus.OK;
      request.response.statusCode = HttpStatus.NOT_FOUND;
      expect(request, responseStatus(HttpStatus.NOT_FOUND));
    });

    test('it can verify piped response body', () async {
      var request = new HttpRequestMock(Uri.parse('/users'), 'GET');
      var body = UTF8.encode('["user1", "user2"]');
      var stream = new Stream.fromIterable([body]);
      await stream.pipe(request.response);
      expect(request, responseBody(equals('["user1", "user2"]')));
    });

    test('it can verify response body from write() and writeln()', () {
      var request = new HttpRequestMock(Uri.parse('/users'), 'GET');
      request.response.writeln('user1');
      request.response.write('user2');
      expect(request, responseBody(equals('user1\nuser2')));
    });

    test('it can verify response body from writeAll()', () {
      var request = new HttpRequestMock(Uri.parse('/users'), 'GET');
      request.response.writeAll(['user1', 'user2'], '\n');
      expect(request, responseBody(equals('user1\nuser2')));
    });

    test('it can verify response has been sent (closed)', () async {
      var request = new HttpRequestMock(Uri.parse('/users'), 'GET');
      var body = UTF8.encode('["user1", "user2"]');
      var stream = new Stream.fromIterable([body]);
      await stream.pipe(request.response);
      expect(request, responseSent);

      var request2 = new HttpRequestMock(Uri.parse('/users'), 'GET');
      request2.response.close();
      expect(request2, responseSent);
    });
  });
}
