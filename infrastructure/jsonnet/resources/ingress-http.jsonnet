// ingress-http.jsonnet
function(resName, domain, middlewareName)

{
  // HTTP Ingress (for redirecting to HTTPS)
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: resName + '-http',
    annotations: {
      'traefik.ingress.kubernetes.io/router.entrypoints': 'web',
      'traefik.ingress.kubernetes.io/router.middlewares': 'default-' + middlewareName + '@kubernetescrd',
    },
  },
  spec: {
    ingressClassName: 'traefik',
    rules: [
      {
        host: domain,
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: resName,
                  port: {
                    number: 80,
                  },
                },
              },
            },
          ],
        },
      },
    ],
  },
}
