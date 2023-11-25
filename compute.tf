resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro" # using micro for example since is in free tier

  tags = local.tags
}



resource "aws_autoscaling_group" "asg" {
  name_prefix         = var.name
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id] # launching ASG in private subnets
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}


resource "aws_security_group" "asg_sg" {
  name        = "${var.name}-alb-sg"
  description = "Security group for Auto Scaling Group"
  tags        = local.tags
}

resource "aws_security_group_rule" "ingress_from_alb" {
  security_group_id = aws_security_group.asg_sg.id

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "egress_to_rds" {
  security_group_id = aws_security_group.asg_sg.id

  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_sg.id
}