$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$manifest=Get-Content -LiteralPath (Join-Path $root 'MANIFEST.json') -Raw -Encoding UTF8|ConvertFrom-Json
foreach($f in $manifest.files){
 $p=Join-Path $root $f.path
 if((Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant() -ne $f.sha256){throw "Hash mismatch: $($f.path)"}
 if($f.path.EndsWith('.json')){ $null=Get-Content -LiteralPath $p -Raw -Encoding UTF8|ConvertFrom-Json }
}
$runs=Get-Content -LiteralPath (Join-Path $root 'data/run-inventory.json') -Raw -Encoding UTF8|ConvertFrom-Json
if($runs.Count -ne 83 -or @($runs|Where-Object response_path).Count -ne 81){throw 'Unexpected run totals'}
foreach($r in $runs|Where-Object response_path){if((Get-FileHash -LiteralPath (Join-Path $root $r.response_path)).Hash.ToLowerInvariant() -ne $r.response_sha256){throw "Response mismatch: $($r.run)"}}
$sel=Get-Content -LiteralPath (Join-Path $root 'representative-A/selection.json') -Raw -Encoding UTF8|ConvertFrom-Json
if((Get-FileHash -LiteralPath (Join-Path $root 'representative-A/response.json')).Hash.ToLowerInvariant() -ne $sel.response_sha256){throw 'Representative response changed'}
[pscustomobject]@{status='PASS';manifest_files=$manifest.files.Count;run_records=$runs.Count;complete_responses=81;representative=$sel.run;scope='Integrity only; no model calls, evaluation replay or physical-device test'}|ConvertTo-Json