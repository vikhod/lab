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
  auth_url    = "http://192.168.122.2/identity"
}

# Create basic instance
resource "openstack_compute_instance_v2" "basic" {
  name            = "first_instance"
  image_name      = "bionic-server-cloudimg-amd64"
  flavor_name     = "ds1G"
  key_pair        = "admin_all_instances"
  security_groups = ["default"]

  config_drive    = true
  user_data       = file("cloud_init.yaml")
  
  metadata = {
    this = "that"
  }

  network {
    name = "public"
  }
}
