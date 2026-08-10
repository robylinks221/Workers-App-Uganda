#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/main.dart \
lib/theme/app_theme.dart \
lib/theme/app_colors.dart \
lib/theme/theme_controller.dart \
lib/widgets/premium_floating_nav_bar.dart \
lib/homeowner_shell.dart \
lib/homeowner_home.dart \
lib/worker_shell.dart \
lib/worker_home.dart \
lib/features/homeowner/widgets \
lib/features/worker/widgets

flutter analyze \
lib/main.dart \
lib/theme/app_theme.dart \
lib/theme/app_colors.dart \
lib/theme/theme_controller.dart \
lib/widgets/premium_floating_nav_bar.dart \
lib/homeowner_shell.dart \
lib/homeowner_home.dart \
lib/worker_shell.dart \
lib/worker_home.dart \
lib/features/homeowner/widgets \
lib/features/worker/widgets
