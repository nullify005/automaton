# If behind another Fastly service, don't keep stale objects in cache
# otherwise we might serve a stale object to a Fastly service which
# will then treat it as a fresh response from origin.  The Fastly-FF
# header lists Fastly POPs that have seen this request prior to the
# current one.
if (req.http.Fastly-FF) {
  set req.max_stale_while_revalidate = 0s;
  set req.max_stale_if_error = 0s;
}

# Should we restart with serve-static-error set then force the URL to be that of the
# branded 50x page hosted within the S3 origin
# In the case that this is a fresh request then prevent the client from going around
# the logic
if (req.restarts == 0) {
  unset req.http.restarts;
  unset req.http.serve-static-error;
} elsif (req.http.serve-static-error) {
  set req.http.restarts = req.restarts; # Use restart value for vary key
  set req.http.Fastly-Force-Shield = "1"; # Re-enable clustering
  set req.url = req.http.serve-static-error-path; # Which is set in the terraform per service (50x/smh/50x.html")
}

# clear this to prevent leakage to the client
unset req.http.serve-static-error-path;
