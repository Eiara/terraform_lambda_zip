variable "name" {
  description = "Name of the function payload thing"
}

variable "project_path" {
  description = "path to the function"
}

variable "output_path" {
  description = "where to write the payload zip"
}

# Optional settings

variable "runtime" {
  default = "python3.6"
  description = "Python runtime. defaults to 3.6."
}

variable "requirements_file" {
  default = ""
  description = "the path to the requirements file. Can be empty."
}