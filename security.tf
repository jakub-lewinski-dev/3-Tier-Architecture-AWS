
resource "aws_security_group" "alb" {
  name        = "my-portfolio-alb-sg"
  description = "Security group for the public Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name  = "my-portfolio-alb-sg"
    Layer = "public"
  }
}

resource "aws_security_group" "app" {
  name        = "my-portfolio-app-sg"
  description = "Security group for application EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name  = "my-portfolio-app-sg"
    Layer = "private-app"
  }
}

resource "aws_security_group" "db" {
  name        = "my-portfolio-db-sg"
  description = "Security group for the database"
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name  = "my-portfolio-db-sg"
    Layer = "private-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic from the internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Allow traffic from ALB to application"
  ip_protocol                  = "tcp"
  from_port                    = 5000
  to_port                      = 5000
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow HTTP traffic only from ALB"
  ip_protocol                  = "tcp"
  from_port                    = 5000
  to_port                      = 5000
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow PostgreSQL traffic to database"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.db.id
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow PostgreSQL only from application"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.app.id
}
