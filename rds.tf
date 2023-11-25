resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  db_name              = "${var.name}-db"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = local.tags
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "Security group for RDS"
  tags        = local.tags
}

resource "aws_security_group_rule" "ingress_from_asg" {
  security_group_id        = aws_security_group.rds_sg.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_sg.id
}
