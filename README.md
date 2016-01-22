# Mocks for dart:io HTTP requests

Mocks and special test matchers to simplify testing of HttpRequests
from `dart:io`.

## 1. Usage

```dart
// file: some_test.dart
library some_lib.tests;

import 'package:test/test.dart';
import 'package:http_mocks/http_mocks.dart';

void main() {
  test('it mocks http requests', () async {
    var request = new HttpRequestMock(Uri.parse('/hello-world'), 'GET');
    // Pass it to your HTTP server or whatever else accepts HttpRequest
    // as an input argument:
    await yourHttpServer.handle(request);

    // Use provided matchers:
    expect(request, responseStatus(HttpStatus.OK));
    expect(request, responseContentType(ContentType.TEXT));
    expect(request,
      responseHeaders(containsPair('Access-Control-Allow-Origin', '*')));
    expect(request, responseBody(contains('Hello world!')));
    expect(request, responseSent); // makes sure request has been "closed".
  });
}
```

## 2. How it works

Under the hood this library uses
[mockito](https://pub.dartlang.org/packages/mockito) to create all the mocks.
All mocks are available through `HttpRequestMock` so it is possible
to perform custom expectations or verifications provided by `mockito`
library.

```dart
var request = new HttpRequestMock(Uri.parse('/foo'), 'GET');
request.headersMock; // mock for request's headers
request.responseMock; // mock for HttpResponse
request.responseHeadersMock; // mock for response's headers
```

## 3. Limitations

Current implementation only covers only a subset of all possible use cases,
though hopefully the most common ones. This means that not all the expectations
can be performed.

Also, the `HttpHeadersMock` does not support "multi-value" headers at
this moment (but this can be added in the future, of course).

If you find a use case which is not covered, feel free to create an issue or a
pull request!

## License

BSD-2
