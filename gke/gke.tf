variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

data "google_container_engine_versions" "available" {
  provider       = google
  location       = var.zone
  project        = var.project_id
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.zone
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 2

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  min_master_version = data.google_container_engine_versions.available.latest_node_version
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name          = "${google_container_cluster.primary.name}-node-pool"
  location      = var.zone
  cluster       = google_container_cluster.primary.name
  node_count    = var.gke_num_nodes
  version  = google_container_cluster.primary.min_master_version

  node_config {
    service_account = "gke-node@tughra-prj01.iam.gserviceaccount.com"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}