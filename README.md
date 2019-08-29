# Overview
This module will connect to a server via ssh and run commands against a chef server. It expects that chef tools such as chef-workstation or chefdk are already installed. (you could use this module in conjuction with https://registry.terraform.io/modules/devoptimist/workshop-server/aws/0.0.2). Depending on the options passed to the module it will attempt to create roles, environments and upload cookbooks. Cookbook uploading handled via the creation of Berksfiles or Policyfiles. If specified policygroups are also created .
#### Supported platform families:
  * Debian
  * RHEL
  * SUSE

## Usage

```hcl

module "populate_chef_server" {
  source               = "devoptimist/chef-server-populate/linux"
  version              = "0.0.1"
  ips                  = "172.16.0.23"
  ssh_user_name        = "ec2-user"
  ssh_user_private_key = "~/.ssh/id_rsa"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|ip|A list of ip addresses where we will install hab and run services|list|[]|no|
|user_name|The ssh user name used to access the ip addresses provided|string||yes|
|user_pass|The ssh user password used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)|string|""|no|
|user_private_key|The ssh user key used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)|string|""|no|
|tmp_path|The path to use as the upload destination for any executabl scripts that need to be run|string|/var/tmp|no|
|populate_script_name|The name to give the chef server populate script|string|chef_server_populate.sh|no|
|chef_repo_path|The path to the chef repo, this path is created and populated with berksfiles / policyfiles, the workstation uses pem, the org validator pem, and the knife.rb|string|/var/tmp/chef_workstation/chef-repo|no|
|workstation_user_name|The name of a chef user, used for workstation -> chef server interactions, can be left out if using the output of the devoptimist chef server module in the chef_module variable|string||yes|
|workstation_user_pem|The content of the chef users client.pem (created at the same time as the user), can be left out if using the output of the devoptimist chef server module in the chef_module variable|string||yes|
|workstation_org_pem|The content of the chef orgs client.pem (created at the same time as the org), can be left out if using the output of the devoptimist chef server module in the chef_module variable|string||yes|
|workstation_org_url|The url to the chef users chef organisation on the chef server e.g. https://demo-chef-server-0.demo.net/organizations/acmecorp, can be left out if using the output of the devoptimist chef server module in the chef_module variable|string||yes|
|chef_server_ssl_verify_mode|The ssl verify mode to use, if using self signed certs use :verify_none|string|:verify_none|no|
|berksfiles|A list of Maps used to populate each berksfile|list|[]|no|
|policyfiles|A list of Maps used to populate each policyfile|list|[]|no|
|environments|A list of Maps used to populate each environments|list|[]|no|
|roles|A list of Maps used to populate each environments|list|[]|no|
|chef_module|The jsonencoded output of the https://registry.terraform.io/modules/devoptimist/chef-server/linux module. If you are not using this module then you need to specify workstation_user_name workstation_user_pem workstation_org_pem and workstation_org_url|string||no|
## Map/List Variable examples

### berksfiles

```hcl
berksfiles = [
  {
    "name" = "base_cookbooks",
    "default_source" = "'https://supermarket.chef.io'",
    "cookbooks" = {
      "audit" = "github: 'chef-cookbooks/audit', tag: 'v8.0.0'",
      "chef-client" = "github: 'chef-cookbooks/chef-client', tag: 'v11.3.0'"
    }
  }
]
```

### policyfiles

```hcl
policyfiles = [
  {
    "name" = "infra_base",
    "default_source" = ":supermarket, 'https://supermarket.chef.io'",
    "cookbooks" = {
      "audit" = "github: 'chef-cookbooks/audit', tag: 'v8.0.0'",
      "chef-client" = "github: 'chef-cookbooks/chef-client', tag: 'v11.3.0'"
    },
    "run_list" = ["chef-client::default","audit::default"],
    "groups" = ["dev","stage","prod"]
  }
]
```

### environments

```hcl
environments = [
  {
    "name" = "dev",
    "description" = "The acmecorp dev environment",
    "cookbook_versions" = {
      "audit" = "> 0.0.0",
      "chef-client" = "> 0.0.0"
    },
    "default_attributes" = {
      "audit" = {
        "reporter" = "chef-server-automate",
        "server" = "https://demo-chef-automate-0.demo.net",
        "token" = "mydatacollectortoken",
        "owner" = "admin"
      }
    },
    "override_attributes" = {
      "chef_client" = {
        "config" = {
          "ssl_verify_mode" = ":verify_none",
          "client_fork" = true
        }
      }
    }
  },
  {
    "name" = "stage",
    "description" = "The acmecorp staging environment",
    "cookbook_versions" = {
      "audit" = "= 8.1.1",
      "chef-client" = "= 11.3.0"
    },
    "default_attributes" = {
      "audit" = {
        "reporter" = "chef-server-automate",
        "server" = "https://demo-chef-automate-0.demo.net",
        "token" = "mydatacollectortoken",
        "owner" = "admin"
      }
    },
    "override_attributes" = {
      "chef_client" = {
        "config" = {
          "ssl_verify_mode" = ":verify_none",
          "client_fork" = true
        }
      }
    }
  },
  {
    "name" = "prod",
    "description" = "The acmecorp production environment",
    "cookbook_versions" = {
      "audit" = "= 8.0.0",
      "chef-client" = "= 11.2.0"
    },
    "default_attributes" = {
      "audit" = {
        "reporter" = "chef-server-automate",
        "server" = "https://demo-chef-automate-0.demo.net",
        "token" = "mydatacollectortoken",
        "owner" = "admin"
      }
    },
    "override_attributes" = {
      "chef_client" = {
        "config" = {
          "ssl_verify_mode" = ":verify_none",
          "client_fork" = true
        }
      }
    }
  }
]
```

### roles

```hcl
roles = [
  {
    "name" = "base",
    "description" = "This role describes the acmecorp base role",
    "default_attributes" = {
      "audit" = {
        "reporter" = "chef-server-automate",
        "server" = "https://demo-chef-automate-0.demo.net",
        "token" = "mydatacollectortoken",
        "owner" = "admin"
      }
    },
    "override_attributes" = {
      "chef_client" = {
        "config" = {
          "ssl_verify_mode" = ":verify_none",
          "client_fork" = true
        }
      }
    },
    "run_list" = ["chef-client::default", "chef-client::config", "audit::default"],
    "env_run_list" = {"prod" = ["chef-client::default", "audit::default"] }
  }
]
```
