terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "1.34.1"
    }
  }
}


provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "e504e5d83ea74fa9"
  auth_url    = "http://172.31.41.204:5000/v3"
  region      = "RegionOne"
}


resource "openstack_images_image_v2" "rancheros" {
  name             = "RancherOS"
  image_source_url = "https://releases.rancher.com/os/latest/rancheros-openstack.img"
  container_format = "bare"
  disk_format      = "qcow2"

  properties = {
    key = "value"
  }
}

#### NETWORK CONFIGURATION ####

# Router creation
resource "openstack_networking_router_v2" "rdo_net" {
  name                = "router-rdo_net"
  external_network_id = var.external_gateway
}

# Network creation
resource "openstack_networking_network_v2" "rdo_net" {
  name = "network-rdo_net"
}

#### HTTP SUBNET ####

# Subnet rdo_test configuration
resource "openstack_networking_subnet_v2" "rdo_test" {
  name            = var.network_rdo_test["subnet_name"]
  network_id      = openstack_networking_network_v2.rdo_net.id
  cidr            = var.network_rdo_test["cidr"]
  dns_nameservers = var.dns_ip
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "rdo_test" {
  router_id = openstack_networking_router_v2.rdo_net.id
  subnet_id = openstack_networking_subnet_v2.rdo_test.id
}

resource "openstack_compute_secgroup_v2" "rdo_test" {
  name        = "rdo_test"
  description = "Open input http port"
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "ssh" {
  name        = "ssh"
  description = "Open input ssh port"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

#### INSTANCE HTTP ####
#
# Create instance
#
resource "openstack_compute_instance_v2" "rdo_test" {
  name        = "rdo_test"
  image_name  = openstack_images_image_v2.rancheros.name
  flavor_name = var.flavor_rdo_test
  key_pair    = "openstack"
  
  network {
    port = openstack_networking_port_v2.rdo_test.id
  }
}

# Create network port
resource "openstack_networking_port_v2" "rdo_test" {
  name           = "port-instance-rdo_test"
  network_id     = openstack_networking_network_v2.rdo_net.id
  admin_state_up = true
  security_group_ids = [
    openstack_compute_secgroup_v2.ssh.id,
    openstack_compute_secgroup_v2.rdo_test.id,
  ]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.rdo_test.id
  }
}

# Create floating ip
resource "openstack_networking_floatingip_v2" "rdo_test" {
  pool = var.external_network
}

# Attach floating ip to instance
resource "openstack_compute_floatingip_associate_v2" "rdo_test" {
  floating_ip = openstack_networking_floatingip_v2.rdo_test.address
  instance_id = openstack_compute_instance_v2.rdo_test.id
}




