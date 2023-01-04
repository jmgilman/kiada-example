local externalSecrets = import 'external-secrets.libsonnet';
local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local tj = import 'tooljet.libsonnet';

{
  tooljet: tj.new('dev', 'tooljet.jmgilman.dev'),
}
