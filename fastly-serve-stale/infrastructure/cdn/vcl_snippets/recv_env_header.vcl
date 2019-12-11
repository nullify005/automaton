if ( req.http.host ~ "^(www|beta|.*-prod)" ) {

    set req.http.X-env = "production";

} elsif (req.http.host ~ "^.*-staging") {

    set req.http.X-env = "staging";

} elsif (req.http.host ~ "^.*-test") {

    set req.http.X-env = "test";

} elsif (req.http.host ~ "^.*-dev") {

    set req.http.X-env = "development";

} else {
  
    set req.http.X-env = "unknown";
}
