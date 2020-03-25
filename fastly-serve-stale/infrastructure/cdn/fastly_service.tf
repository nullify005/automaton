# fastly_service_v1.www:
resource "fastly_service_v1" "www" {

  # This loops over the 'sites' variable and creates one Fastly service for each.
  # so we would have fastly_service_v1.www["smh"]
  for_each = var.sites

  activate        = tobool(var.activate)
  version_comment = "testing"
  force_destroy   = false
  comment         = "fastly-serve-stale"
  default_ttl     = 10
  name            = "fastly-serve-stale [${each.key}]"

  # Configure backends/origins...
  dynamic "backend" {
    for_each = each.value[*].origin

    content {
      name                  = "${terraform.workspace} ${each.key}"
      address               = tostring(backend.value)
      auto_loadbalance      = false
      between_bytes_timeout = 9000
      connect_timeout       = 1000
      error_threshold       = 0
      first_byte_timeout    = 9000
      max_conn              = 200
      port                  = 80
      healthcheck           = "Varnish Health - ${each.key}"
      # ssl_cert_hostname     = "*.ffxblue.com.au"
      # ssl_check_cert        = true
      use_ssl               = false
      weight                = 100
      shield                = "sydney-au"
    }
  }

  dynamic "domain" {
    for_each = flatten(each.value[*].domains)

    content {
      name = tostring(domain.value)
    }
  }

  ###########################################################

  healthcheck {
    check_interval    = var.health_interval
    expected_response = 200
    host              = tostring(var.sites["${each.key}"].origin)
    http_version      = "1.1"
    initial           = 1
    method            = "HEAD"
    name              = "Varnish Health - ${each.key}"
    path              = "/internal/health"
    threshold         = var.health_threshold
    timeout           = 5000
    window            = var.health_window
  }

  ###########################################################

  condition {
    name      = "fastly_edge"
    priority  = 10
    statement = "fastly.ff.visits_this_service == 0"
    type      = "RESPONSE"
  }

  ###########################################################

  dynamic "dynamicsnippet" {
    for_each = var.has_waf ? [1] : []

    content {
      name     = "Fastly_WAF_Snippet"
      priority = 10
      type     = "recv"
    }
  }

  dynamic "condition" {
    for_each = var.has_waf ? [1] : []

    content {
      name      = "WAF_Prefetch"
      priority  = 10
      statement = "req.backend.is_origin && !req.http.bypasswaf"
      type      = "PREFETCH"
    }
  }

  dynamic "response_object" {
    for_each = var.has_waf ? [1] : []

    content {
      content      = "403 Forbidden"
      content_type = "text/plain"
      name         = "WAF_Response"
      response     = "Forbidden"
      status       = 403
    }
  }

  ###########################################################

  gzip {
    content_types = ["application/javascript", "application/json", "application/vnd.ms-fontobject", "application/x-font-opentype", "application/x-font-truetype", "application/x-font-ttf", "application/x-javascript", "application/xml", "font/eot", "font/opentype", "font/otf", "image/svg+xml", "image/vnd.microsoft.icon", "text/css", "text/html", "text/javascript", "text/plain", "text/xml", ]
    extensions    = ["css", "eot", "html", "ico", "js", "json", "otf", "svg", "ttf", ]
    name          = "Default Gzip Policy"
  }

  ###########################################################

  backend {
    address               = "cdn.optimizely.com"
    auto_loadbalance      = false
    between_bytes_timeout = 10000
    connect_timeout       = 1000
    error_threshold       = 0
    first_byte_timeout    = 15000
    max_conn              = 200
    name                  = "cdn.optimizely.com"
    port                  = 443
    request_condition     = "Path Match - begins with - optimizelyjs"
    ssl_cert_hostname     = "cdn.optimizely.com"
    ssl_check_cert        = true
    ssl_sni_hostname      = "cdn.optimizely.com"
    use_ssl               = true
    weight                = 1000
  }

  condition {
    name      = "Path Match - begins with - optimizelyjs"
    priority  = 10
    statement = "req.url ~ \"^/optimizelyjs/\""
    type      = "REQUEST"
  }

  header {
    action            = "regex"
    destination       = "url"
    ignore_if_set     = false
    name              = "cdn.optimizely.com base"
    priority          = 10
    regex             = "^/optimizelyjs/"
    request_condition = "Path Match - begins with - optimizelyjs"
    source            = "req.url"
    substitution      = "/public/304207300/"
    type              = "request"
  }

  header {
    action            = "set"
    destination       = "http.Host"
    ignore_if_set     = false
    name              = "cdn.optimizely.com Host"
    priority          = 10
    request_condition = "Path Match - begins with - optimizelyjs"
    source            = "\"cdn.optimizely.com\""
    type              = "request"
  }


  ###########################################################

  condition {
    name      = "Serve static error page when no content available"
    priority  = 10
    statement = "req.http.serve-static-error"
    type      = "REQUEST"
  }

  response_object {
    content           = file("${path.module}/response/error.html")
    content_type      = "text/html"
    name              = "Serve static error page when no content available"
    request_condition = "Serve static error page when no content available"
    response          = "Service Unavailable"
    status            = 503
  }

  ###########################################################

  request_setting {
    bypass_busy_wait = false
    force_miss       = false
    force_ssl        = true
    geo_headers      = false
    max_stale_age    = 43200
    name             = "Force HTTPS, Serve stale"
    timer_support    = false
    xff              = "append"
  }

  dynamic "snippet" {
    for_each = var.serve_stale ? [1] : []
    content {
      name     = "fetch Serve Stale"
      content  = file("${path.module}/vcl_snippets/fetch_serve_stale.vcl")
      priority = 90
      type     = "fetch"
    }
  }

  snippet {
    name     = "enable ESI"
    content  = file("${path.module}/vcl_snippets/fetch_esi.vcl")
    priority = 100
    type     = "fetch"
  }

  snippet {
    content  = file("${path.module}/vcl_snippets/recv_esi.vcl")
    name     = "disable ESI shield"
    priority = 100
    type     = "recv"
  }

  snippet {
    name     = "Set env header"
    content  = file("${path.module}/vcl_snippets/recv_env_header.vcl")
    priority = 200
    type     = "recv"
  }

  snippet {
    name     = "Block bad request methods"
    content  = file("${path.module}/vcl_snippets/recv_block_methods.vcl")
    priority = 90
    type     = "recv"
  }

  snippet {
    name     = "Purge requires authentication"
    content  = "if (req.request == \"FASTLYPURGE\") {\n    set req.http.Fastly-Purge-Requires-Auth = \"1\";\n}\n"
    priority = 90
    type     = "recv"
  }

  snippet {
    name     = "Set client.geo.ip_override to preserve client IP when using shield"
    content  = "set client.geo.ip_override = req.http.Fastly-Client-IP;"
    priority = 100
    type     = "recv"
  }

  dynamic "snippet" {
    for_each = var.serve_stale ? [1] : []
    content {
      name     = "recv Serve Stale"
      content  = file("${path.module}/vcl_snippets/recv_serve_stale.vcl")
      priority = 110
      type     = "recv"
    }
  }

  snippet {
    name     = "Normalise Request Querystrings"
    content  = file("${path.module}/vcl_snippets/recv_querystring_normalise.vcl")
    priority = 1000
    type     = "recv"
  }

  dynamic "snippet" {
    for_each = var.serve_stale ? [1] : []
    content {
      name     = "deliver Serve Stale"
      content  = file("${path.module}/vcl_snippets/deliver_serve_stale.vcl")
      priority = 100
      type     = "deliver"
    }
  }

  dynamic "snippet" {
    for_each = var.serve_stale ? [1] : []
    content {
      name     = "error Serve Stale"
      content  = file("${path.module}/vcl_snippets/error_serve_stale.vcl")
      priority = 100
      type     = "error"
    }
  }
}


# output "urls" {
#   value = {
#     for site in keys(var.sites) :
#     site => {
#       "admin"   = "https://manage.fastly.com/configure/services/${fastly_service_v1.www[site].id}/versions/${fastly_service_v1.www[site].active_version}"
#       "domains" = [for key in flatten([var.sites[site].domains, "${site}-${terraform.workspace}.ffxblue.com.au"]) : "https://${key}"]
#     }
#   }
# }
