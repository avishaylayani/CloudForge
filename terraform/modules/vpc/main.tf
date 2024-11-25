resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "CloudForge"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "CloudForge_subnet"
  }
}