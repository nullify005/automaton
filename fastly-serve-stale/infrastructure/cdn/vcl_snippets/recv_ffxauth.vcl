# Allow access to preproduction by IP ACL or "ffx-auth" cookie value.

if (!req.http.Fastly-FF && client.requests == 1) {
  unset req.http.ffxauth;
}

if (req.http.Cookie:ffx-auth) {
  if (table.lookup(ffxauth, req.http.Cookie:ffx-auth, "no") != "no" ) {
    set req.http.ffxauth = "cookie";
  }
}  

if (req.http.Fastly-Client-IP ~ trustedhost) {
  set req.http.ffxauth = "trustedip";
}
