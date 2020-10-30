
# leaving "terraform=false" as a created instance tag because they are NOT
# terraform-managed instances

resource "aws_autoscaling_group" "autoscaling" {
  name                = "${var.name}_${var.environment}"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = var.asg_subnets
  target_group_arns   = var.asg_target_groups
  health_check_type   = var.asg_health_check_type
  tags = [
    {
      key                 = "Name",
      value               = var.name
      propagate_at_launch = true
    },
    {
      key                 = "terraform",
      value               = false
      propagate_at_launch = true
    },
    {
      key                 = "project",
      value               = var.project
      propagate_at_launch = true
    },
    {
      key                 = "environment",
      value               = var.environment
      propagate_at_launch = true
    },
  ]

  launch_template {
    id      = aws_launch_template.ec2_instance.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}
