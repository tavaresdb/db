# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# P.S.: Modifications were made to the file, compared to the original file.

# [START gke_redis_spotahome_standard_private_regional_cluster]
module "redis_cluster" {
  source                   = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                  = "~> 29.0"
  project_id               = var.project_id
  name                     = "${var.cluster_prefix}-cluster"
  regional                 = true
  region                   = var.region
  network                  = var.network
  subnetwork               = var.subnetwork
  ip_range_pods            = "k8s-pod-range"
  ip_range_services        = "k8s-service-range"
  create_service_account   = true
  enable_private_endpoint  = false
  enable_private_nodes     = true
  master_ipv4_cidr_block   = "172.16.0.0/28"
  network_policy           = true
  logging_enabled_components = ["SYSTEM_COMPONENTS","WORKLOADS"]
  monitoring_enabled_components = ["SYSTEM_COMPONENTS"]
  enable_cost_allocation = true
  deletion_protection = false
  initial_node_count = 1

  monitoring_enable_managed_prometheus = true
  gke_backup_agent_config = true
 
  node_pools        = var.node_pools
  gce_pd_csi_driver = true
}
# [END gke_redis_spotahome_standard_private_regional_cluster]
