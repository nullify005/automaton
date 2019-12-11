# Disable ESI when used with shield
if (req.http.Fastly-FF) {
  set req.esi = false;
}
if (req.topurl) {
  unset req.http.accept-encoding;
}

# pages with ESI on them shouldnt be served up compressed, because this messes 
# with ESI detection.
if ( req.url.path ~ "^/content/.*\.html" ) {
  unset req.http.accept-encoding;
}
