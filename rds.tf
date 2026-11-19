resource "aws_db_subnet_group" "main" {
  name        = "my-portfolio-db-subnet-group"
  description = "Private subnets for the portfolio PostgreSQL database"
  subnet_ids  = aws_subnet.db[*].id

  tags = {
    Name  = "my-portfolio-db-subnet-group"
    Layer = "private-db"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "my-portfolio-postgres"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  iam_database_authentication_enabled = true

  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name                     = "portfolio"
  username                    = "dbadmin"
  manage_master_user_password = true
  port                        = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  multi_az                   = false
  backup_retention_period    = 1
  auto_minor_version_upgrade = true

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name  = "my-portfolio-postgres"
    Layer = "private-db"
  }
}
