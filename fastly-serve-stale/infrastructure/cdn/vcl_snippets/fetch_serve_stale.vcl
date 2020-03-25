# If origin is unhealthy and a stale object exists in cache, we will
# serve it immediately as a hit, but otherwise, a fetch will be
# attempted.  Network errors during fetches will abort processing
# and move to the ERROR routine, but that leaves us with valid HTTP
# responses which we simply don't like the look of and want to treat
# as invalid.
if (beresp.status >= 500 && beresp.status < 600) {

  # So in the event of a "bad" HTTP response, we can tell the cache
  # to drop this response and use the stale one from the cache instead
  if (stale.exists) {
    return(deliver_stale);
  }

  # On the initial attempt to load a resource, Fastly will delegate
  # the request from an edge server to a cluster server.  If we are
  # at this point on a cluster server, we don't want to construct a
  # synthetic response since it may be cached by the Edge server.
  # Instead, if we restart, clustering will be automatically
  # disabled, and we'll be able to deliver the synthetic from the
  # edge server.
  if (req.restarts < 1 && (req.request == "GET" || req.request == "HEAD")) {
    restart;
  }

  # Triggering an error explicitly here will drop the response
  # received from origin and move processing to ERROR.
  error beresp.status beresp.response;
}

set beresp.stale_while_revalidate = 300s;
set beresp.stale_if_error = 86400s;
