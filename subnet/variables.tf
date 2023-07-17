variable "main_vpc_id"{
    type = string
}
variable "subnet_cider"{
    type = list(string)
}
variable "subnet_names"{
    type = map
}
variable "nat_name"{
    type = string
}
variable "IGW_id" {
    type = string
}