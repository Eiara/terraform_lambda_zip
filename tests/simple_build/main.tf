module "zip_test" {
  source            = "../../"
  name              = "test"
  project_path      = "${path.module}/lambda"
  output_path       = "${path.module}/output"
  runtime           = "python3.6"
  requirements_file = "${path.module}/lambda/requirements.txt"
}