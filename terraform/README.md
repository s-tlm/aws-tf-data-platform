<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_tiers"></a> [data\_tiers](#module\_data\_tiers) | ./modules/data-storage/s3 | n/a |
| <a name="module_dms"></a> [dms](#module\_dms) | ./modules/data-ingestion/migration-service | n/a |
| <a name="module_glue"></a> [glue](#module\_glue) | ./modules/data-transformation | n/a |
| <a name="module_main_vpc"></a> [main\_vpc](#module\_main\_vpc) | ./modules/main-vpc | n/a |
| <a name="module_mysql"></a> [mysql](#module\_mysql) | ./modules/data-storage/rds | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arns"></a> [bucket\_arns](#output\_bucket\_arns) | A list of S3 bucket ARNs |
| <a name="output_bucket_ids"></a> [bucket\_ids](#output\_bucket\_ids) | A list of S3 bucket IDs |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | A list of private subnet IDs in the VPC |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | A list of public subnet IDs in the VPC |
<!-- END_TF_DOCS -->