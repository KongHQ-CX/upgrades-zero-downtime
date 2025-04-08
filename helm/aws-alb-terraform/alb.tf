# Gets the NodePort assigned to Kong
data "kubernetes_resource" "kong_node_port" {
  depends_on = [ helm_release.kong ]

  api_version = "v1"
  kind        = "Service"

  metadata {
    name      = "${var.kong_gateway_name}-kong-proxy"
    namespace = "kong-failover"
  }
}


resource "aws_lb" "kong_alb" {
  name               = var.kong_gateway_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.in_alb_security_group.id]
  subnets            = ["subnet-abc", "subnet-def", "subnet-789"]
}

resource "aws_lb_listener" "kong_in" {
  load_balancer_arn = aws_lb.kong_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-1:123456789012:certificate/32948f18-63d7-4ed9-9882-9448b81351a7"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kong_out.arn
  }
}

resource "aws_lb_target_group" "kong_out" {
  name     = var.kong_gateway_name
  port     = kubernetes_service.nodeport.spec.0.port.0.node_port
  protocol = "HTTP"
  vpc_id   = "vpc-abc"

  health_check {
    interval = 5
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200,404"
  }
}

resource "aws_lb_target_group_attachment" "attach_ec2s" {
  target_group_arn = aws_lb_target_group.kong_out.arn
  target_id        = "i-084eeeca5b8cc3499"
  port             = kubernetes_service.nodeport.spec.0.port.0.node_port
}

resource "aws_security_group" "in_alb_security_group" {
  name        = "${var.kong_gateway_name}-security-group"
  description = "Security Group for Kong Deployment ${var.kong_gateway_name}"
  vpc_id      = "vpc-abc"
}

resource "aws_security_group_rule" "from_www_to_alb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.in_alb_security_group.id
}

resource "aws_security_group_rule" "from_alb_to_anywhere" {
  type              = "egress"
  from_port         = kubernetes_service.nodeport.spec.0.port.0.node_port
  to_port           = kubernetes_service.nodeport.spec.0.port.0.node_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.in_alb_security_group.id
}

resource "aws_security_group_rule" "from_alb_to_kong" {
  type                     = "ingress"
  from_port                = kubernetes_service.nodeport.spec.0.port.0.node_port
  to_port                  = kubernetes_service.nodeport.spec.0.port.0.node_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.in_alb_security_group.id
  security_group_id        = "sg-abc"
}
