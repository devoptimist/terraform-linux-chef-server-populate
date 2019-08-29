output "workstation_user_name" {
  value = data.external.workstation_details.result["workstation_user_name"]
}

output "workstation_user_pem" {
  value = data.external.workstation_details.result["workstation_user_pem"]
}

output "workstation_org_pem" {
  value = data.external.workstation_details.result["workstation_org_pem"]
}

output "workstation_org_url" {
  value = data.external.workstation_details.result["workstation_org_url"]
}

output "workstation_org_name" {
  value = data.external.workstation_details.result["workstation_org_name"]
}
