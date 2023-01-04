local externalSecrets = import 'external-secrets.libsonnet';
local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

local deploy = import 'tooljet/deployment.libsonnet';
local ingress = import 'tooljet/ingress.libsonnet';

{
  local externalSecret = externalSecrets.externalSecret,
  local service = k.core.v1.service,

  new(env, url):: {
    local port = 3000,

    deployment: deploy.new(url, port),
    service: k.util.serviceFor(self.deployment)
             + service.spec.withType('NodePort'),
    secret: externalSecret.new('tooljet-creds')
            + externalSecret.withRefresh('1h')
            + externalSecret.withTarget('tooljet-creds')
            + externalSecret.withClusterStoreRef('cluster-secret-store')
            + externalSecret.withExtract(std.format('%s/db/tooljet', env)),
    ingress: ingress.new(self.service, url),
  },
}
