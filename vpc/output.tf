output "vpc_id"{
    value = aws_vpc.main_vpc.id
}
output "IGW_id"{
    value = aws_internet_gateway.IGW.id
}