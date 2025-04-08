resource "kubernetes_manifest" "gateway_configuration" {
  manifest = yamldecode(templatefile("gateway-configuration-template.yaml",
  {
    name = var.kong_gateway_name
    version = "3.8"
  }))
}

resource "kubernetes_manifest" "gateway_class" {
  depends_on = [ kubernetes_manifest.gateway_configuration ]
  manifest = yamldecode(templatefile("gateway-class-template.yaml",
  {
    name = var.kong_gateway_name
  }))
}

resource "kubernetes_manifest" "gateway" {
  depends_on = [ kubernetes_manifest.gateway_configuration, kubernetes_manifest.gateway_class ]
  manifest = yamldecode(templatefile("gateway-template.yaml",
  {
    name = var.kong_gateway_name
  }))
}
