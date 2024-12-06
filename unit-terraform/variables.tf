### 分隔符
variable "access_key" {
  description = "accesskey"
  type        = string
  default     = "LTAI5asdfasftCma09jkw8kdHHPemJBMyCQ"
}

variable "secret_key" {
  description = "secretkey"
  type        = string
  default     = "aJmxCm1llasdf98EBuzD4QsSKasdftQ1c4F0CHTw"
}

variable "region" {
  type    = string
  default = "cn-hongkong"
}

variable "vpc_cidr" {
  description = "vpc的cidr, 默认10.0.0.0/8"
  type        = string
  default     = "10.0.0.0/8"
}

variable "vs_cidr" {
  description = "vswitch的cidr, 默认10.10.0.0/16"
  type        = string
  default     = "10.10.0.0/16"
}

variable "prefix" {
  description = "使用本Terraform创建资源时, 所有资源的前缀, 默认tf"
  type        = string
  default     = "tf"
}

variable "tag" {
  description = "使用本Terraform资源, 给所有资源打上的标签, 默认env:tf"
  type        = map(string)
  default = {
    "env" = "tf"
  }
}

variable "ins_count" {
  description = "实例个数, 不得小于4个, 本测试中的是高可用的k3s集群, 至少要有3个master和1个worker节点"
  type        = number
  default     = 7
}

variable "ins_type" {
  description = "实例规格: 2c4g"
  type        = string
  default     = "ecs.e-c1m2.large"
}

variable "ins_image" {
  description = "实例的镜像ID"
  type        = string
  default     = "ubuntu_24_04_x64_20G_alibase_20240923.vhd"
}

variable "ins_pubkey" {
  description = "服务器的公钥, 注意1, 必须为绝对路径, 2,如果公钥为a.x.pub, 则私钥为a.b, 公钥必须以.pub结尾"
  type = string
  default = "/root/all.pem.pub"
}
