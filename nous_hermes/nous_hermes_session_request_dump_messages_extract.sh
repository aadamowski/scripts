#!/bin/dash

jq -r '.request.body.messages[]  | (.content, "================== NEXT MESSAGE ==================")' < "$1"
