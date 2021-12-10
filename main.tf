provider "aws" {
  region     = "us-west-2"
}


provider "archive" {}

#############################
# Insert python script here #
#############################

data "archive_file" "zip" {
  output_path = var.output_path
  source_file = var.source_file
  type        = "zip"
}

############################################################################
# Generates Policy Doc in JSON to be used in resource "aws_iam_role" below #
############################################################################

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

#############################################################################
# Creating a generic Lambda Role for this Lambda - just name it accordingly #
#############################################################################

resource "aws_iam_role" "iam_for_lambda" {
  assume_role_policy = data.aws_iam_policy_document.policy.json
  name          = "${var.name}-role"
}


###########################################################################
# This secrets manager piece is use to send emails via SES using the UCOP #
# GLOBAL SES setup. This AWS maanged policy will get attached to the role #
# created for this Lambda                                                 #
###########################################################################

data "aws_iam_policy" "secret_manager" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

###############################################################################
# The creation of an INLINE policy that also will be added to the Lambda role #
# used to create the appropriate priviledges for SES and CloudWatch           # 
############################################################################### 

resource "aws_iam_policy" "lambda_logging" {
  description = "IAM policy for logging from a lambda"
  name         = var.name
  path        = "/"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "iam:ListAccountAliases",
        "iam:ListUsers",
        "iam:ListUserTags",
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

####################################################################################
# Attaching the newly created INLINE policy to the new generic Lambda role created # 
####################################################################################

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  count      = var.enabled ? 1 : 0
  policy_arn = aws_iam_policy.lambda_logging.arn
  role       = aws_iam_role.iam_for_lambda.name
}

#################################################################################################
# Attaching the AWS maanged policy for "secrets manager" to the new generic Lambda role created #
#################################################################################################

resource "aws_iam_role_policy_attachment" "secrets_lambda_logs" {
  count      = var.enabled ? 1 : 0
  policy_arn = data.aws_iam_policy.secret_manager.arn
  role       = aws_iam_role.iam_for_lambda.name
}

###################################################################
# Needed to create the CloudWatch Event Rule - name it accordigly #
###################################################################

resource "aws_cloudwatch_event_rule" "every_thirty" {
  description         = "Fires off based off the schedule in the schedule_expression"
  name                = var.name
  schedule_expression = "cron(00 23 6 * ? *)"
}

################################################################################
# Setup the necessary CloudWatch Events, or as now as it is called EventBridge #
################################################################################

resource "aws_cloudwatch_event_target" "check_every_thirty" {
  count     = var.enabled ? 1 : 0
  arn       = aws_lambda_function.lambda.arn
  rule      = aws_cloudwatch_event_rule.every_thirty.name
  target_id = "lambda"
}

##############################################################################
# Gives CloudWatch Event Rule, SNS permission to access the Lambda function. #
#  Note this piece can also be used for SNS, S3 if those services were used  #
##############################################################################

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check" {
  count         = var.enabled ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_thirty.arn
  statement_id  = "AllowExecutionFromCloudWatch"
}

#######################################################################################
# The actual Lambda function, this one example uses a runtime of python3.8            #
# NOTE: besure to use the latest runtimes for whatever language you are writing it in #
# we have had to upgrade the runtime because AWS  depricates older runtimes.          #
#######################################################################################

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.zip.output_path
  function_name    = "month-user-check--lambda"
  function_name    = var.name
  handler          = "${var.name}.lambda_handler"
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.8"
  timeout       = 10
  source_code_hash = data.archive_file.zip.output_base64sha256
  #tags             = merge(var.tags, map("Name", var.name))
  tags = {
     "ucop:application" = "test"
     "ucop:createdBy"   = "terraform"
     "ucop:environment"  = "Prod"
     "ucop:group"       = "test"
     "Name"             = var.name
     "ucop:owner"       = "chs"
  }

  environment {
    variables = {
      createdBy   = "David Rivera"
    }
  }
}
