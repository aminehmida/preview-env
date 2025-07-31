// deployment.jsonnet
function(appName, image, port, env, replicas=1, resName)

{
  // Deployment
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: resName,
    labels: { app: appName, env: env },
  },
  spec: {
    replicas: replicas,
    selector: {
      matchLabels: { app: appName, env: env },
    },
    template: {
      metadata: {
        labels: { app: appName, env: env },
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
}
