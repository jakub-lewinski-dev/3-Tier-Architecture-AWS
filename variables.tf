variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "Region AWS dla infrastruktury"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Blok CIDR dla VPC"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "Blok CIDR dla publicznej podsieci"
}

variable "availability_zone" {
  type        = string
  default     = "eu-central-1a"
  description = "Strefa dostępności dla podsieci"
}