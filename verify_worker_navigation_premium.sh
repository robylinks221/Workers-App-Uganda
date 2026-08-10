#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/worker_shell.dart \
lib/worker_home.dart \
lib/worker_applications.dart \
lib/features/worker/widgets/worker_quick_actions.dart \
lib/features/hiring/worker_hiring_requests_screen.dart

flutter analyze \
lib/worker_shell.dart \
lib/worker_home.dart \
lib/worker_applications.dart \
lib/features/worker/widgets/worker_quick_actions.dart \
lib/features/hiring/worker_hiring_requests_screen.dart \
lib/features/tips/dashboard_smart_tips.dart
