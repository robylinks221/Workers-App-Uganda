#!/bin/zsh
set -e

cd ~/StudioProjects/workersapp

python3 <<'PY'
from pathlib import Path
import os
import re
import shutil

root = Path('lib')
tips = root / 'features/tips/dashboard_smart_tips.dart'

def relative_import(target):
    rel = os.path.relpath(tips, target.parent).replace(os.sep, '/')
    return rel if rel.startswith('.') else './' + rel

def add_import(text, target):
    statement = f"import '{relative_import(target)}';"
    if statement in text:
        return text

    matches = list(
        re.finditer(r"^import\s+['\"].+?['\"];\s*$", text, re.M)
    )
    if not matches:
        raise RuntimeError(f'No imports found in {target}')

    position = matches[-1].end()
    return text[:position] + '\n' + statement + text[position:]

def backup(path):
    backup_path = path.with_suffix(path.suffix + '.before_tips')
    if not backup_path.exists():
        shutil.copy2(path, backup_path)

worker = None
for path in root.rglob('*.dart'):
    text = path.read_text()
    if 'class WorkerDashboardScreen' in text:
        worker = (path, text)
        break

if worker is None:
    raise RuntimeError('WorkerDashboardScreen file not found.')

worker_path, worker_text = worker
backup(worker_path)
worker_text = add_import(worker_text, worker_path)

if 'TipAudience.worker' not in worker_text:
    anchor = '            SliverToBoxAdapter(child: _EarningsCard(data: data)),\n'
    insertion = '''            const SliverToBoxAdapter(
              child: DashboardSmartTipsCard(
                audience: TipAudience.worker,
                margin: EdgeInsets.fromLTRB(20, 16, 20, 0),
              ),
            ),
'''
    if anchor not in worker_text:
        raise RuntimeError(
            f'Worker dashboard insertion point not found in {worker_path}'
        )

    worker_text = worker_text.replace(anchor, anchor + insertion, 1)

worker_path.write_text(worker_text)
print(f'Updated worker dashboard: {worker_path}')

home = None
for path in root.rglob('*.dart'):
    if path == worker_path or path == tips:
        continue

    text = path.read_text()

    if 'DashboardHeader(' in text and (
        'CustomScrollView' in text or
        'ListView' in text or
        'SingleChildScrollView' in text
    ):
        home = (path, text)
        break

if home is None:
    print(
        'WARNING: The homeowner dashboard composition file was not found '
        'automatically. The tips widget and worker dashboard were installed.'
    )
else:
    home_path, home_text = home
    backup(home_path)
    home_text = add_import(home_text, home_path)

    if 'TipAudience.homeowner' not in home_text:
        match = re.search(
            r'(SliverToBoxAdapter\(\s*child:\s*DashboardHeader\(.*?\),\s*\),)',
            home_text,
            re.S,
        )

        if match:
            insertion = match.group(1) + '''
            const SliverToBoxAdapter(
              child: DashboardSmartTipsCard(
                audience: TipAudience.homeowner,
              ),
            ),'''
            home_text = (
                home_text[:match.start()] +
                insertion +
                home_text[match.end():]
            )
        else:
            match = re.search(r'(DashboardHeader\(.*?\),)', home_text, re.S)

            if match is None:
                raise RuntimeError(
                    f'Homeowner dashboard insertion point not found in {home_path}'
                )

            insertion = match.group(1) + '''
                const DashboardSmartTipsCard(
                  audience: TipAudience.homeowner,
                ),'''
            home_text = (
                home_text[:match.start()] +
                insertion +
                home_text[match.end():]
            )

    home_path.write_text(home_text)
    print(f'Updated homeowner dashboard: {home_path}')
PY

AFFECTED_FILES=$(grep -R -l "TipAudience.worker\|TipAudience.homeowner" lib --include='*.dart')

dart format lib/features/tips/dashboard_smart_tips.dart $AFFECTED_FILES

flutter analyze lib/features/tips/dashboard_smart_tips.dart $AFFECTED_FILES
