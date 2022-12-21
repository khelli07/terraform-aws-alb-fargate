resource "aws_ecs_task_definition" "nginx" {
  family                   = "hello-nginx-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = <<DEFINITION
    [
        {
        "name"      : "nginx",
        "image"     : "nginx:1.23.1",
        "cpu"       : 256,
        "memory"    : 512,
        "essential" : true,
        "portMappings" : [
            {
            "containerPort" : 80,
            "hostPort"      : 80
            }
        ]
        }
    ]
    DEFINITION
}

resource "aws_ecs_cluster" "main" {
  name = "pat-cluster"
}

resource "aws_ecs_service" "hello_nginx" {
  name            = "hello-nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.nginx_task.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_nginx.id
    container_name   = "nginx"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.hello_nginx
  ]
}


