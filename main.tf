terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "high_shuffle_spills_and_disk_i_o_in_spark_tasks" {
  source    = "./modules/high_shuffle_spills_and_disk_i_o_in_spark_tasks"

  providers = {
    shoreline = shoreline
  }
}