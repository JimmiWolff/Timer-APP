#!/bin/bash

# Run CircuitTimer unit tests
# Usage: ./scripts/run-tests.sh

echo "🧪 Running CircuitTimer tests..."

xcodebuild test \
    -project CircuitTimer.xcodeproj \
    -scheme CircuitTimer \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    -quiet 2>&1 | tee /tmp/test_output.txt

TEST_RESULT=${PIPESTATUS[0]}

if [ $TEST_RESULT -ne 0 ]; then
    echo ""
    echo "❌ Tests failed!"
    echo "See /tmp/test_output.txt for details."
    exit 1
fi

echo ""
echo "✅ All tests passed!"
exit 0
