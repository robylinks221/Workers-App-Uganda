#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/widgets/premium_buttons.dart \
lib/homeowner_job_details.dart \
lib/features/marketplace/browse_workers_screen.dart

flutter analyze \
lib/widgets/premium_buttons.dart \
lib/homeowner_job_details.dart \
lib/features/marketplace/browse_workers_screen.dart \
lib/homeowner_shell.dart
