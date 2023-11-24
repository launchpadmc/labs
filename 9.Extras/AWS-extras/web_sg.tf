resource "aws_security_group" "web_sg" {
  # Name of the security Group
  name        = "web-security-group"
  description = "HTTP, HTTPS, SSH, DB"

  depends_on = [
    aws_vpc.custom,
    aws_subnet.public,
    #aws_subnet.private,
    #aws_subnet.rds,
    aws_security_group.lb_sg
  ]
  # VPC ID in which Security group has to be created
  vpc_id = aws_vpc.custom.id

  ingress {
    description     = "HTTP for web"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  # ingress {
  #   description = "database connect"
  #   from_port   = 5432
  #   to_port     = 5433
  #   protocol    = "tcp"
  #   cidr_blocks = ["${var.subnet_cidr_private}"]
  # }
  # ingress {
  #   description = "redis cluster"
  #   from_port   = 6379
  #   to_port     = 6379
  #   protocol    = "tcp"
  #   cidr_blocks = var.subnet_cidrs
  # }
  # ingress {
  #   description = "memcache cluster"
  #   from_port   = 11211
  #   to_port     = 11211
  #   protocol    = "tcp"
  #   cidr_blocks = var.subnet_cidrs
  # }

  # ingress {
  #   description = "HTTPS for web"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # Created an inbound rule for SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  # Outward Network Traffic
  egress {
    description = "output from webserver"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "lb_sg" {
  # Name of the security Group
  name        = "lb-group"
  description = "HTTP"
  vpc_id      = aws_vpc.custom.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "output from webserver"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
output "lbname" {
  value = aws_security_group.lb_sg.id
}
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# resource "aws_subnet" "rds" {
#   count = length(var.subnet_rds)
#   depends_on = [
#     aws_vpc.custom
#   ]
#   vpc_id                  = aws_vpc.custom.id
#   cidr_block              = element(var.subnet_rds, count.index)
#   availability_zone       = element(var.az_rds, count.index)
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "${element(var.az_rds, count.index)} - RDS Subnet"
#   }
# }

