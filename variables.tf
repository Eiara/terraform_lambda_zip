variable "name" {
  description = "Name of the function payload"
}

variable "project_path" {
  description = "path to the function"
}

variable "output_path" {
  description = "where to write the payload zip"
}

# Optional settings

variable "runtime" {
  description = "What runtime. Currently supported: python, nodejs"
}

variable "dependencies_file" {
  default     = ""
  description = "the path to the dependencies file. Can be empty."
}

variable "requirements_file" {
  default     = ""
  description = "DEPRECATED: use dependencies_file"
}

variable "custom_install_commands" {
  type        = list(string)
  description = ""
  default = [
    "",
  ]
}

locals {
  dependencies_file = var.requirements_file != "" ? var.requirements_file : var.dependencies_file != "" ? var.dependencies_file : ""
}

