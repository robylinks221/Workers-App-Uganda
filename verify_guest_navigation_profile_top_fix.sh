#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/guest_home.dart \
lib/features/profile/worker_public_profile_screen.dart

flutter analyze \
lib/guest_home.dart \
lib/features/profile/worker_public_profile_screen.dart \
lib/features/auth/screens/login_screen.dart \
lib/signup.dart
