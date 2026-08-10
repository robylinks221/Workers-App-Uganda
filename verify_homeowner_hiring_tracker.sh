#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/services/hiring_service.dart \
lib/features/hiring/homeowner_hiring_requests_screen.dart \
lib/features/hiring/homeowner_hiring_request_details_screen.dart \
lib/homeowner_shell.dart

flutter analyze \
lib/services/hiring_service.dart \
lib/features/hiring/homeowner_hiring_requests_screen.dart \
lib/features/hiring/homeowner_hiring_request_details_screen.dart \
lib/homeowner_shell.dart
