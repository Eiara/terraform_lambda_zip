module "zip_test" {
  source            = "../../../"
  name              = "simple_test"
  project_path      = "${path.module}/lambda"
  output_path       = "${path.module}/output"
  runtime           = "python3.6"
}
