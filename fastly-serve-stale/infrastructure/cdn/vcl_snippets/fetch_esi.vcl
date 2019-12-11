# Flag the request as requiring ESI processing if it is a webpage
if (beresp.http.Content-Type ~ "^text/html" && beresp.http.X-ESI-Enable == "1") {
  esi;
}

