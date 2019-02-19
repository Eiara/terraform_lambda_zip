module "test" {
  source = "../../"
  
  name              = "nodejs_test"
  project_path      = "${path.module}/src"
  output_path       = "${path.module}/output"
  runtime           = "nodejs8.10"
  dependencies_file = "${path.module}/src/package.json"
}