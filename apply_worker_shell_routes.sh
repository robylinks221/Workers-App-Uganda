#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

python3 - <<'PY'
from pathlib import Path

# Update login_screen.dart
login = Path("lib/features/auth/screens/login_screen.dart")
text = login.read_text()

text = text.replace(
    "import '../../../worker_home.dart';",
    "import '../../../worker_shell.dart';",
)
text = text.replace(
    "? const WorkerHomeScreen()",
    "? const WorkerShell()",
)

login.write_text(text)

# Update worker_complete_profile.dart
profile = Path("lib/worker_complete_profile.dart")
text = profile.read_text()

text = text.replace(
    "import 'worker_home.dart';",
    "import 'worker_shell.dart';",
)
text = text.replace(
    "MaterialPageRoute(builder: (_) => const WorkerHomeScreen())",
    "MaterialPageRoute(builder: (_) => const WorkerShell())",
)

profile.write_text(text)

print("Updated login routing and worker profile-completion routing.")
PY

dart format \
lib/worker_shell.dart \
lib/worker_home.dart \
lib/features/auth/screens/login_screen.dart \
lib/worker_complete_profile.dart

flutter analyze \
lib/worker_shell.dart \
lib/worker_home.dart \
lib/features/auth/screens/login_screen.dart \
lib/worker_complete_profile.dart
