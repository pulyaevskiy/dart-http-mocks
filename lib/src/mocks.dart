part of http_mocks;

/// Mock for [HttpRequest].
class HttpRequestMock extends Mock implements HttpRequest {
  final HttpHeadersMock headersMock = new HttpHeadersMock();
  final HttpResponseMock responseMock = new HttpResponseMock();
  final HttpHeadersMock responseHeadersMock = new HttpHeadersMock();

  HttpRequestMock(Uri uri, String method,
      {String body, Map<String, dynamic> headers}) {
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
      for (var key in headers.keys) {
        if (headers[key] is String) {
          when(headersMock.value(key)).thenReturn(headers[key]);
          when(headersMock[key]).thenReturn([headers[key]]);
        } else if (headers[key] is List) {
          when(headersMock[key]).thenReturn(headers[key]);
        } else {
          throw new ArgumentError.value(headers, 'headers',
              'Header value can only be string or list of strings');
        }
      }
    }
  }
}

/// Mock for [HttpResponse].
class HttpResponseMock extends Mock implements HttpResponse {
  Future _closeFuture;
  int statusCode = HttpStatus.OK;

  String _body;

  String get body => _body;

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
class HttpHeadersMock extends Mock implements HttpHeaders {}
