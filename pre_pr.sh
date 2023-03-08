#!/bin/bash
# exit on error
set -e
# show debug log
set -x

dart format lib
dart format test
flutter analyze --fatal-infos --fatal-warnings
flutter pub run dart_code_metrics:metrics analyze lib --fatal-style --fatal-warnings --fatal-performance --set-exit-on-violation-level=warning

exit 0
