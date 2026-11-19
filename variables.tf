
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

variable "availability_zones" {
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
  description = "Strefy dostepnosci dla infrastruktury"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Bloki CIDR publicznych podsieci"
}

variable "app_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  description = "Bloki CIDR prywatnych podsieci aplikacji"
}

variable "db_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
  description = "Bloki CIDR prywatnych podsieci bazy danych"
}

