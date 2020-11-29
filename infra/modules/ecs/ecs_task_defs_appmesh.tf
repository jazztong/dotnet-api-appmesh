locals {
  appmesh = jsonencode(
    {
      "name" : "envoy",
      "essential" : true,
      "environment" : [
        {
          "name" : "APPMESH_VIRTUAL_NODE_NAME",
          "value" : "mesh/${var.mesh_name}/virtualNode/${join("", aws_appmesh_virtual_node.this.*.name)}"
        },
        {
          "name" : "ENABLE_ENVOY_XRAY_TRACING",
          "value" : "1"
        },
        {
          "name" : "ENVOY_LOG_LEVEL",
          "value" : "info"
        }
      ],
      "image" : "840364872350.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod",
      "healthCheck" : {
        "retries" : 3,
        "command" : [
          "CMD-SHELL",
          "curl -s http://localhost:9901/server_info | grep state | grep -q LIVE"
        ],
        "timeout" : 2,
        "interval" : 5,
        "startPeriod" : 10
      },
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "secretOptions" : null,
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "${var.name}-envoy",
          "awslogs-region" : data.aws_region.current.name,
          "awslogs-stream-prefix" : "${var.name}-envoy"
        }
      },
      "user" : "1337",
    }
  )
}
