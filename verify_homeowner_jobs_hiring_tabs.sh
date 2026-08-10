#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/homeowner_shell.dart \
lib/homeowner_jobs.dart \
lib/features/homeowner/homeowner_jobs_hub_screen.dart \
lib/features/hiring/homeowner_hiring_requests_screen.dart

flutter analyze \
lib/homeowner_shell.dart \
lib/homeowner_jobs.dart \
lib/features/homeowner/homeowner_jobs_hub_screen.dart \
lib/features/hiring/homeowner_hiring_requests_screen.dart
