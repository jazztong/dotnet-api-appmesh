locals {
  xray = jsonencode(
    {
      "name" : "xray",
      "essential" : true,
      "image" : "amazon/aws-xray-daemon",
      "portMappings" : [
        {
          "hostPort" : 2000,
          "protocol" : "udp",
          "containerPort" : 2000
        }
      ],
      "healthCheck" : {
        "retries" : 3,
        "command" : [
          "CMD-SHELL",
          "timeout 1 /bin/bash -c \"</dev/udp/localhost/2000\""
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
          "awslogs-group" : "${var.name}-xray",
          "awslogs-region" : data.aws_region.current.name,
          "awslogs-stream-prefix" : "${var.name}-xray"
        }
      },
    }
  )
}
