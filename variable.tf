variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  default = "10.0.1.0/24"
}

variable "private_cidr_1" {
  default = "10.0.2.0/24"
}

variable "private_cidr_2" {
  default = "10.0.3.0/24"
}

variable "az1" {
  default = "us-east-1a"
}

variable "az2" {
  default = "us-east-1b"
}

variable "ami" {
  default = "ami-02dfbd4ff395f2a1b"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "N Virginia Key"
}