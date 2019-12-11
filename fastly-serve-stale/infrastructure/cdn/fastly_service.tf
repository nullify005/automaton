# fastly_service_v1.www:
resource "fastly_service_v1" "www" {

  # This loops over the 'sites' variable and creates one Fastly service for each.
  # so we would have fastly_service_v1.www["smh"]
  for_each = var.sites

  activate        = tobool(var.activate)
  version_comment = "${var.version_comment}"
  force_destroy   = false
  comment         = "https://bitbucket.org/ffxblue/service-cdn-render-web/"
  default_ttl     = 10
  name            = "render-web [${each.key}] [${terraform.workspace}]"

  # Configure backends/origins...
  dynamic "backend" {
    for_each = each.value[*].origin

    content {
      name                  = "${terraform.workspace} ${each.key}"
      address               = tostring(backend.value)
      auto_loadbalance      = false
      between_bytes_timeout = 10000
      connect_timeout       = 1000
      error_threshold       = 0
      first_byte_timeout    = 15000
      max_conn              = 200
      port                  = 443
      healthcheck           = "Varnish Health - ${each.key}"
      ssl_cert_hostname     = "*.ffxblue.com.au"
      ssl_check_cert        = true
      use_ssl               = true
      weight                = 100
    }
  }

  # Always create a <brand>-<env>.ffxblue.com.au...
  domain {
    name = "${each.key}-${terraform.workspace}.ffxblue.com.au"
  }

  # Always create a <brand>-<env>.cdn.9pub.io...
  domain {
    name = "${each.key}-${terraform.workspace}.cdn.9pub.io"
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

  # Pre-production restrictions...

  dictionary { name = "ffxauth" }
  acl { name = "trustedhost" }

  condition {
    name      = "Auth Cookie not set on non-www"
    priority  = 5
    statement = "req.http.host !~ \"^www\\.\" && !req.http.ffxauth"
    type      = "REQUEST"
  }

  dynamic "snippet" {
    for_each = terraform.workspace != "production" ? [1] : []

    content {
      content  = file("${path.module}/vcl_snippets/recv_ffxauth.vcl")
      name     = "ffxauth"
      priority = 1
      type     = "recv"
    }
  }

  dynamic "response_object" {
    for_each = terraform.workspace != "production" ? [1] : []

    content {
      content           = file("${path.module}/response/deny_access.html")
      content_type      = "text/html"
      name              = "Deny access (403) and link to welcome.ffxblue.com.au"
      request_condition = "Auth Cookie not set on non-www"
      response          = "Forbidden"
      status            = 403
    }
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

  backend {
    address               = "infrastructure-static-error-pages.apse2.ffx.io"
    auto_loadbalance      = false
    between_bytes_timeout = 10000
    connect_timeout       = 1000
    error_threshold       = 0
    first_byte_timeout    = 15000
    max_conn              = 200
    name                  = "static error origin"
    port                  = 80
    request_condition     = "Path Match - begins with - 50x"
    use_ssl               = false
    weight                = 1000
  }

  condition {
    name      = "Path Match - begins with - 50x"
    priority  = 10
    statement = "req.url ~ \"^/50x/\""
    type      = "REQUEST"
  }

  header {
    action            = "set"
    destination       = "http.Host"
    ignore_if_set     = false
    name              = "infrastructure-static-error-pages.apse2.ffx.io Host"
    priority          = 10
    request_condition = "Path Match - begins with - 50x"
    source            = "\"infrastructure-static-error-pages.apse2.ffx.io\""
    type              = "request"
  }

  # Set the error path in a header specific to the service
  header {
    action      = "set"
    destination = "http.serve-static-error-path"
    name        = "Static Error Page Path"
    priority    = 10
    source      = "\"${tostring(var.sites["${each.key}"].static_error_path)}\""
    type        = "request"
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

  ###########################################################

  s3logging {
    bucket_name        = "infrastructure-logging-cdn.apse2.ffx.io"
    domain             = "s3-ap-southeast-2.amazonaws.com"
    format             = "${module.logging.access_log}"
    format_version     = 2
    gzip_level         = 0
    message_type       = "blank"
    name               = "S3-logging"
    path               = "/fastly/${var.fastly-service-name}/${terraform.workspace}/access/"
    period             = 15
    redundancy         = "standard"
    s3_access_key      = var.logging_aws_access_key
    s3_secret_key      = var.logging_aws_secret_key
    timestamp_format   = "%Y-%m-%dT%H:%M:%S.000"
    response_condition = "fastly_edge"
  }

  dynamic "s3logging" {
    for_each = var.has_waf ? [1] : []

    content {
      bucket_name        = "infrastructure-logging-cdn.apse2.ffx.io"
      domain             = "s3-ap-southeast-2.amazonaws.com"
      format             = "${replace(file("${path.module}/log_format/nine-waflog.txt"), "\n", "")}"
      format_version     = 2
      gzip_level         = 9
      message_type       = "blank"
      name               = "Logging Endpoints (WAF)"
      path               = "/fastly/render-web/production/waf/"
      period             = 60
      placement          = "waf_debug"
      redundancy         = "standard_ia"
      s3_access_key      = var.logging_aws_access_key
      s3_secret_key      = var.logging_aws_secret_key
      response_condition = "fastly_edge"
      timestamp_format   = "%Y-%m-%dT%H:%M:%S.000"
    }
  }

  ###########################################################

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

  ###########################################################

  # Block clients that are in the "badbot" ACL.

  acl { name = "badbot" }

  condition {
    name      = "badbot"
    priority  = 10
    statement = "req.http.Fastly-Client-IP ~ badbot"
    type      = "REQUEST"
  }

  response_object {
    content           = file("${path.module}/response/badbot.html")
    content_type      = "text/html"
    name              = "badbot"
    request_condition = "badbot"
    response          = "Rate Limit"
    status            = 429
  }

  header {
    action            = "set"
    destination       = "http.ACL:badbot"
    ignore_if_set     = false
    name              = "badbot ACL"
    priority          = 10
    request_condition = "badbot"
    source            = "req.http.Fastly-Client-IP"
    type              = "request"
  }

  ###########################################################

  dynamic "syslog" {
    for_each = var.has_waf ? [1] : []

    content {
      address        = "104.197.173.239"
      format         = "${replace(file("${path.module}/log_format/soc-weblogs.txt"), "\n", "")}"
      format_version = 2
      message_type   = "blank"
      name           = "soc-weblogs"
      port           = 9555
      tls_ca_cert    = "-----BEGIN CERTIFICATE-----\nMIIEaTCCA1GgAwIBAgILBAAAAAABRE7wQkcwDQYJKoZIhvcNAQELBQAwVzELMAkG\nA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jv\nb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xNDAyMjAxMDAw\nMDBaFw0yNDAyMjAxMDAwMDBaMGYxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i\nYWxTaWduIG52LXNhMTwwOgYDVQQDEzNHbG9iYWxTaWduIE9yZ2FuaXphdGlvbiBW\nYWxpZGF0aW9uIENBIC0gU0hBMjU2IC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IB\nDwAwggEKAoIBAQDHDmw/I5N/zHClnSDDDlM/fsBOwphJykfVI+8DNIV0yKMCLkZc\nC33JiJ1Pi/D4nGyMVTXbv/Kz6vvjVudKRtkTIso21ZvBqOOWQ5PyDLzm+ebomchj\nSHh/VzZpGhkdWtHUfcKc1H/hgBKueuqI6lfYygoKOhJJomIZeg0k9zfrtHOSewUj\nmxK1zusp36QUArkBpdSmnENkiN74fv7j9R7l/tyjqORmMdlMJekYuYlZCa7pnRxt\nNw9KHjUgKOKv1CGLAcRFrW4rY6uSa2EKTSDtc7p8zv4WtdufgPDWi2zZCHlKT3hl\n2pK8vjX5s8T5J4BO/5ZS5gIg4Qdz6V0rvbLxAgMBAAGjggElMIIBITAOBgNVHQ8B\nAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUlt5h8b0cFilT\nHMDMfTuDAEDmGnwwRwYDVR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYBBQUHAgEWJmh0\ndHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMDMGA1UdHwQsMCow\nKKAmoCSGImh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5uZXQvcm9vdC5jcmwwPQYIKwYB\nBQUHAQEEMTAvMC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWxzaWduLmNv\nbS9yb290cjEwHwYDVR0jBBgwFoAUYHtmGkUNl8qJUC99BM00qP/8/UswDQYJKoZI\nhvcNAQELBQADggEBAEYq7l69rgFgNzERhnF0tkZJyBAW/i9iIxerH4f4gu3K3w4s\n32R1juUYcqeMOovJrKV3UPfvnqTgoI8UV6MqX+x+bRDmuo2wCId2Dkyy2VG7EQLy\nXN0cvfNVlg/UBsD84iOKJHDTu/B5GqdhcIOKrwbFINihY9Bsrk8y1658GEV1BSl3\n30JAZGSGvip2CTFvHST0mdCF/vIhCPnG9vHQWe3WVjwIKANnuvD58ZAWR65n5ryA\nSOlCdjSXVWkkDoPWoC209fN5ikkodBpBocLTJIg1MGCUF7ThBCIxPTsvFwayuJ2G\nK1pp74P1S8SqtCr4fKGxhZSM9AyHDPSsQPhZSZg=\n-----END CERTIFICATE-----"
      tls_hostname   = "soc-logging.service.secretcdn.net"
      use_tls        = true
    }
  }

  dynamic "syslog" {
    for_each = var.has_waf ? [1] : []

    content {
      address        = "104.197.173.239"
      format         = "${replace(file("${path.module}/log_format/soc-waflogs.txt"), "\n", "")}"
      format_version = 2
      message_type   = "blank"
      name           = "soc-waflogs"
      placement      = "waf_debug"
      port           = 9556
      tls_ca_cert    = "-----BEGIN CERTIFICATE-----\nMIIEaTCCA1GgAwIBAgILBAAAAAABRE7wQkcwDQYJKoZIhvcNAQELBQAwVzELMAkG\nA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jv\nb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xNDAyMjAxMDAw\nMDBaFw0yNDAyMjAxMDAwMDBaMGYxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i\nYWxTaWduIG52LXNhMTwwOgYDVQQDEzNHbG9iYWxTaWduIE9yZ2FuaXphdGlvbiBW\nYWxpZGF0aW9uIENBIC0gU0hBMjU2IC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IB\nDwAwggEKAoIBAQDHDmw/I5N/zHClnSDDDlM/fsBOwphJykfVI+8DNIV0yKMCLkZc\nC33JiJ1Pi/D4nGyMVTXbv/Kz6vvjVudKRtkTIso21ZvBqOOWQ5PyDLzm+ebomchj\nSHh/VzZpGhkdWtHUfcKc1H/hgBKueuqI6lfYygoKOhJJomIZeg0k9zfrtHOSewUj\nmxK1zusp36QUArkBpdSmnENkiN74fv7j9R7l/tyjqORmMdlMJekYuYlZCa7pnRxt\nNw9KHjUgKOKv1CGLAcRFrW4rY6uSa2EKTSDtc7p8zv4WtdufgPDWi2zZCHlKT3hl\n2pK8vjX5s8T5J4BO/5ZS5gIg4Qdz6V0rvbLxAgMBAAGjggElMIIBITAOBgNVHQ8B\nAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUlt5h8b0cFilT\nHMDMfTuDAEDmGnwwRwYDVR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYBBQUHAgEWJmh0\ndHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMDMGA1UdHwQsMCow\nKKAmoCSGImh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5uZXQvcm9vdC5jcmwwPQYIKwYB\nBQUHAQEEMTAvMC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWxzaWduLmNv\nbS9yb290cjEwHwYDVR0jBBgwFoAUYHtmGkUNl8qJUC99BM00qP/8/UswDQYJKoZI\nhvcNAQELBQADggEBAEYq7l69rgFgNzERhnF0tkZJyBAW/i9iIxerH4f4gu3K3w4s\n32R1juUYcqeMOovJrKV3UPfvnqTgoI8UV6MqX+x+bRDmuo2wCId2Dkyy2VG7EQLy\nXN0cvfNVlg/UBsD84iOKJHDTu/B5GqdhcIOKrwbFINihY9Bsrk8y1658GEV1BSl3\n30JAZGSGvip2CTFvHST0mdCF/vIhCPnG9vHQWe3WVjwIKANnuvD58ZAWR65n5ryA\nSOlCdjSXVWkkDoPWoC209fN5ikkodBpBocLTJIg1MGCUF7ThBCIxPTsvFwayuJ2G\nK1pp74P1S8SqtCr4fKGxhZSM9AyHDPSsQPhZSZg=\n-----END CERTIFICATE-----"
      tls_hostname   = "soc-logging.service.secretcdn.net"
      use_tls        = true
    }
  }

  ###########################################################
}


output "urls" {
  value = {
    for site in keys(var.sites) :
    site => {
      "admin"   = "https://manage.fastly.com/configure/services/${fastly_service_v1.www[site].id}/versions/${fastly_service_v1.www[site].active_version}"
      "domains" = [for key in flatten([var.sites[site].domains, "${site}-${terraform.workspace}.ffxblue.com.au"]) : "https://${key}"]
    }
  }
}
