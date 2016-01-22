library http_mocks.tests.matchers;

import 'dart:io';

import 'package:http_mocks/http_mocks.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseStatus:', () {
    test('it matches response status', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.statusCode = HttpStatus.NO_CONTENT;
      var matcher = responseStatus(HttpStatus.NO_CONTENT);
      var state = new Map();
      expect(matcher.matches(request, state), isTrue);
    });

    test('it describes itself', () {
      var matcher = responseStatus(HttpStatus.OK);
      var desc = new StringDescription();
      matcher.describe(desc);
      expect(desc.toString(), equals("response status is <200>"));
    });

    test('it describes mismatch', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.statusCode = HttpStatus.MOVED_TEMPORARILY;
      var matcher = responseStatus(HttpStatus.OK);
      var state = new Map();
      expect(matcher.matches(request, state), isFalse);

      var desc = new StringDescription();
      matcher.describeMismatch(request, desc, state, false);
      expect(desc.toString(), equals("response status is <302>"));
    });

    test('it describes mismatch for invalid input', () {
      var desc = new StringDescription();
      var matcher = responseStatus(HttpStatus.OK);
      matcher.describeMismatch('just string', desc, {}, false);
      expect(desc.toString(), equals("is not an instance of HttpRequestMock"));
    });
  });

  group('ResponseBody:', () {
    test('it matches response body', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.write('BODY');
      var matcher = responseBody(equals('BODY'));
      var state = new Map();
      expect(matcher.matches(request, state), isTrue);
    });

    test('it describes itself', () {
      var matcher = responseBody(contains('users'));
      var desc = new StringDescription();
      matcher.describe(desc);
      expect(desc.toString(), equals("response body that contains 'users'"));
    });

    test('it describes mismatch', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.write('BODY');
      var matcher = responseBody(contains('notThere'));
      var state = new Map();
      expect(matcher.matches(request, state), isFalse);

      var desc = new StringDescription();
      matcher.describeMismatch(request, desc, state, false);
      expect(
          desc.toString(),
          equals(
              "response body is\n          ```\n          BODY\n          ```"));
    });

    test('it describes mismatch for null body', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      var matcher = responseBody(contains('notThere'));
      var state = new Map();
      expect(matcher.matches(request, state), isFalse);

      var desc = new StringDescription();
      matcher.describeMismatch(request, desc, state, false);
      expect(desc.toString(), equals("response body is <null>"));
    });

    test('it describes mismatch for invalid input', () {
      var desc = new StringDescription();
      var matcher = responseBody(equals('foo'));
      matcher.describeMismatch('not a mock', desc, {}, false);
      expect(desc.toString(), equals("is not an instance of HttpRequestMock"));
    });
  });

  group('ResponseSent:', () {
    test('it matches if response has been closed', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.close();
      var matcher = responseSent;
      expect(matcher.matches(request, {}), isTrue);
    });

    test('it describes itself', () {
      var matcher = responseSent;
      var desc = new StringDescription();
      matcher.describe(desc);
      expect(desc.toString(), equals("response is closed"));
    });

    test('it describes mismatch', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      var matcher = responseSent;
      expect(matcher.matches(request, {}), isFalse);

      var desc = new StringDescription();
      matcher.describeMismatch(request, desc, {}, false);
      expect(desc.toString(), equals("response is not closed"));
    });

    test('it describes mismatch for invalid input', () {
      var desc = new StringDescription();
      var matcher = responseSent;
      matcher.describeMismatch('just string', desc, {}, false);
      expect(desc.toString(), equals("is not an instance of HttpRequestMock"));
    });
  });

  group('ResponseContentType:', () {
    test('it matches response content type', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.headers.contentType = ContentType.BINARY;
      request.response.headers.contentType = ContentType.JSON;
      var matcher = responseContentType(ContentType.JSON);
      expect(matcher.matches(request, {}), isTrue);
    });

    test('it describes itself', () {
      var matcher = responseContentType(ContentType.JSON);
      var desc = new StringDescription();
      matcher.describe(desc);
      expect(
          desc.toString(),
          equals(
              "response content type is ?:<application/json; charset=utf-8>"));
    });

    test('it describes mismatch', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.headers.contentType = ContentType.TEXT;
      var matcher = responseContentType(ContentType.JSON);
      var state = {};
      expect(matcher.matches(request, state), isFalse);

      var desc = new StringDescription();
      matcher.describeMismatch(request, desc, state, false);
      expect(desc.toString(),
          equals("response content type is ?:<text/plain; charset=utf-8>"));
    });

    test('it describes mismatch for invalid input', () {
      var desc = new StringDescription();
      var matcher = responseContentType(ContentType.JSON);
      matcher.describeMismatch('not a request', desc, {}, false);
      expect(desc.toString(), equals("is not an instance of HttpRequestMock"));
    });
  });

  group('ResponseHeaders:', () {
    test('it matches response header', () {
      var matcher = responseHeaders(containsPair('WWW-Authenticate', 'Basic'));

      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.headers.add('WWW-Authenticate', 'Basic');
      expect(matcher.matches(request, {}), isTrue);

      request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.headers.set('WWW-Authenticate', 'Basic');
      expect(matcher.matches(request, {}), isTrue);
    });

    test('it describes itself', () {
      var matcher = responseHeaders(containsPair('WWW-Authenticate', 'Basic'));
      var desc = new StringDescription();
      matcher.describe(desc);
      expect(
          desc.toString(),
          equals(
              "response headers that contains pair \'WWW-Authenticate\' => \'Basic\'"));
    });

    test('it describes mismatch', () {
      var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
      request.response.headers.add('X-Foo', 'Bar');
      var matcher = responseHeaders(containsPair('WWW-Authenticate', 'Basic'));
      expect(matcher.matches(request, {}), isFalse);

      var desc = new StringDescription();
      matcher.describeMismatch(request, desc, {}, false);
      expect(
          desc.toString(), equals("response headers are {\'X-Foo\': \'Bar\'}"));
    });

    test('it describes mismatch for invalid input', () {
      var desc = new StringDescription();
      var matcher = responseHeaders(containsPair('WWW-Authenticate', 'Basic'));
      matcher.describeMismatch('not a request', desc, {}, false);
      expect(desc.toString(), equals("is not an instance of HttpRequestMock"));
    });
  });
}
