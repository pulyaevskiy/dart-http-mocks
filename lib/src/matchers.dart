part of http_mocks;

/// Checks if response status is the same as [expected].
Matcher responseStatus(int expected) => new _ResponseStatus(expected);

class _ResponseStatus extends Matcher {
  final int expectedStatus;

  _ResponseStatus(this.expectedStatus);

  @override
  Description describe(Description description) {
    return description
        .add('response status is ')
        .addDescriptionOf(expectedStatus);
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      mismatchDescription.add('response status is ');
      mismatchDescription.addDescriptionOf(item.responseMock.statusCode);
      return super
          .describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not an instance of HttpRequestMock');
    }
  }

  @override
  bool matches(item, Map matchState) {
    if (item is HttpRequestMock) {
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

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      if (item.responseMock.body == null) {
        mismatchDescription.add('response body is ').addDescriptionOf(null);
      } else {
        mismatchDescription.add('response body is\n').add('          ```\n');
        var lines = item.responseMock.body.split('\n');
        for (var line in lines) {
          mismatchDescription.add('          ${line}\n');
        }
        mismatchDescription.add('          ```');
      }

      return super
          .describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not an instance of HttpRequestMock');
    }
  }
}

/// Checks if `response.close()` has been called.
const Matcher responseSent = const _ResponseSent();

class _ResponseSent extends Matcher {
  const _ResponseSent();

  @override
  Description describe(Description description) {
    return description.add('response is closed');
  }

  @override
  bool matches(item, Map matchState) {
    if (item is HttpRequestMock) {
      return item.responseMock.isClosed;
    } else {
      return false;
    }
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      mismatchDescription.add('response is not closed');
      return super
          .describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not an instance of HttpRequestMock');
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
    return description
        .add('response content type is ')
        .addDescriptionOf(expected);
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      var actual = matchState['actualType'];
      mismatchDescription.add('response content type is ');
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
/// This will only validate headers that were set during handling of the
/// request. Any system suplied default headers are not reflected in the mock.
///
/// It is recommended to use `containsPair()` with this matcher.
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
      return matcher.matches(item.responseHeadersMock._headers, matchState);
    } else {
      return false;
    }
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is HttpRequestMock) {
      var actual = item.responseHeadersMock._headers;
      mismatchDescription.add('response headers are ');
      mismatchDescription.addDescriptionOf(actual);
      return super
          .describeMismatch(item, mismatchDescription, matchState, verbose);
    } else {
      return mismatchDescription.add('is not an instance of HttpRequestMock');
    }
  }
}
