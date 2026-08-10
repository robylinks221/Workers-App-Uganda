#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format lib/homeowner_job_details.dart

flutter analyze \
lib/homeowner_job_details.dart \
lib/widgets/premium_buttons.dart
