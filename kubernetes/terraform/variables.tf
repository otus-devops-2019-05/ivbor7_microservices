# Terraform file eith variables definitions

variable project {  
  description = "Project name"
  default = "docker-250311"
}

variable region {
  description = "Location = Region, that depricated in favor of location"

  # default value
  default = "us-central1"
}

variable initial_node_count {
  description = "Initial node count for the pool"
  default     = 1
}

variable count_nodes {
  description = "The number of nodes per instance group"
  default     = 1
}

variable "min_node_count" {
  type = "string"
  description = "The minimum number of nodes PER ZONE in the node pool"
  default = 1
}

variable "max_node_count" {
  type = "string"
  description = "The maximum number of nodes PER ZONE in the  node pool"
  default = 3
}

variable "machine_type" {
  description = "GCE machine type"
  default = "g1-small"
}

variable "disk_size" {
  description = "Disk size in Gb"
  default = 20
}

variable "username" {
  description = "User name"
  default = "supermaster"
}

variable "psw" {
  description = "Password"
  default = "verystrongpassword"
}
