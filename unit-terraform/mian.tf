provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  profile    = "default"
}

# 创建 VPC
resource "alicloud_vpc" "default" {
  vpc_name    = join("-", [var.prefix, "vpc"])
  cidr_block  = var.vpc_cidr
  enable_ipv6 = true
  ipv6_isp    = "BGP"
  tags        = var.tag
}

data "alicloud_zones" "default" {
  available_instance_type     = var.ins_type
  spot_strategy               = "SpotAsPriceGo"
  available_resource_creation = "Instance"
}

# 创建 VSwitch
resource "alicloud_vswitch" "default" {
  vpc_id       = alicloud_vpc.default.id
  cidr_block   = var.vs_cidr
  zone_id      = data.alicloud_zones.default.ids[0]
  vswitch_name = join("-", [var.prefix, "vs"])
  depends_on   = [alicloud_vpc.default]
  tags         = var.tag
}

# 创建安全组
resource "alicloud_security_group" "default" {
  vpc_id     = alicloud_vpc.default.id
  name       = join("-", [var.prefix, "sg"])
  depends_on = [alicloud_vpc.default, alicloud_vswitch.default]
  tags       = var.tag
}

# 配置安全组规则允许 SSH 访问
resource "alicloud_security_group_rule" "allow-all" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_ecs_key_pair" "default" {
  key_pair_name = join("-", [var.prefix, "sshkey"])
  public_key    = file(var.ins_pubkey)
  tags          = var.tag
}

data "alicloud_ecs_key_pairs" "default" {
  finger_print = alicloud_ecs_key_pair.default.finger_print
  name_regex   = alicloud_ecs_key_pair.default.key_pair_name
}

locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
EOF
}


# 创建 ECS 实例
module "ecs_cluster" {
  source                      = "alibaba/ecs-instance/alicloud"
  number_of_instances         = var.ins_count
  name                        = join("-", [var.prefix, "ecs-"])
  use_num_suffix              = true
  image_id                    = var.ins_image
  instance_type               = var.ins_type
  vswitch_id                  = alicloud_vswitch.default.id
  security_group_ids          = [alicloud_security_group.default.id]
  associate_public_ip_address = true
  internet_max_bandwidth_out  = 100
  instance_charge_type        = "PostPaid"
  spot_strategy               = "SpotAsPriceGo"
  user_data = local.user_data

  key_name             = data.alicloud_ecs_key_pairs.default.pairs.0.id
  system_disk_category = "cloud_auto"
  system_disk_size     = 20
  tags                 = var.tag
  depends_on           = [alicloud_vpc.default, alicloud_vswitch.default, alicloud_security_group.default, alicloud_security_group_rule.allow-all]
}
