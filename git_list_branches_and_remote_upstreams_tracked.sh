#!/bin/sh

git for-each-ref refs/heads --format='%(refname:short) %(upstream:short)'
