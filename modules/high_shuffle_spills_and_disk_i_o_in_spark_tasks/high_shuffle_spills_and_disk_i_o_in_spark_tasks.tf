resource "shoreline_notebook" "high_shuffle_spills_and_disk_i_o_in_spark_tasks" {
  name       = "high_shuffle_spills_and_disk_i_o_in_spark_tasks"
  data       = file("${path.module}/data/high_shuffle_spills_and_disk_i_o_in_spark_tasks.json")
  depends_on = [shoreline_action.invoke_optimize_partitions,shoreline_action.invoke_update_spark_partitions]
}

resource "shoreline_file" "optimize_partitions" {
  name             = "optimize_partitions"
  input_file       = "${path.module}/data/optimize_partitions.sh"
  md5              = filemd5("${path.module}/data/optimize_partitions.sh")
  description      = "Inefficient partitioning of data in Spark tasks, causing unnecessary shuffle operations and spills."
  destination_path = "/tmp/optimize_partitions.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_spark_partitions" {
  name             = "update_spark_partitions"
  input_file       = "${path.module}/data/update_spark_partitions.sh"
  md5              = filemd5("${path.module}/data/update_spark_partitions.sh")
  description      = "Reconfigure the Spark application to use the proper partitioning strategy to reduce the number of data shuffles."
  destination_path = "/tmp/update_spark_partitions.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_optimize_partitions" {
  name        = "invoke_optimize_partitions"
  description = "Inefficient partitioning of data in Spark tasks, causing unnecessary shuffle operations and spills."
  command     = "`chmod +x /tmp/optimize_partitions.sh && /tmp/optimize_partitions.sh`"
  params      = ["NUMBER_OF_PARTITIONS","NAME_OF_SPARK_APPLICATION"]
  file_deps   = ["optimize_partitions"]
  enabled     = true
  depends_on  = [shoreline_file.optimize_partitions]
}

resource "shoreline_action" "invoke_update_spark_partitions" {
  name        = "invoke_update_spark_partitions"
  description = "Reconfigure the Spark application to use the proper partitioning strategy to reduce the number of data shuffles."
  command     = "`chmod +x /tmp/update_spark_partitions.sh && /tmp/update_spark_partitions.sh`"
  params      = ["NUMBER_OF_PARTITIONS","NAME_OF_SPARK_APPLICATION"]
  file_deps   = ["update_spark_partitions"]
  enabled     = true
  depends_on  = [shoreline_file.update_spark_partitions]
}

