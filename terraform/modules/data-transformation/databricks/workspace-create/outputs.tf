output "databricks_host" {
  value = try(databricks_mws_workspaces.this[0].workspace_url, null)
}

output "databricks_token" {
  value     = try(databricks_mws_workspaces.this[0].token[0].token_value, null)
  sensitive = true
}
