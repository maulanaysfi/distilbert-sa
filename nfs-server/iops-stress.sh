#!/bin/sh

NFS_MOUNT_PATH="/mnt/nfs" 
TEST_FILE_SIZE_MB=100
NUM_ITERATIONS=100
DELAY_SECONDS=0.1


if [ ! -d "$NFS_MOUNT_PATH" ]; then
    echo "Error: NFS mount path '$NFS_MOUNT_PATH' does not exist."
    echo "Please ensure your NFS volume is mounted before running this script."
    exit 1
fi

TEMP_DIR="$NFS_MOUNT_PATH/nfs_stress_test_$(date +%s)"
echo "Creating temporary directory: $TEMP_DIR"
mkdir -p "$TEMP_DIR" || { echo "Failed to create directory. Check permissions."; exit 1; }

echo "Starting NFS I/O stress test to $TEMP_DIR"
echo "File size per write: ${TEST_FILE_SIZE_MB}MB"
echo "Number of iterations: $NUM_ITERATIONS"
echo "Delay between iterations: $DELAY_SECONDS seconds"
echo "---------------------------------------------------"

for i in $(seq 1 $NUM_ITERATIONS); do
    TEST_FILE="$TEMP_DIR/test_file_$i.tmp"
    
    echo "Iteration $i/$NUM_ITERATIONS"
    
    # 1. Write a file
    echo "  Writing ${TEST_FILE_SIZE_MB}MB file: $TEST_FILE"
    time dd if=/dev/zero of="$TEST_FILE" bs=1M count="$TEST_FILE_SIZE_MB" 2>/dev/null
    sync # Ensure data is written to disk
    
    # 2. Read the file
    echo "  Reading file: $TEST_FILE"
    time dd if="$TEST_FILE" of=/dev/null bs=1M count="$TEST_FILE_SIZE_MB" 2>/dev/null
    
    # 3. Delete the file
    echo "  Deleting file: $TEST_FILE"
    rm -f "$TEST_FILE"
    
    echo "  Completed iteration $i."
    sleep $DELAY_SECONDS
done

echo "---------------------------------------------------"
echo "Cleaning up temporary directory: $TEMP_DIR"
rm -rf "$TEMP_DIR"

echo "NFS I/O stress test finished."

