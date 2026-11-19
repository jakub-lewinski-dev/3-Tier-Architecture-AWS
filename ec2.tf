
data "aws_ami" "portfolio_app" {
  most_recent = true

  owners = [data.aws_caller_identity.current.account_id]

  filter {
    name   = "name"
    values = ["portfolio-app-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.portfolio_app.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.app[0].id
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm.name
  vpc_security_group_ids = [aws_security_group.app.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    mkdir -p /etc/portfolio-app

    cat > /etc/portfolio-app/portfolio.env <<'ENV'
    DB_HOST=${aws_db_instance.postgres.address}
    DB_PORT=5432
    DB_NAME=portfolio
    DB_USER=portfolio_app
    AWS_REGION=${var.aws_region}
    DB_SSLROOTCERT=/etc/ssl/certs/rds-global-bundle.pem
    ENV

    chmod 600 /etc/portfolio-app/portfolio.env

    systemctl daemon-reload
    systemctl enable --now portfolio-app
  EOF

  tags = {
    Name = "my-portfolio-server"
  }
}
