resource "shoreline_notebook" "high_shuffle_spills_and_disk_i_o_in_spark_tasks" {
  name       = "high_shuffle_spills_and_disk_i_o_in_spark_tasks"
  data       = file("${path.module}/data/high_shuffle_spills_and_disk_i_o_in_spark_tasks.json")
  depends_on = [shoreline_action.invoke_optimal_partitions,shoreline_action.invoke_update_spark_partition_settings]
}

resource "shoreline_file" "optimal_partitions" {
  name             = "optimal_partitions"
  input_file       = "${path.module}/data/optimal_partitions.sh"
  md5              = filemd5("${path.module}/data/optimal_partitions.sh")
  description      = "Inefficient partitioning of data in Spark tasks, causing unnecessary shuffle operations and spills."
  destination_path = "/tmp/optimal_partitions.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_spark_partition_settings" {
  name             = "update_spark_partition_settings"
  input_file       = "${path.module}/data/update_spark_partition_settings.sh"
  md5              = filemd5("${path.module}/data/update_spark_partition_settings.sh")
  description      = "Reconfigure the Spark application to use the proper partitioning strategy to reduce the number of data shuffles."
  destination_path = "/tmp/update_spark_partition_settings.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_optimal_partitions" {
  name        = "invoke_optimal_partitions"
  description = "Inefficient partitioning of data in Spark tasks, causing unnecessary shuffle operations and spills."
  command     = "`chmod +x /tmp/optimal_partitions.sh && /tmp/optimal_partitions.sh`"
  params      = ["NAME_OF_SPARK_APPLICATION","NUMBER_OF_PARTITIONS"]
  file_deps   = ["optimal_partitions"]
  enabled     = true
  depends_on  = [shoreline_file.optimal_partitions]
}

resource "shoreline_action" "invoke_update_spark_partition_settings" {
  name        = "invoke_update_spark_partition_settings"
  description = "Reconfigure the Spark application to use the proper partitioning strategy to reduce the number of data shuffles."
  command     = "`chmod +x /tmp/update_spark_partition_settings.sh && /tmp/update_spark_partition_settings.sh`"
  params      = ["NAME_OF_SPARK_APPLICATION","NUMBER_OF_PARTITIONS"]
  file_deps   = ["update_spark_partition_settings"]
  enabled     = true
  depends_on  = [shoreline_file.update_spark_partition_settings]
}

