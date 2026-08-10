#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/features/homeowner/widgets/recommended_workers.dart

flutter analyze \
lib/features/profile/account_screen.dart \
lib/features/homeowner/widgets/new_workers_carousel.dart \
lib/features/homeowner/widgets/recommended_workers.dart \
lib/features/marketplace/browse_workers_screen.dart \
lib/homeowner_shell.dart \
lib/worker_shell.dart
