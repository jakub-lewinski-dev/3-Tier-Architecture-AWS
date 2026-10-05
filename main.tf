terraform {
    required_version = ">= 1.0.0"
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "my-portfolio-vpc"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "my-portfolio-igw"
    }
}

resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone       = var.availability_zone

    tags = {
        Name = "my-portfolio-public-subnet"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "my-portfolio-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}
