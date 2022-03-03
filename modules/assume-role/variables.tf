
variable "name" {
  description = "The name of the IAM user"
  type        = string
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds between 3600 and 43200"
  type        = number
  default     = 3600
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
