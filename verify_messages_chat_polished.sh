#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

dart format \
lib/conversations_screen.dart \
lib/chat_screen.dart \
lib/models/chat_models.dart \
lib/services/chat_service.dart

flutter analyze \
lib/conversations_screen.dart \
lib/chat_screen.dart \
lib/models/chat_models.dart \
lib/services/chat_service.dart \
lib/worker_shell.dart \
lib/homeowner_shell.dart
