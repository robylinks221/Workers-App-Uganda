#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format lib/homeowner_shell.dart

flutter analyze \
lib/homeowner_shell.dart \
lib/features/hiring/homeowner_hiring_requests_screen.dart \
lib/widgets/premium_floating_nav_bar.dart \
lib/services/notification_badge_service.dart
