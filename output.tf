output "path" {
  value = "${var.output_path}/${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
}

output "filename" {
  value = "${var.name}_${data.external.payload_exists.result["identifier"]}_payload.zip"
}

output "sha256" {
  value = "${data.external.payload_sha.result["sha"]}"
}

output "md5" {
  value = "${data.external.payload_sha.result["md5"]}"
}

