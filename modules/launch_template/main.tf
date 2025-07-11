resource "aws_launch_template" "this" {
  name = "EL2-${var.service}-${var.environment}-${var.version_label}-${var.iac_version}"

  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = var.security_groups
  }

  iam_instance_profile {
    name = var.instance_profile
  }

  key_name = var.key_name

  monitoring {
    enabled = true
  }

  ebs_optimized = var.ebs_optimized

  user_data = base64encode(templatefile("${path.module}/user_data.tpl", var.user_data_vars))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name            = "EL2-${var.environment}-${var.version_label}-${var.iac_version}-${var.service}"
      OldSearch       = "EL2-${var.environment}-${var.service}"
      ASG             = "true"
      "ECS:Environment" = var.user_data_vars["environment_tag"]
      "ECS:FismaId"    = "CIS-07038-MAJ-07038"
      "ECS:ServerFunction" = "TOMCAT_APP"
      "ECS:System"     = "Elis/Elis2"
      "ECS:Poc"        = "#ELIS2-SKynet@uscis.dhs.gov"
      "ECS:Scheduler:ec2-startstop" = "none"
      Purpose         = var.environment
      "ECS:DeviceType" = "Server"
      "ECS:OS"        = "Redhat 7"
    }
  }
}
