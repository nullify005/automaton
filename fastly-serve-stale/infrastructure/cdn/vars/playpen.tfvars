serve_stale      = true
health_interval  = 15000
health_threshold = 3
health_window    = 5
has_waf          = false

sites = {
  "playpen" = {
    origin            = "fastly-serve-stale-test-v1.playpen.ffxblue.io",
    static_error_path = "/50x/bt/50x.html",
    domains           = ["fastly-serve-stale-test-v1.cdn.9pub.io"]
  },
}
