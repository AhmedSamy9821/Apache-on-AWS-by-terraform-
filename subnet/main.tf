/*create subnets / nat_gateway / route tables / route table associations */

resource "aws_subnet" "public_subnet-1" {
  vpc_id     = var.main_vpc_id
  cidr_block = var.subnet_cider[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_names.pub_sub1
  }
}

resource "aws_subnet" "public_subnet-2" {
  vpc_id     = var.main_vpc_id
  cidr_block = var.subnet_cider[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = var.subnet_names.pub_sub2
  }
}

resource "aws_subnet" "private_subnet-1" {
  vpc_id     = var.main_vpc_id
  cidr_block = var.subnet_cider[2]
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_names.priv_sub1
  }
}

resource "aws_subnet" "private_subnet-2" {
  vpc_id     = var.main_vpc_id
  cidr_block = var.subnet_cider[3]
  availability_zone = "us-east-1b"

  tags = {
    Name = var.subnet_names.priv_sub2
  }
}
resource "aws_eip" "eip"{
    domain = "vpc"
}

resource "aws_nat_gateway" "terraform_nat"{
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.public_subnet-1.id
    tags = {
    Name = var.nat_name
  }
  depends_on = [var.IGW_id]
}

resource "aws_route_table" "rt_pub" {
  vpc_id = var.main_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.IGW_id
  }
}
resource "aws_route_table_association" "pub-1" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.rt_pub.id
}
resource "aws_route_table_association" "pub-2" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.rt_pub.id
}

resource "aws_route_table" "rt_private" {
  vpc_id = var.main_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.terraform_nat.id
  }
}

resource "aws_route_table_association" "priv-1" {
  subnet_id      = aws_subnet.private_subnet-1.id
  route_table_id = aws_route_table.rt_private.id
}
resource "aws_route_table_association" "priv-2" {
  subnet_id      = aws_subnet.private_subnet-2.id
  route_table_id = aws_route_table.rt_private.id
}
