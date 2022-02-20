
variable "name" {
  description = "The name of the IAM user"
  type        = string
}

variable "additional_role_policy_document" {
  type    = string
  default = ""
}

variable "script_filename" {
  description = "script_filename"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
