#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/homeowner_home.dart \
lib/features/homeowner/widgets/quick_links.dart

flutter analyze \
lib/homeowner_home.dart \
lib/features/homeowner/widgets/quick_links.dart \
lib/features/tips/dashboard_smart_tips.dart
