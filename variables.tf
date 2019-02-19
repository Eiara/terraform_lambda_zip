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

variable "custom_install_commands" {
  type = "list"
  description = ""
  default = [
    "",
  ]
}