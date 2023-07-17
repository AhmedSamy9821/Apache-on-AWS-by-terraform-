/*security group / private instances / public instances / load balancers */

resource "aws_security_group" "aws-sg" {
  name        = "vm-sg"
  description = "Allow incoming connections"
  vpc_id      = var.main_vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  } 
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 
}

data "aws_ami" "instance_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "pub_instance_1" {
  ami = data.aws_ami.instance_ami.id
  instance_type = var.ec2_type
  subnet_id = var.pub_sub_1
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  source_dest_check      = false
  associate_public_ip_address = "true"
  tags = {
    Name= "proxy_1"
  }
  provisioner "local-exec" {
    command = "echo public-ip1 is ${self.public_ip} >> all-ips.text"
  }
  provisioner "local-exec" {
    command = "echo private-ip1 is ${self.private_ip} >> all-ips.text"
  }
  user_data = file("install_nginx.sh")
}

resource "aws_instance" "pub_instance_2" {
  ami = data.aws_ami.instance_ami.id
  instance_type = var.ec2_type
  subnet_id = var.pub_sub_2
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  source_dest_check      = false
  associate_public_ip_address = "true"
  tags = {
    Name= "proxy_2"
  }
  provisioner "local-exec" {
    command = "echo public-ip2 is ${self.public_ip} >> all-ips.text"
  }
  provisioner "local-exec" {
    command = "echo private-ip2 is ${self.private_ip} >> all-ips.text"
  }
  user_data = file("install_nginx.sh")
}

resource "aws_instance" "private_instance_1" {
  ami = data.aws_ami.instance_ami.id
  instance_type = var.ec2_type
  subnet_id = var.priv_sub_1
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  source_dest_check      = false
  associate_public_ip_address = false
  tags = {
    Name= "BE WS1"
  }
  provisioner "local-exec" {
    command = "echo private-ip3 is ${self.private_ip} >> all-ips.text"
  }
  user_data = file("install_apache.sh")
}

resource "aws_instance" "private_instance_2" {
  ami = data.aws_ami.instance_ami.id
  instance_type = var.ec2_type
  subnet_id = var.priv_sub_2
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  source_dest_check      = false
  associate_public_ip_address = false
  tags = {
    Name= "BE WS2"
  }
  provisioner "local-exec" {
    command = "echo private-ip4 is ${self.private_ip} >> all-ips.text"
  }
  user_data = file("install_apache.sh")
}

/*public load balancer*/

resource "aws_lb" "pub_lb" {
  name               = "terraform-pub-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws-sg.id]
  subnets            = [var.pub_sub_1 , var.pub_sub_2 ]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "pub_tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.main_vpc_id
  
}

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = aws_lb.pub_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pub_tg.arn
  }
}
resource "aws_lb_target_group_attachment" "pub_tg_1" {
  target_group_arn = aws_lb_target_group.pub_tg.arn
  target_id        = aws_instance.pub_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "pub_tg_2" {
  target_group_arn = aws_lb_target_group.pub_tg.arn
  target_id        = aws_instance.pub_instance_2.id
  port             = 80
}
/*private load balancer*/

resource "aws_lb" "priv_lb" {
  name               = "terraform-priv-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.aws-sg.id]
  subnets            = [var.priv_sub_1 , var.priv_sub_2 ]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "priv_tg" {
  name     = "priv-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.main_vpc_id
  
}

resource "aws_lb_listener" "priv_web_http" {
  load_balancer_arn = aws_lb.priv_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.priv_tg.arn
  }
}
resource "aws_lb_target_group_attachment" "priv_tg_1" {
  target_group_arn = aws_lb_target_group.priv_tg.arn
  target_id        = aws_instance.private_instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "priv_tg_2" {
  target_group_arn = aws_lb_target_group.priv_tg.arn
  target_id        = aws_instance.private_instance_2.id
  port             = 80
}