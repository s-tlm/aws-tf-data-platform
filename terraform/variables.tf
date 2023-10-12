variable "environment" {
  type        = string
  description = "The AWS environment name"
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}
