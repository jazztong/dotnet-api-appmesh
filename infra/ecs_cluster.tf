resource "aws_appmesh_mesh" "this" {
  name = "${var.uid}-mesh"
  spec {
    egress_filter { type = "DROP_ALL" }
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.uid}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

locals {
  taskRole_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role_policy_attachment" "task" {
  count = length(local.taskRole_arns)

  role       = aws_iam_role.task.name
  policy_arn = element(local.taskRole_arns, count.index)
}

resource "aws_iam_role_policy" "task" {
  name   = "${var.uid}-TASK-ROLE-POLICY"
  role   = aws_iam_role.task.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "xray:PutTraceSegments"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "task" {
  name = "${var.uid}-TASK-ROLE"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Effect" : "Allow",
        }
      ]
    }
  )
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "mydomain.dev"
  vpc  = data.aws_vpc.this.id
}
