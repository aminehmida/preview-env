// middleware.jsonnet
function(middlewareName)

{
  // Middleware for HTTP to HTTPS redirect
  apiVersion: 'traefik.io/v1alpha1',
  kind: 'Middleware',
  metadata: {
    name: middlewareName,
    namespace: 'default',
  },
  spec: {
    redirectScheme: {
      scheme: 'https',
      permanent: true,
    },
  },
}
