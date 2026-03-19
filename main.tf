terraform {
  backend "s3" {
    bucket = "terraform-3tier-infrastructure"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Define vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "3Tier-VPC"
  }
}

# Define public subnets
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_cidr
  availability_zone = var.az1
  map_public_ip_on_launch = true

  tags = { 
    Name = "Public-Subnet"     
  }

}

# Define private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_cidr_1
  availability_zone = var.az1

  tags = {
     Name = "Private-Subnet-1" 
  }
}


resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_cidr_2
  availability_zone = var.az2

  tags = { 
    Name = "Private-Subnet-2" 
  }
}   

# Define Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Define Route Table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Definne Security Groups

# Web SG
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App SG
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

# DB SG
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}

# Define EC2 Instances

# Web Server (Public)
resource "aws_instance" "web" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_subnet.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { 
    Name = "Web-Server"
  }
}

# App Server (Private)
resource "aws_instance" "app" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.private_subnet_1.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = { 
    Name = "App-Server"
  }
}

# Define RDS Instance

resource "aws_db_subnet_group" "db_subnet" {
  name = "db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "Admin12345"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}
