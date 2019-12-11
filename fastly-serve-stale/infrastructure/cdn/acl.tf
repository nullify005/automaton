
#resource "fastly_service_acl_entries_v1" "trustedhost" {
#  service_id = "${fastly_service_v1.www.id}"
#  acl_id     = { for d in fastly_service_v1.www.acl : d.name => d.acl_id }["trustedhost"]
#
#  lifecycle { ignore_changes = [entry, ] }
#
#  depends_on = [fastly_service_v1.www]
#}

# resource "fastly_service_acl_entries_v1" "badbot" {
#   service_id = "${fastly_service_v1.www.id}"
#   acl_id     = { for d in fastly_service_v1.www.acl : d.name => d.acl_id }["badbot"]
#
#   lifecycle { ignore_changes = [entry, ] }
#
#   depends_on = [fastly_service_v1.www]
# }
#
# output "badbot_acl" {
#   value = fastly_service_acl_entries_v1.badbot
# }
