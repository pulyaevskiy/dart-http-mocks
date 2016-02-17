part of http_mocks;

/// Mock for [HttpRequest].
class HttpRequestMock extends Mock implements HttpRequest {
  /// Mock for this request's headers.
  final HttpHeadersMock headersMock = new HttpHeadersMock();

  /// Response mock.
  final HttpResponseMock responseMock = new HttpResponseMock();

  /// Response headers mock.
  final HttpHeadersMock responseHeadersMock = new HttpHeadersMock();

  /// Creates new mock for [HttpRequest].
  HttpRequestMock(Uri uri, String method,
      {String body, Map<String, String> headers}) {
    when(this.requestedUri).thenReturn(uri);
    when(this.method).thenReturn(method);
    when(this.headers).thenReturn(headersMock);
    when(this.response).thenReturn(responseMock);
    when(this.responseMock.headers).thenReturn(responseHeadersMock);
    if (body is String) {
      var data = UTF8.encode(body);
      var stream = new Stream.fromIterable([data]);
      when(this.transform(argThat(anything)))
          .thenReturn(stream.transform(UTF8.decoder));
    }

    if (headers is Map && headers.isNotEmpty) {
      headersMock._headers.addAll(headers);
    }
  }
}

/// Mock for [HttpResponse].
class HttpResponseMock extends Mock implements HttpResponse {
  Future _closeFuture;
  int statusCode = HttpStatus.OK;

  String _body;

  /// Body of this response.
  String get body => _body;

  /// Returns `true` if response has been closed.
  bool get isClosed => _closeFuture is Future;

  @override
  void write(Object obj) {
    _body ??= '';
    _body += obj.toString();
  }

  @override
  void writeln([Object obj = ""]) {
    _body ??= '';
    _body += obj.toString() + '\n';
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = ""]) {
    _body ??= '';
    _body += objects.join(separator);
  }

  /// Override to handle situations when response body gets populated from
  /// another stream via `pipe()`.
  @override
  Future<dynamic> addStream(Stream<List<int>> stream) async {
    _body ??= '';
    _body += await UTF8.decodeStream(stream);
    return new Future.value();
  }

  @override
  Future close() {
    _closeFuture ??= new Future.value();
    return _closeFuture;
  }
}

/// Mock for [HttpHeaders].
///
/// Please note that it does not support multi-value headers.
class HttpHeadersMock extends Mock implements HttpHeaders {
  Map<String, String> _headers;
  HttpHeadersMock([Map<String, String> headers])
      : _headers = headers ?? new Map();

  @override
  List<String> operator [](String name) {
    return _headers.containsKey(name) ? [_headers[name]] : null;
  }

  @override
  String value(String name) {
    // TODO: for multi-value headers (when supported) this should throw an exception
    return _headers.containsKey(name) ? _headers[name] : null;
  }

  @override
  void add(String name, Object value) {
    // TODO: add value for multi-value headers instead of overwriting
    _headers[name] = value;
  }

  @override
  void set(String name, Object value) {
    // TODO: clear existing multi-value headers first.
    _headers[name] = value;
  }

  @override
  void forEach(void f(String name, List<String> values)) {
    _headers.forEach((k, v) {
      f(k, [v]);
    });
  }
}
