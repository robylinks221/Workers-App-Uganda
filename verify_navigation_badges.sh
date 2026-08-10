#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/widgets/premium_floating_nav_bar.dart \
lib/services/notification_badge_service.dart \
lib/worker_shell.dart \
lib/homeowner_shell.dart

flutter analyze \
lib/widgets/premium_floating_nav_bar.dart \
lib/services/notification_badge_service.dart \
lib/worker_shell.dart \
lib/homeowner_shell.dart \
lib/services/hiring_service.dart \
lib/services/chat_service.dart
