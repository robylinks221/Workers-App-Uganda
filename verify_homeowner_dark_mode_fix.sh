#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/homeowner_home.dart \
lib/features/homeowner/widgets/new_workers_carousel.dart

flutter analyze \
lib/homeowner_home.dart \
lib/features/homeowner/widgets/dashboard_header.dart \
lib/features/homeowner/widgets/quick_links.dart \
lib/features/homeowner/widgets/services_section.dart \
lib/features/homeowner/widgets/new_workers_carousel.dart \
lib/features/homeowner/widgets/recommended_workers.dart \
lib/widgets/premium_floating_nav_bar.dart
