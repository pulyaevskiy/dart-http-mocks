part of http_mocks;

/// Checks if response status is the same as [statusCode].
Matcher responseStatus(int statusCode) => new _ResponseStatus(statusCode);

class _ResponseStatus extends Matcher {
  final int expectedStatus;

  _ResponseStatus(this.expectedStatus);

  @override
  Description describe(Description description) {
    return description.add('response status ').addDescriptionOf(expectedStatus);
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      var actual = matchState['actualStatus'];
      mismatchDescription.add('response status ');
      mismatchDescription.addDescriptionOf(actual);
      return super
          .describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not an instance of HttpResponseMock');
    }
  }

  @override
  bool matches(item, Map matchState) {
    if (item is HttpRequestMock) {
      matchState['actualStatus'] = item.responseMock.statusCode;

      return (item.responseMock.statusCode == expectedStatus);
    } else {
      return false;
    }
  }
}

/// Checks if response body matches with provided [matcher].
Matcher responseBody(Matcher matcher) => new _ResponseBody(matcher);

class _ResponseBody extends Matcher {
  final Matcher matcher;

  _ResponseBody(this.matcher);

  @override
  Description describe(Description description) {
    return description.add('response body that ').addDescriptionOf(matcher);
  }

  @override
  bool matches(item, Map matchState) {
    if (item is HttpRequestMock) {
      var body = item.responseMock.body;
      return matcher.matches(body, matchState);
    } else {
      return false;
    }
  }
}

/// Checks if `response.close()` has been called.
const Matcher responseSent = const _ResponseSent();

class _ResponseSent extends Matcher {
  const _ResponseSent();

  @override
  Description describe(Description description) {
    return description.add('response has been sent');
  }

  @override
  bool matches(item, Map matchState) {
    if (item is HttpRequestMock) {
      return (item.responseMock.isClosed);
    } else {
      return false;
    }
  }
}

/// Checks if response's ContentType equals [expected] value.
Matcher responseContentType(ContentType expected) =>
    new _ResponseContentType(expected);

class _ResponseContentType extends Matcher {
  final ContentType expected;

  _ResponseContentType(this.expected);

  @override
  Description describe(Description description) {
    return description.add('response content type ').addDescriptionOf(expected);
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      var actual = matchState['actualType'];
      mismatchDescription.add('response content type ');
      mismatchDescription.addDescriptionOf(actual);
      return super
          .describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not an instance of HttpRequestMock');
    }
  }

  @override
  bool matches(item, Map matchState) {
    if (item is HttpRequestMock) {
      var actual = verify(item.responseHeadersMock.contentType = captureAny)
          .captured
          .last;
      matchState['actualType'] = actual;

      return (actual == expected);
    } else {
      return false;
    }
  }
}

/// Checks if response's headers match with provided [matcher].
///
/// It is recommended to use `containsPair()` matcher. Behavior of `equals`
/// matcher may not be consistent.
Matcher responseHeaders(Matcher matcher) => new _ResponseHeaders(matcher);

class _ResponseHeaders extends Matcher {
  final Matcher matcher;

  _ResponseHeaders(this.matcher);

  @override
  Description describe(Description description) {
    return description.add('response headers that ').addDescriptionOf(matcher);
  }

  @override
  bool matches(item, Map matchState) {
    if (item is HttpRequestMock) {
      var args = verify(item.responseHeadersMock.add(captureAny, captureAny))
          .captured
          .toList();
      var hasMatch = false;
      var actualHeaders = new List();
      while (args.isNotEmpty) {
        var key = args.removeAt(0);
        var value = args.removeAt(0);
        actualHeaders.add({key: value});
        if (matcher.matches({key: value}, matchState)) {
          hasMatch = true;
        }
      }
      matchState['actualHeaders'] = actualHeaders;
      return hasMatch;
    } else {
      return false;
    }
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      var actual = matchState['actualHeaders'];
      mismatchDescription.add('response headers contains ');
      mismatchDescription.addDescriptionOf(actual);
      return super
          .describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not an instance of HttpRequestMock');
    }
  }
}
