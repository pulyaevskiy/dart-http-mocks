library http_mocks.tests.matchers;

import 'package:http_mocks/http_mocks.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseBody', () {
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
  });
}
