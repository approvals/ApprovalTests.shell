#!/bin/bash

echo "test: pass"
./verify.sh -t test1 <<< "test 1 approves this message
line 2"
echo ""

echo "test: fails and triggers diff tool"
./verify.sh -t test3 -d diff <<< "test 3 receives this input"
echo ""
