# The following outputs allow authentication and connectivity to the GKE Cluster
# by using certificate-based authentication.
output "client_certificate" {
  value = "${google_container_cluster.reddit-cluster.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.reddit-cluster.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.reddit-cluster.master_auth.0.cluster_ca_certificate}"
}

# External IP of cluster

output "k8s-external-ip" {
  value = "${google_compute_address.k8s-external-ip.address}"
}
