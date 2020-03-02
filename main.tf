locals {
  # below is a workarround for this bug: https://github.com/hashicorp/terraform/issues/21917 
  # once it is fixed this can be tidied up
  code = var.chef_module != "" ? var.chef_module : jsonencode({"node_name" = [var.workstation_user_name], "client_pem" = [var.workstation_user_pem], "validation_pem" = [var.workstation_org_pem], "org_url" = [var.workstation_org_url]})

  attribute_parser = templatefile("${path.module}/templates/attribute_parser.rb", {})

  # the module was originally intended to be compatible with linux and windows, however not any more due to the portability issues
  # with using an external data source. When the bug https://github.com/hashicorp/terraform/issues/21917 is fixed it can go back to being multi platform
  cmd              = var.system_type == "linux" ? "bash" : "powershell.exe"
  chef_repo_path   = var.system_type == "linux" ? var.linux_chef_repo_path : var.windows_chef_repo_path
  tmp_base         = var.system_type == "linux" ? var.linux_tmp_path : var.windows_tmp_path
  tmp_path         = "${local.tmp_base}/${var.working_directory}"
  data_source_name = var.system_type == "linux" ? "data_source.sh" : "data_source.ps1"
  script_name      = var.system_type == "linux" ? var.linux_populate_script_name : var.windows_populate_script_name
  jq_url           = var.system_type == "linux" ? var.jq_linux_url : var.jq_windows_url
  mkdir            = var.system_type == "linux" ? "mkdir -p" : "New-Item -ItemType Directory -Force -Path"
  populate_cmd     = var.system_type == "linux" ? "${local.tmp_path}/${local.script_name}" : "Invoke-Expression ${local.tmp_path}/${local.script_name} > ${local.tmp_path}/populate_script.log 2>&1"

  data_source = templatefile("${path.module}/templates/data_source", {
    data     = local.code,
    tmp_path = local.tmp_path,
    jq_url   = local.jq_url
    system   = var.system_type
  })

  populate_script = templatefile("${path.module}/templates/populate_file", {
    chef_repo_path              = local.chef_repo_path,
    berksfiles                  = var.berksfiles,
    policyfiles                 = var.policyfiles,
    chef_server_ssl_verify_mode = var.chef_server_ssl_verify_mode,
    environments                = var.environments,
    roles                       = var.roles,
    tmp_path                    = local.tmp_path,
    jq_url                      = local.jq_url,
    system                      = var.system_type,
    populate                    = var.populate
    workstation_user_name       = length(jsondecode(local.code)["node_name"]) > 0 ? jsondecode(local.code)["node_name"][0] : ""
    workstation_user_pem        = length(jsondecode(local.code)["client_pem"]) > 0 ? jsondecode(local.code)["client_pem"][0] : ""
    workstation_org_pem         = length(jsondecode(local.code)["validation_pem"]) > 0 ? jsondecode(local.code)["validation_pem"][0] : ""
    workstation_org_url         = length(jsondecode(local.code)["org_url"]) > 0 ? jsondecode(local.code)["org_url"][0] : ""
    module_input                = var.module_input
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
      "${local.mkdir} ${local.tmp_path}"
    ]
  }

  provisioner "file" {
    content     = local.attribute_parser
    destination = "${local.tmp_path}/attribute_parser.rb"
  }

  provisioner "file" {
    content     = local.data_source
    destination = "${local.tmp_path}/${local.data_source_name}"
  }

  provisioner "file" {
    content     = local.populate_script
    destination = "${local.tmp_path}/${local.script_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "${local.cmd} ${local.populate_cmd}"
    ]
  }
}

data "external" "workstation_details" {
  program = ["bash", "${path.module}/files/data_source.sh"]
  depends_on = [null_resource.populate_chef_server]

  query = {
    ssh_user      = var.user_name
    ssh_key       = var.user_private_key
    ssh_pass      = var.user_pass
    target_ip     = var.ip
    target_script = "${local.tmp_path}/${local.data_source_name}"
  }
}

resource "random_string" "module_hook" {
  depends_on       = [null_resource.populate_chef_server]
  length           = 16
  special          = true
  override_special = "/@\" "
}

data "null_data_source" "module_hook" {
  inputs = {
    data = jsonencode(random_string.module_hook[*].result)
  }
}
