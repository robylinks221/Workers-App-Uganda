#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/features/auth/widgets/auth_header.dart \
lib/signup.dart \
lib/guest_home.dart

flutter analyze \
lib/features/auth/widgets/auth_header.dart \
lib/features/auth/screens/login_screen.dart \
lib/signup.dart \
lib/guest_home.dart \
lib/widgets/app_button.dart
