#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/homeowner_jobs.dart \
lib/features/marketplace/browse_workers_screen.dart \
lib/conversations_screen.dart \
lib/widgets/premium_floating_nav_bar.dart

flutter analyze \
lib/homeowner_jobs.dart \
lib/features/marketplace/browse_workers_screen.dart \
lib/conversations_screen.dart \
lib/widgets/premium_floating_nav_bar.dart \
lib/homeowner_shell.dart \
lib/worker_shell.dart
