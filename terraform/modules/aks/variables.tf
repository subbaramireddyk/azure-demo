variable "name" {}
variable "location" { default = "southindia" }
variable "resource_group_name" {}
variable "dns_prefix" {}
variable "node_count" { default = 1 }
variable "min_count" { default = 1 }
variable "max_count" { default = 2 }
variable "vm_size" { default = "Standard_D2s_v3" }
