if (beresp.status >= 500 && beresp.status < 600) {
  if (stale.exists) {
    return(deliver_stale);
  }
  if (req.restarts < 1 && (req.request == "GET" || req.request == "HEAD")) {
    restart;
  }
}
set beresp.stale_if_error = 43200s;
