resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  subnets            = [for subnet in aws_subnet.public : subnet.id] # launching ALB in public subnets
  security_groups    = [aws_security_group.alb_sg.id]
  tags               = local.tags
}

resource "aws_autoscaling_attachment" "asg_to_alb" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = aws_lb.alb.id
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  description = "Security group for Application Load Balancer"
  tags        = local.tags
}

resource "aws_security_group_rule" "ingress_from_internet" {
  security_group_id = aws_security_group.alb_sg.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_to_asg" {
  security_group_id = aws_security_group.alb_sg.id

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
}


