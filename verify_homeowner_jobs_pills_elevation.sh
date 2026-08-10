#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/features/homeowner/homeowner_jobs_hub_screen.dart \
lib/homeowner_jobs.dart

flutter analyze \
lib/features/homeowner/homeowner_jobs_hub_screen.dart \
lib/homeowner_jobs.dart \
lib/features/hiring/homeowner_hiring_requests_screen.dart \
lib/homeowner_shell.dart
