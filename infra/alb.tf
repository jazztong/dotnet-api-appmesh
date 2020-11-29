resource "aws_lb" "this" {
  name            = "${var.uid}-alb"
  security_groups = [aws_security_group.this.id]
  subnets         = data.aws_subnet_ids.this.ids
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "this" {
  name_prefix = "my-alb"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.this.id
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = ["/WeatherForecast*"]
    }
  }
}
