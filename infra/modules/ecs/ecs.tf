resource "aws_ecs_service" "this" {
  name        = var.name
  cluster     = var.cluster
  launch_type = "FARGATE"

  dynamic load_balancer {
    for_each = length(var.paths) > 0 ? [1] : []
    content {
      target_group_arn = join("", aws_lb_target_group.this.*.arn)
      container_port   = var.port
      container_name   = var.name
    }
  }

  task_definition  = aws_ecs_task_definition.this.arn
  platform_version = "1.4.0"
  desired_count    = 1

  network_configuration {
    subnets          = data.aws_subnet_ids.this.ids
    security_groups  = [var.sg_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  depends_on = [
    aws_service_discovery_service.this,
    aws_lb_target_group.this
  ]
}
