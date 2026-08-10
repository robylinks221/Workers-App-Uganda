#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/main.dart \
lib/features/homeowner/widgets/dashboard_header.dart \
lib/features/worker/widgets/worker_home_header.dart

flutter analyze \
lib/main.dart \
lib/homeowner_home.dart \
lib/worker_home.dart \
lib/features/homeowner/widgets/dashboard_header.dart \
lib/features/worker/widgets/worker_home_header.dart
