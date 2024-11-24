
resource "aws_key_pair" "ssh_pub" {
  key_name   = "ssh_pub-key"
  public_key = file("technion-key.pub")
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "cicd_security_group"
  description = "Security group for CI/CD server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (adjust for better security)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS (Jenkins) from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "ec2_machines" {
  availability_zone = "us-east-1a"
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_pub.key_name
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  
  #user_data = file("script.sh")

  for_each = toset(var.instances)
  tags = {
    name =  "${each.value}"
  }
}

resource "local_file" "output_inventory_json" {
  content  = jsonencode([
    for instance in aws_instance.ec2_machines : {
      name = instance.tags["name"]
      ip   = instance.public_ip
    }
  ])
  filename = "inventory.json"
}

# output "instance_public_ip" {
#   value       = aws_instance.ec2_machines.public_ip
#   description = "The public IP address of the CD/CI server."
# }

# output "instance_ssh_command" {
#   value       = "ssh -i 'technion-key' ubuntu@${aws_instance.cicd.public_ip}"
#   description = "The SSH command to connect to the CI/CD server."
# }

output "private_key" {
  value     = file("technion-key")
  sensitive = true
}