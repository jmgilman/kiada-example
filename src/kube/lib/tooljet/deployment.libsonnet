local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local deploy = k.apps.v1.deployment,
  local container = k.core.v1.container,
  local kport = k.core.v1.containerPort,
  local env = k.core.v1.envVar,
  local secretRef = k.core.v1.envVarSource.secretKeyRef,

  new(url, port):: deploy.new(name='tooljet', replicas=2, containers=[
                     container.new('tooljet', 'tooljet/tooljet-ce')
                     + container.withPorts(kport.newNamed(port, 'ui'))
                     + container.withArgs(['npm', 'run', 'start:prod'])
                     + container.withEnv([
                       env.fromSecretRef('PG_HOST', 'tooljet-creds', 'host'),
                       env.fromSecretRef('PG_USER', 'tooljet-creds', 'username'),
                       env.fromSecretRef('PG_PASS', 'tooljet-creds', 'password'),
                       env.new('PG_DB', 'tooljet'),
                       env.new('PG_DB_OWNER', 'false'),
                       env.fromSecretRef('LOCKBOX_MASTER_KEY', 'tooljet-server', 'lockbox_key'),
                       env.fromSecretRef('SECRET_KEY_BASE', 'tooljet-server', 'secret_key_base'),
                       env.new('TOOLJET_HOST', std.format('https://%s', url)),
                       env.new('DEPLOYMENT_PLATFORM', 'k8s'),
                     ])
                     + container.readinessProbe.withSuccessThreshold(1)
                     + container.readinessProbe.withInitialDelaySeconds(10)
                     + container.readinessProbe.withPeriodSeconds(5)
                     + container.readinessProbe.withFailureThreshold(6)
                     + container.readinessProbe.httpGet.withPort(port)
                     + container.readinessProbe.httpGet.withPath('/api/health'),
                   ])
                   + deploy.spec.strategy.withType('RollingUpdate')
                   + deploy.spec.strategy.rollingUpdate.withMaxUnavailable(1)
                   + deploy.spec.strategy.rollingUpdate.withMaxSurge(1),
}
