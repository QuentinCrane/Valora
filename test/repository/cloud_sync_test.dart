import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

class _RealHttpOverrides extends HttpOverrides {
  HttpClient createRealClient(SecurityContext? context) =>
      super.createHttpClient(context);
}

Future<T> _withRealHttp<T>(Future<T> Function() body) {
  final overrides = _RealHttpOverrides();
  return HttpOverrides.runZoned(
    body,
    createHttpClient: overrides.createRealClient,
  );
}

class _FakeWebDav {
  HttpServer? _server;
  String body = '';
  String etag = '"v1"';
  int putCount = 0;
  int headCount = 0;
  bool requireAuth = false;

  Future<CloudSyncSettings> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unawaited(_server!.forEach(_handle));
    return CloudSyncSettings(
      provider: CloudSyncProvider.customWebdav,
      serverUrl: 'http://127.0.0.1:${_server!.port}/dav/',
      username: 'user',
      password: 'password',
      remotePath: 'backup.json',
    );
  }

  Future<void> _handle(HttpRequest request) async {
    final auth = request.headers.value(HttpHeaders.authorizationHeader);
    if (requireAuth && auth == null) {
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
      return;
    }
    switch (request.method) {
      case 'HEAD':
        headCount += 1;
        if (body.isEmpty) {
          request.response.statusCode = HttpStatus.notFound;
        } else {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.set(HttpHeaders.etagHeader, etag);
        }
        await request.response.close();
        return;
      case 'PUT':
        putCount += 1;
        final ifMatch = request.headers.value(HttpHeaders.ifMatchHeader);
        final ifNoneMatch =
            request.headers.value(HttpHeaders.ifNoneMatchHeader);
        if (body.isNotEmpty && ifMatch != etag) {
          request.response.statusCode = HttpStatus.preconditionFailed;
          await request.response.close();
          return;
        }
        if (body.isEmpty && ifNoneMatch != '*') {
          request.response.statusCode = HttpStatus.preconditionFailed;
          await request.response.close();
          return;
        }
        final bytes = await request
            .fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk));
        body = utf8.decode(bytes);
        etag = '"v${putCount + 1}"';
        request.response.statusCode = HttpStatus.noContent;
        request.response.headers.set(HttpHeaders.etagHeader, etag);
        await request.response.close();
        return;
      case 'GET':
        if (body.isEmpty) {
          request.response.statusCode = HttpStatus.notFound;
        } else {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.set(HttpHeaders.etagHeader, etag);
          request.response.add(utf8.encode(body));
        }
        await request.response.close();
        return;
      case 'PROPFIND':
        request.response.statusCode = 207;
        await request.response.close();
        return;
      default:
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
    }
  }

  Future<void> close() async {
    await _server?.close(force: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first upload uses If-None-Match and records a content summary',
      () async {
    final server = _FakeWebDav();
    final settings = await server.start();
    addTearDown(server.close);
    const service = CloudSyncService.test();
    const json = '{"assets":[],"wishes":[],"categories":[],"tags":[]}';

    final result = await _withRealHttp(() => service.upload(settings, json));

    expect(result.ok, isTrue);
    expect(result.contentHash, isNotEmpty);
    expect(result.remoteSummary?.assets, 0);
    expect(server.putCount, 1);
    expect(server.body, json);
  });

  test('unchanged upload is skipped and an ETag mismatch becomes a conflict',
      () async {
    final server = _FakeWebDav();
    final settings = await server.start();
    addTearDown(server.close);
    const service = CloudSyncService.test();
    const json = '{"assets":[],"wishes":[],"categories":[],"tags":[]}';

    final first = await _withRealHttp(() => service.upload(settings, json));
    final remembered = settings.copyWith(
      remoteEtag: first.etag,
      remoteContentHash: first.contentHash,
    );
    final skipped = await _withRealHttp(() => service.upload(remembered, json));
    expect(skipped.ok, isTrue);
    expect(skipped.skipped, isTrue);
    expect(server.putCount, 1);

    server.etag = '"changed-on-another-device"';
    final conflict =
        await _withRealHttp(() => service.upload(remembered, '{"assets":[1]}'));
    expect(conflict.ok, isFalse);
    expect(conflict.conflict, isTrue);
    expect(conflict.statusCode, 412);
    expect(server.putCount, 1);
  });

  test('download validates JSON and rejects insecure non-loopback endpoints',
      () async {
    final server = _FakeWebDav()..body = '{"assets":[],"wishes":[]}';
    final settings = await server.start();
    addTearDown(server.close);
    const service = CloudSyncService.test();

    final downloaded = await _withRealHttp(() => service.download(settings));
    expect(downloaded.ok, isTrue);
    expect(downloaded.payload, contains('assets'));
    expect(downloaded.remoteSummary?.wishes, 0);

    final unsafe = await const CloudSyncService().download(
      settings.copyWith(serverUrl: 'http://example.com/dav/'),
    );
    expect(unsafe.ok, isFalse);
  });
}
