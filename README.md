# Proyecto de Visualización de Datos Serverless (AWS)

Este proyecto despliega una infraestructura completa de visualización de datos utilizando Terraform. Conecta Amazon DynamoDB con Amazon QuickSight utilizando consultas de SQL con Athena

## Arquitectura

![Imagen1](proyecto-quicksight.svg)

- **Fuente de Datos:** Amazon DynamoDB
- **Conector:** AWS Lambda (Athena DynamoDB Connector)
- **Motor de Consultas:** Amazon Athena
- **Almacenamiento Temporal (Spill):** Amazon S3
- **Visualización:** Amazon QuickSight

## Prerrequisitos

1.  [AWS CLI](https://aws.amazon.com/cli/) instalado y configurado.
2.  [Terraform](https://www.terraform.io/) instalado (v1.0+).
3.  Una cuenta de AWS con suscripción activa a QuickSight (QuickSight requiere configuración manual inicial en la consola).

## Configuración Segura

1.  Clona este repositorio.
2.  Crea un archivo llamado `terraform.tfvars` en la raíz (este archivo es ignorado por git).
3.  Define tus variables sensibles dentro de `terraform.tfvars`:

    ```hcl
    project_prefix = "mi-proyecto-data"
    aws_region     = "us-east-1"
    bucket_name    = "nombre-unico-de-mi-bucket-spill"
    ```

## Comandos de Despliegue

### 1. Inicializar
Descarga los proveedores necesarios y prepara el entorno.
```bash
terraform init
```
### 2. Planificar
Muestra qué recursos se crearán sin realizar cambios
```bash
terraform plan
```

### 3. Aplicar
Crea la infraestructura en tu cuenta de AWS. Escribe yes cuando se solicite
```bash
terraform apply
```

### 4. Destruir
Elimina todos los recursos creados para evitar incurrir en costos.
```bash
terraform destroy
```