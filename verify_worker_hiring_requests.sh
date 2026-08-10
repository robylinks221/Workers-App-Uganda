#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/services/hiring_service.dart \
lib/features/hiring/worker_hiring_requests_screen.dart \
lib/features/hiring/worker_hiring_request_details_screen.dart \
lib/worker_shell.dart

flutter analyze \
lib/services/hiring_service.dart \
lib/features/hiring/worker_hiring_requests_screen.dart \
lib/features/hiring/worker_hiring_request_details_screen.dart \
lib/worker_shell.dart
