locals {
  app = jsonencode(
    {
      "name" : var.name
      "essential" : true,
      "environment" : var.inject_env == null ? null : [
        for key, value in var.inject_env : {
          value = value, name = key
        }
      ],
      "image" : var.image,
      "portMappings" : [{ containerPort = var.port }],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "secretOptions" : null,
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : var.name,
          "awslogs-region" : data.aws_region.current.name,
          "awslogs-stream-prefix" : "${var.name}-service"
        }
      }
    }
  )
}
