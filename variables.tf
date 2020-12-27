
#### NEUTRON
variable "external_network" {
  type    = string
  default = "external-network"
}

# UUID of external gateway
variable "external_gateway" {
  type    = string
  default = "93210dd9-23bc-457a-8969-dc692b35a8f9"
}

variable "dns_ip" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.8.4"]
}

#### VM parameters
variable "flavor_http" {
  type    = string
  default = "t2.medium"
}

variable "network_http" {
  type = map(string)
  default = {
    subnet_name = "subnet-http"
    cidr        = "192.168.1.0/24"
  }
}