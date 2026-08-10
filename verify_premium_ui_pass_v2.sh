#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/widgets/premium_buttons.dart \
lib/features/profile/worker_public_profile_screen.dart \
lib/homeowner_job_details.dart \
lib/worker_job_details.dart \
lib/features/hiring/choose_hiring_job_screen.dart

flutter analyze \
lib/widgets/premium_buttons.dart \
lib/features/profile/worker_public_profile_screen.dart \
lib/homeowner_job_details.dart \
lib/worker_job_details.dart \
lib/features/hiring/choose_hiring_job_screen.dart
