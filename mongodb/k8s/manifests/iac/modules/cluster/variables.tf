variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "region" {
  description = "The region to host the cluster in"
}

variable "network" {
  description = "The VPC network to host the cluster in"
}

variable "subnetwork" {
  description = "The subnetwork to host the cluster in"
}

variable "cluster_prefix" {
  description = "The prefix for all cluster resources"
}

variable "node_pools" {
  type        = list(map(any))
  description = "List of maps containing node pools"
}
