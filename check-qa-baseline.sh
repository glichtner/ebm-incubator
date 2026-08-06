#!/bin/bash
# Warn-only QA regression gate: compares the publisher's qa.json error/warning
# counts against the committed baseline (qa-baseline.json). Never fails the
# build; emits GitHub warning annotations on regressions.
set -uo pipefail
QA=output/qa.json
BASE=qa-baseline.json
[ -f "$QA" ] || { echo "::warning::$QA not found - skipping QA baseline check"; exit 0; }
[ -f "$BASE" ] || { echo "::warning::$BASE not found - skipping QA baseline check"; exit 0; }
read -r ERRS WARNS <<< "$(python3 -c "import json;j=json.load(open('$QA'));print(j.get('errs',0), j.get('warnings',0))")"
read -r BERRS BWARNS <<< "$(python3 -c "import json;j=json.load(open('$BASE'));print(j.get('errs',0), j.get('warnings',0))")"
echo "QA: errors=$ERRS (baseline $BERRS), warnings=$WARNS (baseline $BWARNS)"
if [ "$ERRS" -gt "$BERRS" ]; then
  echo "::warning::QA errors increased: $ERRS > baseline $BERRS - investigate (toolchain or content regression); update qa-baseline.json only if intentional"
fi
if [ "$WARNS" -gt "$BWARNS" ]; then
  echo "::warning::QA warnings increased: $WARNS > baseline $BWARNS"
fi
if [ "$ERRS" -lt "$BERRS" ]; then
  echo "::notice::QA errors decreased ($ERRS < $BERRS) - consider lowering qa-baseline.json"
fi
exit 0
