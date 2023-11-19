resource "aws_lb" "alb" {
  name               = "LoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    Environment = "Labs Balancer"
  }
}
resource "aws_lb_target_group" "tg-labs" {
  name     = "target-labs"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom.id
}

resource "aws_lb_target_group_attachment" "target-01" {
  target_group_arn = aws_lb_target_group.tg-labs.arn
  target_id        = aws_instance.webserver_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target-02" {
  target_group_arn = aws_lb_target_group.tg-labs.arn
  target_id        = aws_instance.webserver_2.id
  port             = 80
}
resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn = aws_lb.alb.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.tg-labs.id
    type             = "forward"
  }
}
output "alb_public_dns" {
  value = aws_lb.alb.dns_name
}