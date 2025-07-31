// myapp-deploy.jsonnet
// Import individual resource files
local middleware = import 'resources/middleware.jsonnet';
local deployment = import 'resources/deployment.jsonnet';
local service = import 'resources/service.jsonnet';
local ingressHttp = import 'resources/ingress-http.jsonnet';
local ingressHttps = import 'resources/ingress-https.jsonnet';

// Configuration variables with defaults
local appName = std.extVar('appName');
local image = std.extVar('image');
local port = std.parseInt(std.extVar('port'));
local baseDomain = std.extVar('baseDomain');
local env = std.extVar('env');
local replicas = std.parseInt(std.extVar('replicas'));

// Calculate common variables once (DRY principle)
local resName = appName + '-' + env;
local domain = env + '.' + baseDomain;
local middlewareName = 'default-redirectscheme';

// Call the individual resource functions with their required parameters
local config = {
  middleware: middleware(middlewareName),
  deployment: deployment(appName, image, port, env, replicas, resName),
  service: service(appName, port, env, resName),
  ingressHttp: ingressHttp(resName, domain, middlewareName),
  ingress: ingressHttps(resName, domain),
};

// Output all resources
{
  'my-webapp-deployment.yaml': std.manifestYamlDoc(config.deployment, quote_keys=false),
  'my-webapp-service.yaml': std.manifestYamlDoc(config.service, quote_keys=false),
  'my-webapp-ingress-http.yaml': std.manifestYamlDoc(config.ingressHttp, quote_keys=false),
  'my-webapp-ingress.yaml': std.manifestYamlDoc(config.ingress, quote_keys=false),
  'my-webapp-middleware.yaml': std.manifestYamlDoc(config.middleware, quote_keys=false),
}