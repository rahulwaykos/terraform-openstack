

variable "external_network" {
  type    = string
  default = "public"
}


variable "external_gateway" {
  type    = string
  default = "7112bce3-f554-449e-b58b-5501b3381f47"
}

variable "dns_ip" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.8.4"]
}


variable "flavor_rdo_test" {
  type    = string
  default = "m1.small"
}

variable "network_rdo_test" {
  type = map(string)
  default = {
    subnet_name = "subnet"
    cidr        = "192.168.1.0/24"
  }
}
