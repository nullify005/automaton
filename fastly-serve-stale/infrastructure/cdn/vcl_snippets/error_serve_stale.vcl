if (obj.status >= 500 && obj.status < 600) {
  if (stale.exists) {
    return(deliver_stale);
  }
}
