local externalSecrets = import 'github.com/jsonnet-libs/external-secrets-libsonnet/0.5/main.libsonnet';

{
  local es = externalSecrets.nogroup.v1beta1.externalSecret,
  externalSecret: {
    new(name):: es.new(name),
    withRefresh(interval):: es.spec.withRefreshInterval(interval),
    withTarget(name):: es.spec.target.withName(name),
    withStoreRef(name):: es.spec.secretStoreRef.withName(name) +
                         es.spec.secretStoreRef.withKind('SecretStore'),
    withClusterStoreRef(name): es.spec.secretStoreRef.withName(name) +
                               es.spec.secretStoreRef.withKind('ClusterSecretStore'),
    withExtract(name): es.spec.withDataFrom(es.spec.dataFrom.extract.withKey(name)),
  },
}
