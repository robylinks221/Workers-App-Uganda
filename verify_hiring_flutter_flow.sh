#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/config/api_config.dart \
lib/services/hiring_service.dart \
lib/features/hiring/choose_hiring_job_screen.dart \
lib/features/hiring/confirm_hiring_request_screen.dart \
lib/features/profile/worker_public_profile_screen.dart

flutter analyze \
lib/config/api_config.dart \
lib/services/hiring_service.dart \
lib/features/hiring/choose_hiring_job_screen.dart \
lib/features/hiring/confirm_hiring_request_screen.dart \
lib/features/profile/worker_public_profile_screen.dart
