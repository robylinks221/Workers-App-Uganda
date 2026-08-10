#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/features/profile/homeowner_personal_information_screen.dart \
lib/features/profile/worker_personal_information_screen.dart \
lib/features/profile/profile_view_screen.dart \
lib/features/profile/worker_services_screen.dart \
lib/features/profile/security_screen.dart \
lib/features/profile/change_password_screen.dart

flutter analyze \
lib/features/profile/homeowner_personal_information_screen.dart \
lib/features/profile/worker_personal_information_screen.dart \
lib/features/profile/profile_view_screen.dart \
lib/features/profile/worker_services_screen.dart \
lib/features/profile/security_screen.dart \
lib/features/profile/change_password_screen.dart \
lib/features/profile/account_screen.dart
