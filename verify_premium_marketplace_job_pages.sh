#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/features/marketplace/browse_workers_screen.dart \
lib/post_job.dart \
lib/saved_workers_screen.dart \
lib/worker_job_details.dart

flutter analyze \
lib/features/marketplace/browse_workers_screen.dart \
lib/post_job.dart \
lib/saved_workers_screen.dart \
lib/worker_job_details.dart \
lib/features/worker/widgets/worker_job_sections.dart
