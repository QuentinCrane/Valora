import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  test('serializes 100 CRUD revisions without dropping the final snapshot',
      () async {
    final writes = <int>[];
    var activeWriters = 0;
    var maximumActiveWriters = 0;
    final coordinator = SaveCoordinator(
      writer: (revision, snapshot) async {
        activeWriters += 1;
        maximumActiveWriters = maximumActiveWriters < activeWriters
            ? activeWriters
            : maximumActiveWriters;
        await Future<void>.delayed(Duration.zero);
        writes.add(revision);
        expect(snapshot, 'asset-$revision');
        activeWriters -= 1;
      },
    );

    final tickets = List.generate(
      100,
      (index) => coordinator.enqueue('asset-${index + 1}'),
    );
    await Future.wait(tickets.map((ticket) => ticket.completion));

    expect(maximumActiveWriters, 1);
    expect(writes, List<int>.generate(100, (index) => index + 1));
    expect(coordinator.revision, 100);
    expect(coordinator.persistedRevision, 100);
    expect(coordinator.state.status, PersistenceStatus.saved);
  });

  test('coalesces queued settings revisions but keeps CRUD requests separate',
      () async {
    final gate = Completer<void>();
    final writes = <String>[];
    var first = true;
    final coordinator = SaveCoordinator(
      writer: (_, snapshot) async {
        writes.add(snapshot);
        if (first) {
          first = false;
          await gate.future;
        }
      },
    );

    final firstSettings = coordinator.enqueue(
      'settings-1',
      kind: PersistenceSaveKind.settings,
    );
    await Future<void>.delayed(Duration.zero);
    final secondSettings = coordinator.enqueue(
      'settings-2',
      kind: PersistenceSaveKind.settings,
    );
    final thirdSettings = coordinator.enqueue(
      'settings-3',
      kind: PersistenceSaveKind.settings,
    );
    final crud = coordinator.enqueue('crud-4');
    gate.complete();

    await Future.wait([
      firstSettings.completion,
      secondSettings.completion,
      thirdSettings.completion,
      crud.completion,
    ]);

    expect(writes, ['settings-1', 'settings-3', 'crud-4']);
    expect(secondSettings.revision, 2);
    expect(thirdSettings.revision, 3);
    expect(coordinator.persistedRevision, 4);
  });

  test('a failed revision can be retried after the queue reports failure',
      () async {
    var shouldFail = true;
    final coordinator = SaveCoordinator(
      writer: (revision, _) async {
        if (revision == 2 && shouldFail) {
          shouldFail = false;
          throw StateError('simulated write failure');
        }
      },
    );

    final first = coordinator.enqueue('one');
    final failed = coordinator.enqueue('two');
    await first.completion;
    await expectLater(failed.completion, throwsA(isA<StateError>()));
    expect(coordinator.state.status, PersistenceStatus.failed);

    final retry = coordinator.retryLastFailed();
    expect(retry, isNotNull);
    await retry!.completion;
    expect(coordinator.persistedRevision, 3);
    expect(coordinator.state.status, PersistenceStatus.saved);
  });

  test('search and display filters do not create persistence requests', () {
    final store = AppStore();

    store.setQuery('camera');
    store.setStatusFilter('serving');
    store.setCategoryFilter('uncategorized');
    store.setSortMode(SortMode.recent);
    store.setAdvancedFilters(taggedOnlyValue: true, targetedOnlyValue: true);
    store.setWishArchivedFilter(true);

    expect(store.persistenceRevision, 0);
    expect(store.exportMap().containsKey('query'), isFalse);
    expect(store.exportMap().containsKey('statusFilter'), isFalse);
    expect(store.exportMap().containsKey('taggedOnly'), isFalse);
    expect(store.exportMap().containsKey('wishShowArchived'), isFalse);
  });
}
