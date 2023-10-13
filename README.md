
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High Shuffle Spills and Disk I/O in Spark Tasks.
---

This incident type refers to a situation where Spark tasks are experiencing high shuffle spills and disk I/O. Shuffle spills occur when the amount of data being shuffled is larger than the available memory, causing it to spill over to disk. High disk I/O can cause performance issues and slow down the Spark job. The incident requires optimization of shuffle operations and reduction of spills to improve the performance of the Spark tasks.

### Parameters
```shell
export DISK_NAME="PLACEHOLDER"

export JOB_ID="PLACEHOLDER"

export EXECUTOR_ID="PLACEHOLDER"

export CONTAINER_ID="PLACEHOLDER"

export LOG_FILE_PATH="PLACEHOLDER"

export NAME_OF_SPARK_APPLICATION="PLACEHOLDER"

export NUMBER_OF_PARTITIONS="PLACEHOLDER"
```

## Debug

### Check if there are any disk I/O issues
```shell
iostat -x ${DISK_NAME}
```

### Check if disk space is running low
```shell
df -h
```

### Check if there are any network I/O issues
```shell
ifconfig
```

### Check if there are any memory issues
```shell
free -m
```

### Check if there are any CPU issues
```shell
top
```

### Check Spark configuration settings
```shell
cat /etc/spark/conf/spark-defaults.conf
```

### Check Spark job status
```shell
yarn application -status ${JOB_ID}
```

### Check Spark event logs
```shell
yarn logs -applicationId ${JOB_ID} | grep ${EXECUTOR_ID}
```

### Check Spark executor logs
```shell
yarn logs -applicationId ${JOB_ID} -containerId ${CONTAINER_ID}
```

### Check for any Spark errors or warnings in the logs
```shell
grep -i -E "error|warning" ${LOG_FILE_PATH}
```

### Check for any slow queries in the application
```shell
grep -i -E "slow|query" ${LOG_FILE_PATH}
```

### Inefficient partitioning of data in Spark tasks, causing unnecessary shuffle operations and spills.
```shell


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


```

## Repair

### Reconfigure the Spark application to use the proper partitioning strategy to reduce the number of data shuffles.
```shell
bash

#!/bin/bash



# Set the variables

SPARK_APP=${NAME_OF_SPARK_APPLICATION}

PARTITION=${NUMBER_OF_PARTITIONS}



# Stop the running Spark application

sudo systemctl stop $SPARK_APP



# Update the Spark configuration to use the proper partitioning strategy

sudo sed -i "s/spark.sql.shuffle.partitions=.*/spark.sql.shuffle.partitions=$PARTITION/" /etc/spark/conf/spark-defaults.conf



# Start the Spark application

sudo systemctl start $SPARK_APP


```