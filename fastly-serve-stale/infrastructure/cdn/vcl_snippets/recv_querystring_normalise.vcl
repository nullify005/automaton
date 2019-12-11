
set req.url = querystring.regfilter_except(req.url, "^(action|client_id|code|commentId|company|debug|email|error_code|exchange|ffOverrides|field_passthrough[0-9]|fixed|format|ignorePublicState|isGoogle|match|maxResults|p|page|pcrypt|query|redirect_uri|refId|responseFrom|response_type|scope|signature|state|success|tenantId|term|text|token|year)$");
set req.url = querystring.sort(req.url);


