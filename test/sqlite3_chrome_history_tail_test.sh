#!/bin/sh
# Unit tests for sqlite3_chrome_history_tail.sh

SCRIPT="/scripts/sqlite3_chrome_history_tail.sh"

setUp() {
    T=$(mktemp -d)
    DB="$T/history.db"
    sqlite3 "$DB" <<SQL
CREATE TABLE urls (
    id INTEGER PRIMARY KEY,
    url TEXT,
    title TEXT
);
CREATE TABLE visits (
    id INTEGER PRIMARY KEY,
    url INTEGER REFERENCES urls(id),
    visit_time INTEGER
);
INSERT INTO urls VALUES (1, 'https://example.com', 'Example');
INSERT INTO visits VALUES (1, 1, 13370000000000000);
SQL
    export TEST_DB="$DB"
}

tearDown() {
    cd /
    rm -rf "$T"
}

test_queries_history() {
    out=$("$SCRIPT" "$TEST_DB" 2>/dev/null)
    case "$out" in *example.com*) e=1 ;; *) e=0 ;; esac
    assertTrue "Should query and show URL" "[ $e -eq 1 ]"
}

test_missing_db_error() {
    out=$("$SCRIPT" "/nonexistent/path/history.db" 2>&1)
    case "$out" in *example.com*) e=1 ;; *) e=0 ;; esac
    assertFalse "Should not show URLs for missing DB" "[ $e -eq 1 ]"
}

. /usr/bin/shunit2
