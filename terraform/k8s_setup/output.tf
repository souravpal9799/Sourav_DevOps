output "master_public_ip" {
  value = module.master.public_ip
}

output "worker_public_ip" {
  value = module.worker.public_ip
}
