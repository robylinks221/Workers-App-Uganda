#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/features/hiring/worker_hiring_requests_screen.dart \
lib/features/hiring/worker_hiring_request_details_screen.dart

flutter analyze \
lib/features/hiring/worker_hiring_requests_screen.dart \
lib/features/hiring/worker_hiring_request_details_screen.dart
