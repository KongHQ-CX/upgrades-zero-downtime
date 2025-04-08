resource "helm_release" "kong" {
  name            = var.kong_gateway_name
  chart           = "kong"
  repository      = "https://charts.konghq.com"
  version         = "2.48.0"
  namespace       = "kong-failover"
  force_update    = true
  cleanup_on_fail = true

  values = [templatefile("values-template.yaml", {
    kong_version = "3.8"
  })]
}
