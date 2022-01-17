#!/bin/bash

set -xeo pipefail
shopt -s nullglob

for test in /tests/*; do
  testrunner -logtostderr "--test_spec=${test}"
done