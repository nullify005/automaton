if (req.method !~ "^(HEAD|GET|OPTIONS|POST|FASTLYPURGE)$" ) {
  error 405 "Method not allowed: " + req.method;
}

