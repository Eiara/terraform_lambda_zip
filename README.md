# Python-Lambda

This is a Terraform module implements the necessary moving parts to take a path that contains a Python project and a `requirements.txt` file, and will compile that path into a zip payload for deployment to AWS Lambda.

It _requires_ that you have the following packages installed:

 - `jq`
 - `pyenv`
 - `python2.7` and `python3.6`, selectable via `pyenv`
 - `virtualenv`, in the selected python runtime, installed via `pip`
 - `terraform` v0.11.2 or higher. This project _may_ be usable with lower, but it is _untested._

## How It Works

This module makes extensive use of `null_resource`s and temporary directories (from `$TMPDIR`) to construct a virtualenv and project directory that are zipped according to the [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html).

Because it uses temporary directories extensively, it _requires_ a user-provided output path to ensure that the written zip is not cleaned up during normal system maintenance.

Building a private virtualenv and project directory is used to perform `python -m compileall`, in order to create the appropriate `.pyc` files. This is done to ensure faster startup time for the Lambda function.

## Usage

```

    module "zip_test" {
      source            = "github.com/Eiara/terraform_lambda_zip"
      name              = "test"
      project_path      = "${path.module}/lambda"
      output_path       = "${path.module}/output_path"
      runtime           = "python3.6"
      requirements_file = "${path.module}/lambda/requirements.txt"
    }
```

- `name`:               the name of this zip. used to construct the payload zip filename.
- `project_path`:       The path to your Python lambda project, _not_ the `.py` file.
- `output_path`:        Where to write the final zip.
- `runtime`:            *Optional*. Defaults to `python3.6`.
- `requirements_file`:  *Optional*. Not providing a requirements.txt will still build a virtualenv, but will otherwise work normally.

## Outputs

- `path`: The path to the final zip. This will be in the form of `${var.name}_payload.zip`, to allow for multiple uses of this module in a project
- `sha256`: a `base64sha256()`-compatible sha256 representing the archive, for use in [source_code_hash](https://www.terraform.io/docs/providers/aws/r/lambda_function.html#source_code_hash).

## License

This project is copyright 2018 Eiara Limited, and licensed under the terms of the MIT license.