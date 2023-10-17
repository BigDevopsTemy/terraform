# provider "aws" {
#   version = "1.0"
#   region = "us-east-1"
#   access_key = "AKIAYFSLFDZ3AMYLBXLL"
#   secret_key = "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"
# }

# resource "aws" "name" {
  
# }


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

  }

  backend "s3" {
    bucket = "terraform-bucket-temi"
    key = "key/terraform.tfstate"
    region = "us-east-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  access_key = "AKIAYFSLFDZ3DA2JL7TO"
  secret_key = "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"
  #  region  = "us-east-1"
  # access_key = "AKIAYFSLFDZ3AMYLBXLL"
  # secret_key = "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"
}

#create VPC

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="mainVPC"
  }
  
}
#create internet gateway

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name="mIGW"
  }
}

#create a routeTable
resource "aws_route_table" "mainRouteTable" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block="0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_internet_gateway.id
    
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.main_internet_gateway.id
  }

  tags = {
    Name="mainRoute"
  }
    
  
  
}

resource "aws_subnet" "mainsubnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name ="mainsubnet"
  }
}

resource "aws_route_table_association" "routeTableAssociation" {
  subnet_id      = aws_subnet.mainsubnet.id
  route_table_id = aws_route_table.mainRouteTable.id
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "local"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow WEB"
  }
}

resource "aws_network_interface" "main_network_interface" {
  subnet_id       = aws_subnet.mainsubnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_tls.id]

  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  # }
}

resource "aws_eip" "main_elp" {
  
  vpc = true
  network_interface         = aws_network_interface.main_network_interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [ aws_internet_gateway.main_internet_gateway ]
}

resource "aws_instance" "mainVM" {
  ami           = "ami-03a6eaae9938c858c"
  instance_type = "t3.micro"
  # monitoring = true
  availability_zone = "us-east-1a"
  key_name = "terraform_keypair"
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.main_network_interface.id
  }
  # user_data = <<-EOF
  # #!/bin/bash
  # echo "*** Installing apache2"
  # sudo apt update -y
  # sudo apt install apache2 -y
  # echo "*** Completed Installing apache2"
  # EOF
                
  tags = {
    Name = "mainVM"
  }
}
# resource "aws_instance" "web-public1a" {
#   ami           = "ami-03a6eaae9938c858c"
#   instance_type = "t3.micro"
#   security_groups= ["sg-04ccba4e9a4bc75b0"]
#   subnet_id = "subnet-08c6cf2a72e590a48"
#   key_name = "terraform_keypair"
#   tags = {
#     Name = "InstancePublic1a"
#   }
# }
# resource "aws_instance" "web-public1b" {
#   ami           = "ami-03a6eaae9938c858c"
#   instance_type = "t3.micro"
#   security_groups= ["sg-04ccba4e9a4bc75b0"]
#   subnet_id = "subnet-0d36c591a3b9c7433"
#   key_name = "terraform_keypair"
#   tags = {
#     Name = "InstancePublic1b"
#   }
# }
# resource "aws_instance" "web-private1a" {
#   ami           = "ami-03a6eaae9938c858c"
#   instance_type = "t3.micro"
#   security_groups= ["sg-04ccba4e9a4bc75b0"]
#   subnet_id = "subnet-098611fd2e7629ff5"
#   key_name = "terraform_keypair"
#   tags = {
#     Name = "InstancePrivate1a"
#   }
# }
# resource "aws_instance" "web-private1b" {
#   ami           = "ami-03a6eaae9938c858c"
#   instance_type = "t3.micro"
#   security_groups= ["sg-04ccba4e9a4bc75b0"]
#   subnet_id = "subnet-02b27885225b985fb"
#   key_name = "terraform_keypair"
#   tags = {
#     Name = "InstancePrivate1b"
#   }
# }
