#--------------------------------------------------------------
# Instance
#--------------------------------------------------------------
resource "aws_instance" "main" {
  instance_type = "t2.micro"

  # Trusty 14.04
  ami = "ami-02ace471"

  # This will create 1 instances
  count = 2

  subnet_id              = "${aws_subnet.main.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  key_name               = "deployer"
}

#--------------------------------------------------------------
# Security Group
#--------------------------------------------------------------
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "main" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "172.31.0.0/20"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key" 
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfuwia8lm5IMFUgiGddpu/9c4AYyqaYRpaXuncYCdk94gbKAYR0C+YrnI2/sx/GyVwie28qg85s40pF8K/ibzO7MMXd9wyMO9Spc4UNvWFvw17DbG774Ht8amvF9drE7BufP42h0RY4Rj4EXQBY63UP5xMMRpjfcnLS5NCxYl47juwwq0ASZe/0HKZ+hVKft0aXVrW0BwcYTEcl+KBFdDIBWZ1aFkN28zFf0isRGvQZueh3mcGldtletr2o046UTKVfm4CzyHl4YGgXFodpCa5uCWeGeZIFxdLihJtee5bd0SlCzOR5yUhSjrdwIwjaT+ddN5kSLyKxZg9ujBUonyZ root@nas.brandrick.net"
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.r.id}"
}
