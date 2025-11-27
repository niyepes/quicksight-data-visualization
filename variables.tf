variable "aws_region" {
  description = "Región de AWS donde se desplegará"
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
}

variable "spill_bucket_name" {
  description = "Nombre único global para el bucket S3 de Spill"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB a consultar"
  type        = string
}