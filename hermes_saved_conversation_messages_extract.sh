#!/bin/dash

jq -r '.messages[] | (.content, "================== NEXT MESSAGE ==================")' < "$1"
