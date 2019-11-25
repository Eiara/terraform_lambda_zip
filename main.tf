terraform {
  required_version = "~> 0.11.2"
}

locals {
  engine_lookup = {
    "python2.7"  = "python"
    "python3.7"  = "python"
    "python3.6"  = "python"
    "nodejs10.x" = "nodejs"
    "nodejs8.10" = "nodejs"
    "nodejs6.10" = "nodejs"
  }

  custom = {
    install = "${join(" && ", compact(var.custom_install_commands))}"
  }
}

data "null_data_source" "engine" {
  inputs = {
    engine = "${lookup(local.engine_lookup, var.runtime)}"
  }
}

# Sha the requirements file. This determines whether or not we need to
# rebuild the dependencies (which will trigger whether or not we need to rebuild)
# the payload


data "external" "dependencies_sha" {
  program = ["bash", "${path.module}/scripts/dependencies_sha.sh"]

  query = {
    dependencies_file = "${local.dependencies_file != "" ? local.dependencies_file : "null" }"
    name              = "${var.name}"
  }

  # returns 1 result, a sha
}

# Determines if the project has changed
# If it has, we need to rebuild the project

data "external" "project_sha" {
  program = ["bash", "${path.module}/scripts/${data.null_data_source.engine.outputs["engine"]}/project_sha.sh"]

  query = {
    project_path = "${var.project_path}"
  }

  # returns 1 result, a sha
}

data "external" "payload_exists" {
  program = ["python", "${path.module}/scripts/payload_exists.py"]

  query = {
    name        = "${var.name}"
    output_path = "${var.output_path}"
  }

  # Returns a stable identifier to determine whether or not
  # a payload archive actually exists, to provide a metadata
  # codepoint to tell if a user has, in fact, deleted the payload
  # file without changing the project or requirements
  # returns: identifier
}

# This will create a new work directory only if the requirements
# has changed

resource "null_resource" "make_project_work_dir" {
  triggers {
    requirements = "${data.external.dependencies_sha.result["sha"]}"

    # the dependencies has been explicitly deleted already, by the cleanup code
    # later on, so if the project has changed we need to rebuild it
    project = "${data.external.project_sha.result["sha"]}"
    payload_exists = "${data.external.payload_exists.result["identifier"]}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/mktmp.sh project ${data.external.project_sha.result["sha"]}"
  }
}

resource "null_resource" "build_payload" {
  triggers {
    build_dependencies = "${null_resource.build_dependencies.id}"
    payload_exists     = "${data.external.payload_exists.result["identifier"]}"
  }

  depends_on = [
    "null_resource.make_project_work_dir",
    "null_resource.build_dependencies"
  ]

  provisioner "local-exec" {
    # Which runtime we're using
    # Where we're building
    # our SHA, to tell where our work directory is
    # The requirements SHA, so we know where our environment is
    command = "${path.module}/scripts/${data.null_data_source.engine.outputs["engine"]}/build_payload.sh"

    environment {
      PAYLOAD_NAME    = "${var.name}"
      PAYLOAD_RUNTIME = "${var.runtime}"
      PROJECT_PATH    = "${var.project_path}"
      PROJECT_SHA     = "${data.external.project_sha.result["sha"]}"
      WORK_SHA        = "${data.external.project_sha.result["sha"]}"
      OUTPUT_PATH     = "${var.output_path}"
      FILENAME        = "${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f ${var.output_path}/${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
  }
}

resource "null_resource" "build_dependencies" {
  triggers {
    project_sha      = "${data.external.project_sha.result["sha"]}"
    dependencies_sha = "${data.external.dependencies_sha.result["sha"]}"
    payload_exists   = "${data.external.payload_exists.result["identifier"]}"
  }

  depends_on = ["null_resource.make_project_work_dir"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/${data.null_data_source.engine.outputs["engine"]}/build_environment.sh"

    environment {
      PROJECT_PATH      = "${var.project_path}"
      RUNTIME           = "${var.runtime}"
      DEPENDENCIES_FILE = "${local.dependencies_file != "" ? local.dependencies_file : "null"}"
      WORK_SHA  = "${data.external.project_sha.result["sha"]}"
      CUSTOM_COMMANDS   = "${local.custom["install"]}"
    }
  }
}

resource "null_resource" "cleanup_environment_work_directory" {
  triggers {
    project = "${null_resource.build_payload.id}"
  }

  depends_on = ["null_resource.build_payload"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/cleanup.sh ${data.external.dependencies_sha.result["sha"]}"
  }
}

resource "null_resource" "cleanup_project_work_directory" {
  triggers {
    project = "${null_resource.build_payload.id}"
  }

  depends_on = ["null_resource.build_payload"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/cleanup.sh ${data.external.project_sha.result["sha"]}"
  }
}

data "external" "payload_sha" {
  program = ["bash", "${path.module}/scripts/payload_hash.sh"]

  depends_on = ["null_resource.build_payload"]

  query = {
    filename = "${var.output_path}/${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
    id       = "${null_resource.build_payload.id}"
  }
}
