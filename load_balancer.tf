resource "aws_lb" "default" {
  name            = "pat-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "hello_nginx" {
  vpc_id = aws_vpc.pat_vpc.id

  name        = "pat-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    interval          = "30"
    protocol          = "HTTP"
    matcher           = "200"
    path              = "/"
  }
}

resource "aws_lb_listener" "hello_nginx" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_nginx.id
    type             = "forward"
  }
}
