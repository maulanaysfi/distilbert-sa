#!/bin/bash

NUM_CPU_CORES=1
DURATION_SECONDS=180

echo "Starting CPU stress test on NFS server pod for $DURATION_SECONDS seconds."
echo "Will simulate load on $NUM_CPU_CORES CPU cores."
echo "---------------------------------------------------"

# Loop to start multiple 'yes' processes in the background
for i in $(seq 1 $NUM_CPU_CORES); do
    # 'yes > /dev/null' consumes CPU. Running it in background (&) for each core.
    yes > /dev/null &
    CPU_PIDS[$i]=$! # Store the PID of each background process
    echo "  Started CPU stress process with PID: ${CPU_PIDS[$i]}"
done

echo "CPU stress processes are running in the background."

if [ "$DURATION_SECONDS" -gt 0 ]; then
    echo "Waiting for $DURATION_SECONDS seconds..."
    sleep "$DURATION_SECONDS"

    echo "Stopping CPU stress processes."
    for pid in "${CPU_PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then # Check if process still exists
            kill "$pid"
            echo "  Killed PID: $pid"
        else
            echo "  Process $pid already stopped or not found."
        fi
    done
    wait # Wait for all background processes to terminate
    echo "CPU stress test finished."
else
    echo "Running indefinitely. Manually stop by finding 'yes' PIDs and killing them, or deleting the pod."
    wait # Wait for background processes to finish (they won't unless killed)
fi

