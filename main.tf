module "vpc"{
    source = "./vpc"
    cider = "10.0.0.0/16"
    vpc_name = "terraform_vpc"
    IGW_name = "terraform_GW"
}

module "subnets"{
    source = "./subnet"
    main_vpc_id = module.vpc.vpc_id
    subnet_cider = ["10.0.0.0/24" , "10.0.2.0/24" , "10.0.1.0/24" , "10.0.3.0/24"]
    subnet_names = {
        pub_sub1 = "public_subnet-1"
        pub_sub2 = "public_subnet-2"
        priv_sub1 = "private_subnet-1"
        priv_sub2 = "private_subnet-2"
    }
    nat_name = "terraform_nat"
    IGW_id = module.vpc.IGW_id
}

module "ec2"{
    source = "./ec2"
    main_vpc_id = module.vpc.vpc_id
    ec2_type = "t2.micro"
    pub_sub_1 = module.subnets.pub_sub_id_1
    pub_sub_2 = module.subnets.pub_sub_id_2
    priv_sub_1 = module.subnets.priv_sub_id_1
    priv_sub_2 = module.subnets.priv_sub_id_2
    lb_subnet = "subnet-0f544edabd3c0569b"
}