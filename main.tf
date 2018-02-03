# Sha the requirements file. This determines whether or not we need to
# rebuild the virtualenv (which will trigger whether or not we need to rebuild)
# the payload

data "external" "requirements_sha" {
  program = ["bash", "${path.module}/scripts/requirements_sha.sh"]

  query = {
    requirements_file = "${var.requirements_file != "" ? var.requirements_file : "null" }"
    name              = "${var.name}"
  }

  # returns 1 result, a sha
}

# Determines if the project has changed
# If it has, we need to rebuild the project

data "external" "project_sha" {
  program = ["bash", "${path.module}/scripts/project_sha.sh"]

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

/*locals {
  filename    = "${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
  output_path = "${var.output_path}/${local.filename}"
}*/


# This will create a new work directory only if the requirements
# has changed
resource "null_resource" "make_virtualenv_work_dir" {
  triggers {
    requirements = "${data.external.requirements_sha.result["sha"]}"

    # the virtualenv has been explicitly deleted already, by the cleanup code later on,
    # so if the project has changed we need to rebuild it
    project = "${data.external.project_sha.result["sha"]}"
    payload_exists = "${data.external.payload_exists.result["identifier"]}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/mktmp.sh virtualenv ${data.external.requirements_sha.result["sha"]}"
  }
}

resource "null_resource" "make_project_work_dir" {
  triggers {
    requirements = "${data.external.requirements_sha.result["sha"]}"

    # the virtualenv has been explicitly deleted already, by the cleanup code later on,
    # so if the project has changed we need to rebuild it
    project = "${data.external.project_sha.result["sha"]}"
    payload_exists = "${data.external.payload_exists.result["identifier"]}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/mktmp.sh project ${data.external.project_sha.result["sha"]}"
  }
}

resource "null_resource" "build_payload" {
  triggers {
    build_virtualenv = "${null_resource.build_virtualenv.id}"
    payload_exists = "${data.external.payload_exists.result["identifier"]}"
  }

  depends_on = [
    "null_resource.make_project_work_dir",
    "null_resource.make_virtualenv_work_dir",
    "null_resource.build_virtualenv",
  ]

  provisioner "local-exec" {
    # Which runtime we're using
    # Where we're building
    # our SHA, to tell where our work directory is
    # The requirements SHA, so we know where our virtualenv is
    command = "${path.module}/scripts/build_payload.sh ${var.name} ${var.runtime} ${var.project_path} ${data.external.project_sha.result["sha"]} ${data.external.requirements_sha.result["sha"]} ${var.output_path} ${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
  }
}

resource "null_resource" "build_virtualenv" {
  triggers {
    project_sha      = "${data.external.project_sha.result["sha"]}"
    requirements_sha = "${data.external.requirements_sha.result["sha"]}"
    payload_exists = "${data.external.payload_exists.result["identifier"]}"
  }

  depends_on = ["null_resource.make_virtualenv_work_dir"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/build_virtualenv.sh ${var.runtime} ${var.requirements_file != "" ? var.requirements_file : "null"} ${data.external.requirements_sha.result["sha"]}"
  }
}

resource "null_resource" "cleanup_virtualenv_work_directory" {
  triggers {
    project = "${null_resource.build_payload.id}"
  }

  depends_on = ["null_resource.build_payload"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/cleanup.sh ${data.external.requirements_sha.result["sha"]}"
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
  /*depends_on = [
    "null_resource.build_payload"
  ]*/
  program = ["bash", "${path.module}/scripts/payload_hash.sh"]

  query = {
    filename    = "${var.output_path}/${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
    id          = "${null_resource.build_payload.id}"
  }
}
