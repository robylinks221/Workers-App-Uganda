#!/bin/zsh
set -e
cd ~/StudioProjects/workersapp

dart format lib/features/marketplace/browse_workers_screen.dart

flutter analyze \
lib/features/marketplace/browse_workers_screen.dart \
lib/homeowner_home.dart \
lib/homeowner_shell.dart
