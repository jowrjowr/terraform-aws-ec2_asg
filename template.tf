
resource "aws_launch_template" "ec2_instance" {
  name          = var.name
  image_id      = var.ec2_ami
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name
  # nixos will boot into nix userdata directly
  # see: https://github.com/NixOS/nixpkgs/issues/37390
  # it will also, however, execute every time on boot.

  user_data = var.ec2_user_data

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.ec2_root_volume_size
      delete_on_termination = true
    }
  }
  network_interfaces {
    description                 = "${var.name} ${var.project} ${var.environment}"
    delete_on_termination       = true
    associate_public_ip_address = var.ec2_public_ip
    ipv6_address_count          = 1
    security_groups = concat(
      [aws_security_group.ec2_default.id],
      var.ec2_additional_security_groups
    )
  }

  # we want to tag both the instances and the volumes generated
  # otherwise there's a large amount of resources that are unmanagable mysteries

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = var.name
      terraform   = "true"
      project     = var.project
      environment = var.environment
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = var.name
      terraform   = "true"
      project     = var.project
      environment = var.environment
    }
  }


  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_instance.arn
  }

  tags = {
    Name        = var.name
    terraform   = "true"
    project     = var.project
    environment = var.environment
  }
}
