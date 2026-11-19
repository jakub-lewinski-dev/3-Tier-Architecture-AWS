
# Security Group for SSM VPC Interface Endpoints
resource "aws_security_group" "ssm_endpoints" {
  name        = "my-portfolio-ssm-endpoints-sg"
  description = "Allow HTTPS from application EC2 to SSM endpoints"
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "my-portfolio-ssm-endpoints-sg"
  }
}

# Allow application EC2 to connect to SSM endpoints over HTTPS
resource "aws_vpc_security_group_ingress_rule" "ssm_endpoints_https" {
  security_group_id            = aws_security_group.ssm_endpoints.id
  description                  = "HTTPS from application EC2"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.app.id
}

# Allow application EC2 to reach SSM endpoints
resource "aws_vpc_security_group_egress_rule" "app_to_ssm_endpoints" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTPS to SSM VPC endpoints"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.ssm_endpoints.id
}

# Systems Manager endpoint
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.app[0].id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "my-portfolio-ssm"
  }
}

# Systems Manager Messages endpoint
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.app[0].id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "my-portfolio-ssmmessages"
  }
}

# EC2 Messages endpoint
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.app[0].id]
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "my-portfolio-ec2messages"
  }
}
