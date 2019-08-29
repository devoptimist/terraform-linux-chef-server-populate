locals {
  # below is a workarround for this bug: https://github.com/hashicorp/terraform/issues/21917 
  # once it is fixed this can be tidied up
  code = var.chef_module != "" ? var.chef_module : jsonencode({"workstation_user_name" = [var.workstation_user_name], "workstation_user_pem" = [var.workstation_user_pem], "workstation_org_pem" = [var.workstation_org_pem], "workstation_org_url" = [var.workstation_org_url]})

  attribute_parser = templatefile("${path.module}/templates/attribute_parser.rb", {})
  data_source = templatefile("${path.module}/templates/data_source", {
    data         = local.code,
    tmp_path     = var.tmp_path,
    jq_linux_url = var.jq_linux_url
  })

  installer = templatefile("${path.module}/templates/populate_file", {
    data                        = local.code,
    chef_repo_path              = var.chef_repo_path,
    berksfiles                  = var.berksfiles,
    policyfiles                 = var.policyfiles,
    chef_server_ssl_verify_mode = var.chef_server_ssl_verify_mode,
    environments                = var.environments,
    roles                       = var.roles,
    tmp_path                    = var.tmp_path,
    jq_linux_url                = var.jq_linux_url
  })
}

resource "null_resource" "populate_chef_server" {

  triggers = {
    berksfiles   = md5(jsonencode(var.berksfiles))
    policyfiles  = md5(jsonencode(var.policyfiles))
    environments = md5(jsonencode(var.environments))
    roles        = md5(jsonencode(var.roles))
  }

  connection {
    user        = var.user_name
    password    = var.user_pass
    private_key = var.user_private_key != "" ? file(var.user_private_key) : null
    host        = var.ip
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.tmp_path}"
    ]
  }

  provisioner "file" {
    content     = local.attribute_parser
    destination = "${var.tmp_path}/attribute_parser.rb"
  }

  provisioner "file" {
    content     = local.data_source
    destination = "${var.tmp_path}/data_source.sh"
  }

  provisioner "file" {
    content     = local.installer
    destination = "${var.tmp_path}/${var.populate_script_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash ${var.tmp_path}/${var.populate_script_name}"
    ]
  }
}

data "external" "workstation_details" {

  program = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = ["null_resource.populate_chef_server"]

  query = {
    ssh_user      = var.user_name
    ssh_key       = var.user_private_key
    ssh_pass      = var.user_pass
    target_ip     = var.ip
    target_script = "${var.tmp_path}/data_source.sh"
  }
}
