#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/theme/app_theme.dart \
lib/widgets/app_button.dart \
lib/features/auth/widgets/auth_header.dart \
lib/features/auth/screens/login_screen.dart \
lib/features/profile/account_screen.dart \
lib/features/auth/widgets/primary_button.dart \
lib/core/widgets/primary_button.dart

flutter analyze \
lib/theme/app_theme.dart \
lib/widgets/app_button.dart \
lib/features/auth/widgets/auth_header.dart \
lib/features/auth/screens/login_screen.dart \
lib/features/profile/account_screen.dart \
lib/homeowner_shell.dart \
lib/worker_shell.dart
