
#resource "fastly_service_dictionary_items_v1" "ffxauth" {
#  for_each      = var.sites
#  service_id    = "${fastly_service_v1.www[each.key].id}"
#  dictionary_id = "${ { for s in fastly_service_v1.www["${each.key}"].dictionary : s.name => s.dictionary_id }["ffxauth"]}"
#  items = {
#    "covfefe" : true
#  }
#
#  lifecycle { ignore_changes = [items, ] }
#}
