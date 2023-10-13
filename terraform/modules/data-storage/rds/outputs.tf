output "database_name" {
  description = "The name of the database"
  value       = try(aws_db_instance.this[0].db_name, null)
}

output "database_address" {
  description = "The connection address of the database"
  value       = try(aws_db_instance.this[0].address, null)
}

output "database_port" {
  description = "The connection port of the database"
  value       = try(aws_db_instance.this[0].port, null)
}
