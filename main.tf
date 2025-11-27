# 1. Bucket S3 para "Spill Location"
resource "aws_s3_bucket" "spill_bucket" {
  bucket        = var.spill_bucket_name
  force_destroy = true # Permite destruir el bucket aunque tenga datos (útil para demos)
}

# Configuración de ciclo de vida para borrar datos viejos del Spill
resource "aws_s3_bucket_lifecycle_configuration" "spill_lifecycle" {
  bucket = aws_s3_bucket.spill_bucket.id
  rule {
    id     = "borrar-temporales-1-dia"
    status = "Enabled"
    expiration {
      days = 1
    }
  }
}

# 2. DynamoDB (Tabla de Ejemplo)
resource "aws_dynamodb_table" "data_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
  
  tags = {
    Name = "${var.project_prefix}-table"
  }
}

# 3. Athena Workgroup (Entorno para consultas)
resource "aws_athena_workgroup" "primary" {
  name = "${var.project_prefix}-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.spill_bucket.bucket}/athena-results/"
    }
  }
}

# 4. Lambda Connector
# Desplegamos el conector oficial de AWS desde el Serverless Repo.
# Esto crea automáticamente la Lambda y los IAM Roles necesarios (InvokeFunction, S3 access).

data "aws_serverlessapplicationrepository_application" "athena_dynamodb_connector" {
  application_id = "arn:aws:serverlessrepo:us-east-1:292517598671:applications/AthenaDynamoDBConnector"
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "deploy_connector" {
  name             = "${var.project_prefix}-connector"
  application_id   = data.aws_serverlessapplicationrepository_application.athena_dynamodb_connector.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.athena_dynamodb_connector.semantic_version
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_RESOURCE_POLICY"]

  # Parámetros requeridos por el conector oficial
  parameters = {
    AthenaCatalogName = "${var.project_prefix}-catalog"
    SpillBucket       = aws_s3_bucket.spill_bucket.bucket
    # Aquí conectamos el catálogo con la tabla específica o usamos 'default'
  }
}

# 5. QuickSight (Visualización)

resource "aws_quicksight_data_source" "athena_source" {
  data_source_id = "${var.project_prefix}-athena-ds"
  name           = "${var.project_prefix}-athena-source"
  type           = "ATHENA"

  parameters {
    athena {
      work_group = aws_athena_workgroup.primary.name
    }
  }
  
  permission {
    actions = ["quicksight:DescribeDataSource", "quicksight:DescribeDataSourcePermissions", "quicksight:PassDataSource", "quicksight:UpdateDataSource", "quicksight:DeleteDataSource", "quicksight:UpdateDataSourcePermissions"]
    principal = "arn:aws:quicksight:${var.aws_region}:${data.aws_caller_identity.current.account_id}:user/default/TU_USUARIO_QUICKSIGHT" # Requiere ajustar al usuario real
  }
  
  # Dependencia explicita para asegurar que el catálogo existe antes de conectar
  depends_on = [aws_serverlessapplicationrepository_cloudformation_stack.deploy_connector]
}

# Data source para obtener tu ID de cuenta actual
data "aws_caller_identity" "current" {}