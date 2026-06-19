# --- Public Application Load Balancer ---
resource "aws_security_group" "alb" {
  name_prefix = "${local.name}-alb-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP (redirect to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "public" {
  name               = "${local.name}-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

# Target group per public service (gateway, web).
resource "aws_lb_target_group" "public" {
  for_each    = { for k, v in local.services : k => v if v.public }
  name        = "${local.name}-${each.key}"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path    = each.key == "web" ? "/" : "/health"
    matcher = "200"
  }
}

# HTTP -> HTTPS redirect.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener. Provide an ACM certificate ARN before enabling in production.
# Default action sends traffic to the web app; /api/* is routed to the gateway.
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  # certificate_arn = var.acm_certificate_arn  # TODO: set before production

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public["web"].arn
  }
}

resource "aws_lb_listener_rule" "api_to_gateway" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public["gateway"].arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
