// service.jsonnet
function(appName, port, env, resName)

{
  // Service
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: resName,
    labels: {
      app: appName,
      env: env,
    },
  },
  spec: {
    selector: {
      app: appName,
      env: env,
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
}
