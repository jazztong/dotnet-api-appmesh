resource "aws_lb_listener_rule" "this" {
  count        = var.create_lb ? 1 : 0
  listener_arn = var.lb_listener_arn

  action {
    type             = "forward"
    target_group_arn = join("", aws_lb_target_group.this.*.arn)
  }

  condition {
    path_pattern { values = var.paths }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "this" {
  count       = var.create_lb ? 1 : 0
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }
}
