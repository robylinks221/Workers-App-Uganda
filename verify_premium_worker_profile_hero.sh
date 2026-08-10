#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/features/profile/worker_public_profile_screen.dart

flutter analyze \
lib/features/profile/worker_public_profile_screen.dart \
lib/features/profile/profile_view_screen.dart \
lib/homeowner_shell.dart
