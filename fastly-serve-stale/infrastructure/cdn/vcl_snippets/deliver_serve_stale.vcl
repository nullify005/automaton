# If a network error was encountered in the fetch, and there was no
# stale version of the content available on the cluster server, we
# would move to ERROR and generate a synthetic 503 Service unavailable
# response. However, DELIVER runs on the Edge server, and there's a
# small chance that the edge server has a stale version of the object.
# If it does, restarting the process here will disable clustering and
# allow us to use the stale version in the edge server's cache.
if (resp.status >= 500 && resp.status < 600 && stale.exists) {
   restart;
}
