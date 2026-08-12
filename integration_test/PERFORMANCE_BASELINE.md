# Valora performance baseline

B15 adds a repeatable dataset generator and a host-side Flutter benchmark
harness. The harness defaults to the `small` scale so a local run stays bounded; use
`VALORA_BENCHMARK_SCALE=all` to run empty, small, medium, and large datasets.

Generate datasets and archive-sized JSON fixtures:

```powershell
C:\Flutter\bin\dart.bat run tooling/performance_dataset.dart --scale=all
C:\Flutter\bin\dart.bat run tooling/performance_dataset.dart --scale=large --archive-bytes=104857600
```

Run the repeatable UI baseline on the Flutter test host:

```powershell
$env:VALORA_BENCHMARK_SCALE = 'small'
C:\Flutter\bin\flutter.bat test test/performance/performance_application_baseline_test.dart
```

The test prints JSONL records. The counters include frame
count, missed 16.67 ms frame budget, RSS before/after, save/import wall time,
and explicit markers for build/layout/paint and GC timeline breakdowns. Pipe
captured JSONL into the report formatter:

```powershell
C:\Flutter\bin\dart.bat run tooling/performance_report.dart `
  --input=build/performance/baseline.jsonl `
  --output=build/performance/baseline.md
```

This host harness does not claim Android device or native storage results. Run
the same scenarios on the target Android profile with the platform integration
adapter when device-level UI/raster, GC, and native storage numbers are needed.
