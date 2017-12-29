resource "aws_key_pair" "my_public_ssh_key" {
    key_name = "id_rsa1"
    public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "puppet-server" {
    ami = "ami-aa2ea6d0"
    instance_type = "t2.micro"
    availability_zone = "${var.AVAILABILITY_ZONE}"
    root_block_device {
      volume_size = "12"
      delete_on_termination = true
    }
    vpc_security_group_ids = ["${aws_security_group.puppet-server.id}"]
    key_name = "${aws_key_pair.my_public_ssh_key.key_name}"
    # connection {
    #   user = "${var.INSTANCE_USERNAME}"
    # }
    depends_on = ["aws_security_group.puppet-server"]
    user_data = "${file("server_install.sh")}"
    tags {
      Name = "MySQLServer"
    }
}



resource "aws_security_group" "puppet-server" {
    name = "ASG-for-MySQl-EC2"
    ingress {
      from_port = "${var.MYSQL-PORT}"
      to_port = "${var.MYSQL-PORT}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = "${var.SSH-PORT}"
      to_port = "${var.SSH-PORT}"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
      Name = "ASG-for-MySQLSERVER"
    }
}
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.17"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "foo"
  password             = "Epam-barT23#"
  publicly_accessible  = true
  vpc_security_group_ids = ["${aws_security_group.puppet-server.id}"]
}


output "puppet_server_dns" {
  value = "${aws_instance.puppet-server.public_dns}"
}
