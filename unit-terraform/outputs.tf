
output "ecs_private_ip" {
  value = module.ecs_cluster.this_private_ip
}

output "ecs_public_ip" {
  value = module.ecs_cluster.this_public_ip
}

output "ecs_pubkey" {
  value = var.ins_pubkey
}