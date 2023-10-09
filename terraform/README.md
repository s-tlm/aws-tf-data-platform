<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.mysql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_dms_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_endpoint) | resource |
| [aws_dms_replication_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_instance) | resource |
| [aws_dms_replication_subnet_group.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_subnet_group) | resource |
| [aws_dms_replication_task.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_task) | resource |
| [aws_dms_s3_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_s3_endpoint) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_policy.access_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.access_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.dms_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.role_s3_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.landing_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.landing_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.landing_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.access_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.role_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_dms"></a> [create\_dms](#input\_create\_dms) | Create DMS? | `bool` | `true` | no |
| <a name="input_create_ec2"></a> [create\_ec2](#input\_create\_ec2) | Create EC2? | `bool` | `true` | no |
| <a name="input_create_landing_zone"></a> [create\_landing\_zone](#input\_create\_landing\_zone) | Create S3 landing zone? | `bool` | `true` | no |
| <a name="input_create_rds"></a> [create\_rds](#input\_create\_rds) | Create RDS? | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Create VPC? | `bool` | `true` | no |
| <a name="input_default_region"></a> [default\_region](#input\_default\_region) | The default AWS region | `string` | `"ap-southeast-2"` | no |
| <a name="input_password"></a> [password](#input\_password) | Password for RDS DB | `string` | `"masterpassword"` | no |
| <a name="input_private_snet_cidr_block"></a> [private\_snet\_cidr\_block](#input\_private\_snet\_cidr\_block) | Private subnets CIDR block | `list(string)` | <pre>[<br>  "10.0.96.0/19",<br>  "10.0.128.0/19",<br>  "10.0.160.0/19"<br>]</pre> | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | Path of public key used to SSH to EC2 | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_public_snet_cidr_block"></a> [public\_snet\_cidr\_block](#input\_public\_snet\_cidr\_block) | Public subnets CIDR block | `list(string)` | <pre>[<br>  "10.0.0.0/19",<br>  "10.0.32.0/19",<br>  "10.0.64.0/19"<br>]</pre> | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Path to EC2 user data | `string` | `"./user-data/create-data.sh"` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for RDS DB | `string` | `"masteruser"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | Main VPC CIDR block | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | The database endpoint |
| <a name="output_dms_replication_task_status"></a> [dms\_replication\_task\_status](#output\_dms\_replication\_task\_status) | The status of the DMS replication task |
| <a name="output_ec2_public_dns"></a> [ec2\_public\_dns](#output\_ec2\_public\_dns) | Login DNS of the EC2 instance |
| <a name="output_landing_zone_arn"></a> [landing\_zone\_arn](#output\_landing\_zone\_arn) | ARN of the landing zone S3 bucket |
<!-- END_TF_DOCS -->