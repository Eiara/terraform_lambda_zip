module "zip_test" {
  source            = "../../../"
  name              = "test"
  project_path      = "${path.module}/lambda"
  output_path       = "${path.module}/output"
  runtime           = "python2.6"
}
