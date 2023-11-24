resource "aws_instance" "webserver_1" {
  depends_on = [
    aws_vpc.custom,
    #aws_subnet.private,
    aws_subnet.public,
    #aws_subnet.rds,
    aws_security_group.web_sg
  ]

  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  key_name      = "webserver"
  tags = {
    Name    = "web-server-1"
    Owner   = "iam"
    Progect = "lab-task"
  }
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/Users/v.sushchevich/.ssh/webserver")
    host        = aws_instance.webserver_1.public_ip
  }

  # Code for installing the softwares!
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install apache2 apache2-bin -y",
      "sudo apt install php libapache2-mod-php php-mysql -y",
      "sudo apt install mysql-server -y",
      "sudo apt install nodejs -y",
      #"sudo apt install npm -y",
      "sudo chown -R ubuntu:ubuntu /var/www/html/",
      "sudo echo 'webserver_1' > /var/www/html/index.html",
      "sudo systemctl restart apache2.service"
    ]
  }
}
output "webserver_1_public_ip" {
  description = "PublicIPadress of the EC2 instance"
  value       = aws_instance.webserver_1.public_ip
}
output "webserver_1_private_ip" {
  description = "PrivateIPadress of the EC2 instance"
  value       = aws_instance.webserver_1.private_ip
}
################################################################################
# resource "aws_instance" "webserver_2" {
#   depends_on = [
#     aws_vpc.custom,
#     aws_subnet.private,
#     aws_subnet.public,
#     aws_security_group.web_sg
#   ]

#   ami           = var.ami
#   instance_type = var.instance_type
#   subnet_id     = aws_subnet.public[1].id
#   key_name      = "webserver"
#   tags = {
#     Name    = "web-server-2"
#     Owner   = "iam"
#     Progect = "lab-task"
#   }
#   vpc_security_group_ids = [aws_security_group.web_sg.id]
#   # Code for installing the softwares!
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt update -y",
#       "sudo apt install postgresql-client -y",
#       "sudo apt install nginx -y",
#       "sudo chown -R ubuntu:ubuntu /var/www/html/",
#       "sudo echo 'webserver_2' > /var/www/html/index.html",
#       "sudo systemctl restart nginx.service"
#     ]
#   }

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = file("/Users/v.sushchevich/.ssh/webserver")
#     host        = aws_instance.webserver_2.public_ip
#   }
# }
resource "aws_key_pair" "web_auth" {
  key_name   = "webserver"
  public_key = file("/Users/v.sushchevich/.ssh/webserver.pub")

}

# output "webserver_2_public_ip" {
#   description = "PublicIPadress of the EC2 instance"
#   value       = aws_instance.webserver_2.public_ip
# }
# output "webserver_2_private_ip" {
#   description = "PrivateIPadress of the EC2 instance"
#   value       = aws_instance.webserver_2.private_ip
# }
# output "webserver_2_public_dns" {
#   value = aws_instance.webserver_2.public_dns
# }
