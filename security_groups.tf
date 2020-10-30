# every EC2 instance gets a basic amount of access
# the bare minimum is v4/v6 ping, teleport, and outbound internet.
# can be modulated later as necessary but this is a sane and safe start.

# the teleport node service on 3022 does not ever need to be internet-accessible
# it is arguably fine to expose but why risk it?

resource "aws_security_group" "ec2_default" {
  name        = "${var.name} ${var.project} default access"
  description = "default ec2 access"
  vpc_id      = var.vpc_id

  ingress {
    description = "teleport node service"
    from_port   = 3022
    to_port     = 3022
    protocol    = "tcp"
    ipv6_cidr_blocks = [
      data.terraform_remote_state.master_terraform.outputs.teleport_ipv6_block
    ]
  }

  egress {
    description      = "outbound internet access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "ipv4 ping"
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ipv6 ping"
    protocol         = "icmpv6"
    from_port        = -1
    to_port          = -1
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "ec2 default access"
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
