# Include all settings from root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  enabled     = true
  output_path = "monthly-user.zip"
  source_file = "monthly-user.py"

  tags = {
    "ucop:application" = local.application
    "ucop:createdBy"   = local.createdBy
    "ucop:environment" = local.environment
    "ucop:group"       = local.group
    "ucop:source"      = local.source
  }
}

locals {
 # common_vars = jsondecode(file("../../../../common_vars.json"))
  application = local.common_vars.applications.lambda.label
  createdBy   = join(" ", ["terraform :", local.common_vars.creators.david.email])
 # environment = local.common_vars.environments.dev.label
 # group       = local.common_vars.groups.chs.label
  source      = "https://github.com/ucopacme/ucop-terraform-config.git"
}

terraform {
  source = "git::https://git@github.com/ucopacme/terraform-aws-lambda-check-user.git//?ref=v0.0.2"
}
# comment
