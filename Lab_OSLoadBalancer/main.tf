# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "secret"
  auth_url    = "http://192.168.122.173/identity"
#  endpoint_overrides = {
#    "Block Storage" =	http://192.168.122.255/volume/v3/553731e4f4b74a8e8b1cae50dba1b0ab
#    "compute" =	http://192.168.122.255/compute/v2.1
#    "Compute_Legacy" =	http://192.168.122.255/compute/v2/553731e4f4b74a8e8b1cae50dba1b0ab
#    "identity" = http://192.168.122.255/identity
#    "image" =	http://192.168.122.255/image
#    "network" =	http://192.168.122.255:9696/
#    "placement" = http://192.168.122.255/placement
#    "volumev2" = http://192.168.122.255/volume/v2/553731e4f4b74a8e8b1cae50dba1b0ab
#    "volumev3" = http://192.168.122.255/volume/v3/553731e4f4b74a8e8b1cae50dba1b0ab
#  }
  use_octavia = true
}

# Create security group
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "secgroup"
  description = "Security group for load balancer"
}

# Create security rules
resource "openstack_networking_secgroup_rule_v2" "allow_ssh" {
  depends_on        = ["openstack_networking_secgroup_v2.secgroup", ]
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
}

resource "openstack_networking_secgroup_rule_v2" "allow_http" {
  depends_on        = ["openstack_networking_secgroup_v2.secgroup", ]
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup.id}"
}

# Create web server instances
resource "openstack_compute_instance_v2" "web_server" {
  count           = 2
  name            = "Web server ${count.index}"
  image_name      = "bionic-server-cloudimg-amd64"
  flavor_name     = "ds1G"
  key_pair        = "admin_all_instances"
  security_groups = ["secgroup"]
  config_drive    = true
  user_data       = file("cloud_init.yaml")
  metadata = {
    this = "that"
  }
  network {
    name = "private"
  }
}

# Create load balancer

data "openstack_networking_subnet_v2" "subnet" {
  name = "private-subnet"
}

resource "openstack_lb_loadbalancer_v2" "lbaas" {
  name = "lbaas"
  vip_subnet_id = "${data.openstack_networking_subnet_v2.subnet.subnet_id}"
}

# Associate load balancer's port with security group
resource "openstack_networking_port_secgroup_associate_v2" "lbaas_port" {
  depends_on = ["openstack_networking_secgroup_v2.secgroup", ]
  port_id    = "${openstack_lb_loadbalancer_v2.lbaas.vip_port_id}"
  security_group_ids = [
    "${openstack_networking_secgroup_v2.secgroup.id}",
  ]
}

# Create listener
resource "openstack_lb_listener_v2" "lb_http" {
  depends_on      = ["openstack_lb_loadbalancer_v2.lbaas", ]
  name            = "lb_http"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = "openstack_lb_loadbalancer_v2.lbaas.id"
  insert_headers = {
    X-Forwarded-For = "true"
  }
}

# Create load balancer pool
resource "openstack_lb_pool_v2" "lb_pool" {
  depends_on  = ["openstack_lb_listener_v2.lb_http", ]
  name        = "lb_pool"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "openstack_lb_listener_v2.lb_http.id"
}

# Add load balancer's members
resource "openstack_lb_member_v2" "member_1" {
  depends_on    = ["openstack_lb_pool_v2.lb_pool", "openstack_compute_instance_v2.web_server[0]", ]
  pool_id       = "openstack_lb_pool_v2.lb_pool.id"
  address       = "openstack_compute_instance_v2.web_server[0].acces_ip_v4"
  protocol_port = 80
}

resource "openstack_lb_member_v2" "member_2" {
  depends_on    = ["openstack_lb_pool_v2.lb_pool", "openstack_compute_instance_v2.web_server[1]", ]
  pool_id       = "openstack_lb_pool_v2.lb_pool.id"
  address       = "openstack_compute_instance_v2.web_server[1].acces_ip_v4"
  protocol_port = 80
}
