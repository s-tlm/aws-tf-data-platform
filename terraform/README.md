<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_tiers"></a> [data\_tiers](#module\_data\_tiers) | ./modules/data-storage/s3/ | n/a |
| <a name="module_dms"></a> [dms](#module\_dms) | ./modules/data-ingestion/migration-service/ | n/a |
| <a name="module_main_vpc"></a> [main\_vpc](#module\_main\_vpc) | ./modules/main-vpc/ | n/a |
| <a name="module_mysql"></a> [mysql](#module\_mysql) | ./modules/data-storage/mysql/ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_dms"></a> [create\_dms](#input\_create\_dms) | Create DMS? | `bool` | `false` | no |
| <a name="input_create_ec2"></a> [create\_ec2](#input\_create\_ec2) | Create EC2? | `bool` | `false` | no |
| <a name="input_create_rds"></a> [create\_rds](#input\_create\_rds) | Create RDS? | `bool` | `false` | no |
| <a name="input_default_region"></a> [default\_region](#input\_default\_region) | The default AWS region | `string` | `"ap-southeast-2"` | no |
| <a name="input_password"></a> [password](#input\_password) | Password for RDS DB | `string` | `"masterpassword"` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Path of public key used to SSH to EC2 | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Path to EC2 user data | `string` | `"./user-data/create-data.sh"` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for RDS DB | `string` | `"masteruser"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arns"></a> [bucket\_arns](#output\_bucket\_arns) | A list of S3 bucket ARNs |
| <a name="output_bucket_ids"></a> [bucket\_ids](#output\_bucket\_ids) | A list of S3 bucket IDs |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | A list of private subnet IDs in the VPC |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | A list of public subnet IDs in the VPC |
<!-- END_TF_DOCS -->