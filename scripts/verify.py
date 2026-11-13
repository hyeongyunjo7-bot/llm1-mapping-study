"""Offline integrity verification. No model or network calls; Python 3 stdlib only."""
import hashlib, json
from pathlib import Path
root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'MANIFEST.json').read_text(encoding='utf-8-sig'))
for f in manifest['files']:
    p = root / f['path']
    assert hashlib.sha256(p.read_bytes()).hexdigest() == f['sha256'], f['path']
    if p.suffix == '.json':
        json.loads(p.read_text(encoding='utf-8-sig'))
runs = json.loads((root / 'data/run-inventory.json').read_text(encoding='utf-8-sig'))
assert len(runs) == 83
assert sum(bool(r['response_path']) for r in runs) == 81
for r in runs:
    if r['response_path']:
        assert hashlib.sha256((root / r['response_path']).read_bytes()).hexdigest() == r['response_sha256']
sel = json.loads((root / 'representative-A/selection.json').read_text(encoding='utf-8-sig'))
assert hashlib.sha256((root / 'representative-A/response.json').read_bytes()).hexdigest() == sel['response_sha256']
print(json.dumps({'status': 'PASS', 'files': len(manifest['files']), 'run_records': 83, 'complete_responses': 81, 'scope': 'Integrity only'}, indent=2))