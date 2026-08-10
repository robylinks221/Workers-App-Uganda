#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/conversations_screen.dart \
lib/features/homeowner/homeowner_jobs_hub_screen.dart \
lib/features/hiring/worker_hiring_requests_screen.dart \
lib/homeowner_job_details.dart \
lib/worker_job_details.dart \
lib/features/homeowner/widgets/dashboard_header.dart \
lib/features/worker/widgets/worker_home_header.dart

flutter analyze \
lib/conversations_screen.dart \
lib/features/homeowner/homeowner_jobs_hub_screen.dart \
lib/features/hiring/worker_hiring_requests_screen.dart \
lib/homeowner_job_details.dart \
lib/worker_job_details.dart \
lib/homeowner_shell.dart \
lib/worker_shell.dart
