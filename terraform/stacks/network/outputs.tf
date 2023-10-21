output "vpn_server_dns" {
  description = "The EC2 instance DNS"
  value       = try(aws_instance.this[0].public_dns, null)
}
