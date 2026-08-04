#!/usr/bin/env bash
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/mccp-azure-tests.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

cp "$repository_root"/*.tf "$test_root"/
cp "$repository_root/tests/runtime.tf" "$test_root/providers.tf"
mkdir "$test_root/tests"
cp "$repository_root/tests"/*.tftest.hcl "$test_root/tests"/

terraform -chdir="$test_root" init -backend=false -no-color
terraform -chdir="$test_root" fmt -check -recursive
terraform -chdir="$test_root" validate -no-color
terraform -chdir="$test_root" test -no-color
