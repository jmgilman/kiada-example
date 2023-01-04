local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';

{
  local ingress = k.networking.v1.ingress,
  local ingressTLS = k.networking.v1.ingressTLS,
  local ingressRule = k.networking.v1.ingressRule,
  local ingressHTTPPath = k.networking.v1.httpIngressPath,

  new(service, url):: ingress.new('ingress-tooljet')
                      + ingress.metadata.withAnnotations({
                        'alb.ingress.kubernetes.io/scheme': 'internet-facing',
                        'alb.ingress.kubernetes.io/target-type': 'ip',
                        'alb.ingress.kubernetes.io/listen-ports': '[{"HTTPS":443}]',
                      })
                      + ingress.spec.withIngressClassName('alb')
                      + ingress.spec.withTls(ingressTLS.withHosts(url))
                      + ingress.spec.withRules(
                        ingressRule.withHost(url)
                        + ingressRule.http.withPaths(
                          ingressHTTPPath.withPath('/')
                          + ingressHTTPPath.withPathType('Prefix')
                          + ingressHTTPPath.backend.service.withName(service.metadata.name)
                          + ingressHTTPPath.backend.service.port.withNumber(service.spec.ports[0].port)
                        )
                      ),
}
