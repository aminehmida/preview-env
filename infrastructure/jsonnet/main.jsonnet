// myapp-deploy.jsonnet
local webapp = import 'webapp.jsonnet';

// Configuration variables with defaults
local appName = std.extVar('appName');
local image = std.extVar('image');
local port = std.parseInt(std.extVar('port'));
local domain = std.extVar('domain');

// Call the function with your parameters
local config = webapp(
  appName=appName,       // Application name (used for all resource names)
  image=image,           // Container image with tag
  port=port,             // Container port
  domain=domain          // Your domain
);

// Output all resources
{
  'my-webapp-deployment.yaml': std.manifestYamlDoc(config.deployment, quote_keys=false),
  'my-webapp-service.yaml': std.manifestYamlDoc(config.service, quote_keys=false),
  'my-webapp-ingress-http.yaml': std.manifestYamlDoc(config.ingressHttp, quote_keys=false),
  'my-webapp-ingress.yaml': std.manifestYamlDoc(config.ingress, quote_keys=false),
  'my-webapp-middleware.yaml': std.manifestYamlDoc(config.middleware, quote_keys=false),
}