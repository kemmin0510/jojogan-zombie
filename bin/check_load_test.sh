#!/bin/bash

# Read the second line
RESULT_LINE=$(tail -n +2 "tests/locust_results_stats.csv" | head -n 1)

# Extract the number of failures
FAILURE_COUNT=$(echo "$RESULT_LINE" | awk -F',' '{print $4}')
# Calculate the average of the response times
AVG_RESPONSE_TIME=$(echo "$RESULT_LINE" | awk -F',' '{print $6}')

echo "Failure Count: $FAILURE_COUNT"
echo "Average Response Time: $AVG_RESPONSE_TIME ms"

# Check conditions
if [[ "$FAILURE_COUNT" -ne 0 ]]; then
    echo "ERROR: There is at least a failure!"
    exit 1
fi

if (( $(echo "$AVG_RESPONSE_TIME > 60000" | bc -l) )); then
    echo "ERROR: Response time too high!"
    exit 1
fi

echo "✅ Load testing success!"
