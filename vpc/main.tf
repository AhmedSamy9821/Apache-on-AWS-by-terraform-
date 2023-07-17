
/*create vpc / internet gateway */

resource "aws_vpc" "main_vpc" {
  cidr_block = var.cider
  tags = {
    Name = var.vpc_name
  }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = var.IGW_name
  }
}
