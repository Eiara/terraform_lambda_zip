module "test" {
  source = "../../"
  
  name              = "python_test"
  project_path      = "${path.module}/src"
  output_path       = "${path.module}/output"
  runtime           = "python3.6"
  dependencies_file = "${path.module}/src/requirements.txt"
}