// webapp.jsonnet
function(appName, image, port, domain)
local serviceName = appName + '-service';
local ingressName = appName + '-ingress';
local middlewareName = 'default-redirectscheme';

{
  // Middleware for HTTP to HTTPS redirect
  middleware: {
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
  },

  // Deployment
  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: appName,
      labels: {
        app: appName,
      },
    },
    spec: {
      replicas: 2,
      selector: {
        matchLabels: {
          app: appName,
        },
      },
      template: {
        metadata: {
          labels: {
            app: appName,
          },
        },
        spec: {
          containers: [
            {
              name: appName,
              image: image,
              ports: [
                {
                  containerPort: port,
                },
              ],
              resources: {
                requests: {
                  memory: '64Mi',
                  cpu: '50m',
                },
                limits: {
                  memory: '128Mi',
                  cpu: '100m',
                },
              },
            },
          ],
        },
      },
    },
  },

  // Service
  service: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: serviceName,
      labels: {
        app: appName,
      },
    },
    spec: {
      selector: {
        app: appName,
      },
      ports: [
        {
          port: 80,
          targetPort: port,
          protocol: 'TCP',
        },
      ],
      type: 'ClusterIP',
    },
  },

  // HTTP Ingress (for redirecting to HTTPS)
  ingressHttp: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: ingressName + '-http',
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
                    name: serviceName,
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
  },

  // HTTPS Ingress (for serving actual content)
  ingress: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: ingressName,
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
                    name: serviceName,
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
  },
}