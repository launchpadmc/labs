resource "aws_db_instance" "database" {
  identifier             = "instance-postgresql"
  instance_class         = "db.t3.micro"
  multi_az               = false
  storage_type           = "gp2"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.7"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db_sub.name
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
  username               = "postgres"                         #local.db_creds.username
  password               = random_password.db_password.result #local.db_creds.password #
}
# Firstly create a random generated password to use in secrets
resource "random_password" "db_password" {
  length  = 20
  special = false
  upper   = true
}

# connect to db "psql -h -p -U"
resource "aws_db_subnet_group" "db_sub" {
  name        = "postgresql-subnet"
  description = "RDS subnet group"
  subnet_ids  = aws_subnet.rds.*.id
}

output "rds_endpoint" {
  value = aws_db_instance.database.endpoint
}
#use command "terraform output db_password" for encrypt password
output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}