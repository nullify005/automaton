# We end up in ERROR if we call it explicitly from FETCH, and also
# if there are any network connection problems when sending the
# request to origin.  In the event of network issues, Fastly will
# generate a 500-series error internally and pass it to ERROR.
if (obj.status >= 500 && obj.status < 600) {

  # We already check in FETCH for a stale object, but if we ended
  # up here because of a network problem, we will not have run the
  # FETCH code, so it's worth checking again if there's a stale copy
  # available.
  if (stale.exists) {
    return(deliver_stale);
  }

  # Since we cannot serve stale we need to deliver the 50x static content from the
  # static error origin. Set the var which will trigger this and return to the recv
  # Should the var already exist then we have no recourse but to fall through to
  # a synthetic response because the static error origin is broken too
  if (!req.http.serve-static-error) {
    set req.http.serve-static-error = "1";
    restart;
  }

  # At this point our only option is to construct an error response
  # that we can send to the browser
  set obj.http.Content-Type = "text/html";
  synthetic {"
    <!DOCTYPE html>
    <html>
      <body>
        Sorry, we are currently experiencing problems fulfilling
        your request.  We've logged this problem and we'll try to
        resolve it as quickly as possible.
      </body>
    </html>
  "};

  return(deliver);
}
