// ingress-https.jsonnet
function(resName, domain)

{
  // HTTPS Ingress (for serving actual content)
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: resName + '-https',
    annotations: {
      'traefik.ingress.kubernetes.io/router.entrypoints': 'websecure',
      'traefik.ingress.kubernetes.io/router.tls.certresolver': 'default',
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
    tls: [
      {
        hosts: [domain]
      },
    ],
  },
}
