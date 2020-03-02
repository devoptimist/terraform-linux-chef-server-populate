################## connection #####################
variable "ip" {
  description = "An ip addresses where we will stage pushes to the chef server (pushes include roles, environments, policyfiles, policygroups, cookbooks"
  type        = string
}

variable "user_name" {
  description = "The ssh user name used to access the ip addresses provided" 
  type        = string
}

variable "user_pass" {
  description = "The ssh user password used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = string
  default     = ""
}

variable "user_private_key" {
  description = "The ssh user key used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = string
  default     = ""
}

############ misc ###############################

variable "populate" {
  description = "Set to false if you only want to create the chef-repo directory (with knife.rb and keys) and you do not want to populate the chef server"
  type        = bool
  default     = true
}

variable "system_type" {
  description = "The system type linux or windows"
  type        = string
  default     = "linux"
}

variable "jq_linux_url" {
  description = "A url to a jq binary to download, used in the install process"
  type        = string
  default     = "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
}

variable "jq_windows_url" {
  description = "A url to a jq binary to download, used in the install process"
  type        = string
  default     = "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe"
}

variable "linux_tmp_path" {
  description = "The location of a temp directory to store install scripts on"
  type        = string
  default     = "/var/tmp"
}

variable "windows_tmp_path" {
  description = "The location of a temp directory to store install scripts on"
  type        = string
  default     = "C:\\chef_workstation"
}

variable "working_directory" {
  description = "The path to use for the working directory"
  type        = string
  default     = "chef_server_populate"
}

variable "linux_populate_script_name" {
  description = "The name to give the chef server populate script"
  type        = string
  default     = "chef_server_populate.sh"
}

variable "windows_populate_script_name" {
  description = "The name to give the chef server populate script"
  type        = string
  default     = "chef_server_populate.ps1"
}

############ populate server options ############

variable "linux_chef_repo_path" {
  description = "The path to the chef repo, this path is created and populated with berksfiles / policyfiles, the workstation uses pem, the org validator pem, and the knife.rb"
  type        = string
  default     = "/var/tmp/chef_workstation/chef-repo"
}

variable "windows_chef_repo_path" {
  description = "The path to the chef repo, this path is created and populated with berksfiles / policyfiles, the workstation uses pem, the org validator pem, and the knife.rb"
  type        = string
  default     = "C:\\chef_workstation\\chef-repo"
}

variable "workstation_user_name" {
  description = "The name of a chef user, used for workstation -> chef server interactions, can be left out if using the output of the srb3 chef server module in the chef_module variable"
  type        = string
  default     = ""
}

variable "workstation_user_pem" {
  description = "The content of the chef users client.pem (created at the same time as the user), can be left out if using the output of the srb3 chef server module in the chef_module variable"
  type        = string
  default     = ""
}

variable "workstation_org_pem" {
  description = "The content of the chef orgs client.pem (created at the same time as the org), can be left out if using the output of the srb3 chef server module in the chef_module variable"
  type        = string
  default     = ""
}

variable "workstation_org_url" {
  description = "The url to the chef users chef organisation on the chef server e.g. https://demo-chef-server-0.demo.net/organizations/acmecorp, can be left out if using the output of the srb3 chef server module in the chef_module variable"
  type        = string
  default     = ""
}

variable "chef_server_ssl_verify_mode" {
  description = "The ssl verify mode to use, if using self signed certs use :verify_none"
  type        = string
  default     = ":verify_none"
}

variable "berksfiles" {
  description = "A list of Maps used to populate each berksfile"
  type        = string
  default     = "[]"
}

variable "policyfiles" {
  description = "A list of Maps used to populate each policyfile" 
  type        = string
  default     = "[]"
}

variable "environments" {
  description = "A list of Maps used to populate each environments"
  type        = string
  default     = "[]"
}

variable "roles" {
  description = "A list of Maps used to populate each environments"
  type        = string
  default     = "[]"
}

variable "chef_module" {
  description = "The jsonencoded output of the https://registry.terraform.io/modules/srb3/chef-server/linux module. If you are not using this module then you need to specify workstation_user_name workstation_user_pem workstation_org_pem and workstation_org_url"
  type       = string
  default    = ""
}

############ module input ############

variable "module_input" {
  description = "A string input to the module, used to enforce module ordering. make this input the putput from a dependant module"
  type        = string
  default     = "no_dependency"
}
