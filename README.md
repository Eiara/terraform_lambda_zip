# Terraform-Lambda-Zip

This is a Terraform module implements the necessary moving parts to take a path that contains a Python or Node project and into a `.zip` payload for deployment to AWS Lambda.

It _requires_ that you have the following packages installed:

 - `jq`
 - `pyenv`
 - `openssl`
 - BSD `md5`
 - `python2.7` and `python3.6`, selectable via `pyenv`
 - `node` and `npm`
 - `virtualenv`, in the selected python runtime, installed via `pip`
 - `terraform` v0.11.2 or higher. This project _may_ be usable with lower, but it is _untested._
 
## Impetus

This module exists to make it easier to construct stable, long-lived zipped payloads for AWS Lambda functions, allowing for the Python or NodeJS Lambda functions to live in the same repository as the rest of the infracode.


## How It Works

This module makes extensive use of `null_resource`s and temporary directories (from `$TMPDIR`) to construct a project directory that is zipped according to the [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html).

Because it uses temporary directories extensively, it _requires_ a user-provided output path to ensure that the written zip is not cleaned up during normal system maintenance.

For Python, this project directory will include building a private virtualenv and running `python -m compileall`, in order to create the appropriate `.pyc` files. This is done to ensure faster startup time for the Lambda function.

Installing `node_modules` is handled in a temporary work directory, to avoid cluttering the repository.

Payload zip files are written in the form of `${var.name}_{epoch}_payload.zip`. This is done to provide a stable indicator of whether or not a file has been deleted, and if it needs to be re-created.

## Usage

```

    module "zip_test" {
      source            = "github.com/Eiara/terraform_lambda_zip"
      name              = "test"
      project_path      = "${path.module}/lambda"
      output_path       = "${path.module}/output_path"
      runtime           = "python3.6"
      dependencies_file = "${path.module}/lambda/requirements.txt"
    }
```

- `name`:               the name of this zip. used to construct the payload zip filename.
- `project_path`:       The path to your Python lambda project, _not_ the `.py` file.
- `output_path`:        Where to write the final zip.
- `runtime`:            supports nodejs6.10, nodejs8.10, python2.7, python3.6, python3.7
- `dependencies_file`:  *Optional*. Not providing a dependency file will otherwise work normally. This largely exists to support Python projects that update the requirements file out of band.

## Outputs

- `path`: The path to the final zip. This will be in the form of `${var.name}_{epoch}_payload.zip`, to allow for multiple uses of this module in a project
- `sha256`: a `base64sha256()`-compatible sha256 representing the archive, for use in [source_code_hash](https://www.terraform.io/docs/providers/aws/r/lambda_function.html#source_code_hash).
- `filename`: The filename being exported.
- `md5`: Suitable for using in the S3 bucket object etag.


## License

This project is Copyright 2018-2019 Eiara Limited, and licensed under the terms of the MIT license.