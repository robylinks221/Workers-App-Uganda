#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format lib/homeowner_job_details.dart

flutter analyze \
lib/homeowner_job_details.dart \
lib/homeowner_jobs.dart \
lib/features/homeowner/homeowner_jobs_hub_screen.dart
