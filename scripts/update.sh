#!/usr/bin/env bash
# Обновить inputs, проверить флейк и пересобрать систему (nh покажет diff и спросит подтверждение).
set -euo pipefail
cd "$(dirname "$0")/.."

nix flake update
nix flake check --print-build-logs
nh os switch --ask .
