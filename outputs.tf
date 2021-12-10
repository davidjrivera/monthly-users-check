output "lambda" {
  description = "The qualified ARN of the Lambda function"
  value       = aws_lambda_function.lambda.qualified_arn
}
### new below here
output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda.arn
}
output "role" {
  description = "The name of the IAM role created for the Lambda function"
  value       = aws_iam_role.iam_for_lambda.name
}
output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

