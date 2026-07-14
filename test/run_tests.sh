#!/bin/sh
# run_tests.sh
# Runs each test script in an isolated podman container using shunit2.
# Uses a pre-built base image to avoid slow apt-get on every test.
# Usage: sh run_tests.sh

set -eu

SCRIPTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_DIR="$SCRIPTS_DIR/test"
IMAGE_NAME="hermes-scripts-test-base"

# Build (or rebuild) a base image with all required dependencies
build_base_image() {
    podman build -t "$IMAGE_NAME" - <<'EOF'
FROM docker.io/library/ubuntu:22.04
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        bzip2 coreutils grep git openssl sqlite3 bc xxd perl \
        bsdextrautils shunit2 python2.7 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
EOF
}

build_base_image

run_test() {
    test_script="$1"
    name=$(basename "$test_script")

    echo "=== Running $name ==="

    podman run --rm \
        --security-opt=no-new-privileges \
        -v "$SCRIPTS_DIR:/scripts:ro" \
        "$IMAGE_NAME" \
        sh -c "sh /scripts/test/$name"

    result=$?
    if [ $result -ne 0 ]; then
        echo "=== FAILED: $name (exit $result) ==="
        FAIL=1
    else
        echo "=== PASSED: $name ==="
    fi
}

FAIL=0

for t in "$TEST_DIR"/*.sh; do
    # skip this runner script
    [ "$(basename "$t")" = "run_tests.sh" ] && continue
    # skip shunit2 (it's sourced, not run)
    [ "$(basename "$t")" = "shunit2" ] && continue
    run_test "$t"
done

if [ "$FAIL" -ne 0 ]; then
    echo "Some tests failed."
    exit 1
fi

echo "All tests passed."
exit 0
