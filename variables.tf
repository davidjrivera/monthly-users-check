variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}
variable "name" {
  default     = null
  description = "Resource name"
  type        = string
}
variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}
variable "enabled" {
  default     = true
  description = "Set to `false` to prevent the module from creating resources"
  type        = bool
}
variable "output_path" {
  description = "Set to `false` to prevent the module from creating resources"
  type        = string
}
variable "source_file" {
  description = "Set to `false` to prevent the module from creating resources"
  type        = string
}
#variable "function_name" {
#  description = "Name of the function seen in the Lambda service "
#  type        = string
#}
#variable "handler" {
#  description = "Name of the Lambda Handler "
#  type        = string
#}
