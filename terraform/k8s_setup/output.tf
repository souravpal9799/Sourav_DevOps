output "master_public_ip" {
  value = module.master.public_ip
}

output "worker_public_ip" {
  value = module.worker.public_ip
}

# Run this command (with your key: -i /path/to/key.pem) to get the kubeadm join command for workers.
# Wait for master userdata to finish (~3–5 min) before running.
output "get_worker_join_command" {
  description = "SSH to master and cat the join command file. Use: ssh -i <your-key.pem> ubuntu@<master_ip> 'cat /home/ubuntu/worker-join.txt'"
  value       = "ssh -t -i keys/module.keypair.key_name ubuntu@${module.master.public_ip} 'cat /home/ubuntu/worker-join.txt'"
}
