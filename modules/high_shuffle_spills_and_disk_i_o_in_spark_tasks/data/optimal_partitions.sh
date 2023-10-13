

#!/bin/bash



# Set variables

APP_NAME=${NAME_OF_SPARK_APPLICATION}

NUM_PARTITIONS=${NUMBER_OF_PARTITIONS}



# Check if application logs are present

if [ ! -f "$APP_NAME.log" ]; then

    echo "Application logs not found"

    exit 1

fi



# Check if number of partitions is set to optimal value

PARTITIONS=$(grep "RDD.*:.*partitions" $APP_NAME.log | tail -1 | awk '{print $3}')

if [ "$PARTITIONS" -eq "$NUM_PARTITIONS" ]; then

    echo "Number of partitions is optimal"

    exit 0

fi



# If number of partitions is not optimal, check if partitioning is efficient

SHUFFLE=$(grep "Shuffle.*records" $APP_NAME.log | tail -1 | awk '{print $3}')

if [ "$SHUFFLE" -eq 0 ]; then

    echo "Partitioning is efficient but number of partitions is suboptimal"

    exit 1

else

    echo "Partitioning is inefficient, causing unnecessary shuffle operations and spills"

    exit 2

fi