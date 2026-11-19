
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

source "amazon-ebs" "ubuntu" {
  region        = var.aws_region
  instance_type = "t3.small"

  vpc_id    = "vpc-03b40afd59d5a55bc"
  subnet_id = "subnet-028a212aaebabec6a"

  ami_name = "portfolio-app-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    owners      = ["099720109477"]
    most_recent = true
  }

  ssh_username = "ubuntu"

  associate_public_ip_address = true
  ssh_interface               = "public_ip"

  temporary_security_group_source_public_ip = true

  tags = {
    Name        = "portfolio-app-ami"
    Environment = "portfolio"
    ManagedBy   = "Packer"
  }
}

build {
  name    = "portfolio-app"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io curl",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo docker --version"
    ]
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /tmp/portfolio-app"
    ]
  }

  provisioner "file" {
    source      = "app/app.py"
    destination = "/tmp/portfolio-app/app.py"
  }

  provisioner "file" {
    source      = "app/Dockerfile"
    destination = "/tmp/portfolio-app/Dockerfile"
  }

  provisioner "file" {
    source      = "app/requirements.txt"
    destination = "/tmp/portfolio-app/requirements.txt"
  }

  provisioner "file" {
    source      = "scripts/portfolio-app.service"
    destination = "/tmp/portfolio-app.service"
  }

  provisioner "shell" {
    inline = [
      "if ! snap list amazon-ssm-agent >/dev/null 2>&1; then sudo snap install amazon-ssm-agent; fi",
      "sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service",
      "sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service",
      "sudo mkdir -p /tmp/portfolio-app/certs",
      "sudo curl -fsSL https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -o /tmp/portfolio-app/certs/rds-global-bundle.pem",
      "sudo docker build -t portfolio-app:latest /tmp/portfolio-app",
      "sudo docker image inspect portfolio-app:latest",
      "sudo install -m 0644 /tmp/portfolio-app.service /etc/systemd/system/portfolio-app.service",
      "sudo rm -rf /tmp/portfolio-app /tmp/portfolio-app.service"
    ]
  }
}
