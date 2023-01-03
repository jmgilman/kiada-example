local externalSecrets = import 'external-secrets.libsonnet';
local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local deploy = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local port = k.core.v1.containerPort,
  local env = k.core.v1.envVar,
  local secretRef = k.core.v1.envVarSource.secretKeyRef,

  local service = k.core.v1.service,

  local externalSecret = externalSecrets.externalSecret,

  local ingress = k.networking.v1.ingress,
  local ingressTLS = k.networking.v1.ingressTLS,
  local ingressRule = k.networking.v1.ingressRule,
  local ingressHTTPPath = k.networking.v1.httpIngressPath,

  _config:: {
    tooljet: {
      port: 3000,
      name: 'tooljet',
      url: 'tooljet.jmgilman.dev',
    },
  },
  tooljet: {
    deployment: deploy.new(name=$._config.tooljet.name, replicas=2, containers=[
                  container.new($._config.tooljet.name, 'tooljet/tooljet-ce')
                  + container.withPorts(port.newNamed($._config.tooljet.port, 'ui'))
                  + container.withArgs(['npm', 'run', 'start:prod'])
                  + container.withEnv([
                    env.fromSecretRef('PG_HOST', 'tooljet-creds', 'host'),
                    env.fromSecretRef('PG_USER', 'tooljet-creds', 'username'),
                    env.fromSecretRef('PG_PASS', 'tooljet-creds', 'password'),
                    env.new('PG_DB', 'tooljet'),
                    env.new('PG_DB_OWNER', 'false'),
                    env.fromSecretRef('LOCKBOX_MASTER_KEY', 'tooljet-server', 'lockbox_key'),
                    env.fromSecretRef('SECRET_KEY_BASE', 'tooljet-server', 'secret_key_base'),
                    env.new('TOOLJET_HOST', std.format('https://%s', $._config.tooljet.url)),
                    env.new('DEPLOYMENT_PLATFORM', 'k8s'),
                  ])
                  + container.readinessProbe.withSuccessThreshold(1)
                  + container.readinessProbe.withInitialDelaySeconds(10)
                  + container.readinessProbe.withPeriodSeconds(5)
                  + container.readinessProbe.withFailureThreshold(6)
                  + container.readinessProbe.httpGet.withPort($._config.tooljet.port)
                  + container.readinessProbe.httpGet.withPath('/api/health'),
                ])
                + deploy.spec.strategy.withType('RollingUpdate')
                + deploy.spec.strategy.rollingUpdate.withMaxUnavailable(1)
                + deploy.spec.strategy.rollingUpdate.withMaxSurge(1),
    service: k.util.serviceFor(self.deployment)
             + service.spec.withType('NodePort'),
    secret: externalSecret.new('tooljet-creds')
            + externalSecret.withRefresh('1h')
            + externalSecret.withTarget('tooljet-creds')
            + externalSecret.withClusterStoreRef('cluster-secret-store')
            + externalSecret.withExtract('dev/db/tooljet'),
    ingress: ingress.new('ingress-tooljet')
             + ingress.metadata.withAnnotations({
               'alb.ingress.kubernetes.io/scheme': 'internet-facing',
               'alb.ingress.kubernetes.io/target-type': 'ip',
               'alb.ingress.kubernetes.io/listen-ports': '[{"HTTPS":443}]',
             })
             + ingress.spec.withIngressClassName('alb')
             + ingress.spec.withTls(ingressTLS.withHosts($._config.tooljet.url))
             + ingress.spec.withRules(
               ingressRule.withHost($._config.tooljet.url)
               + ingressRule.http.withPaths(
                 ingressHTTPPath.withPath('/')
                 + ingressHTTPPath.withPathType('Prefix')
                 + ingressHTTPPath.backend.service.withName($._config.tooljet.name)
                 + ingressHTTPPath.backend.service.port.withNumber($._config.tooljet.port)
               )
             ),
  },
}
