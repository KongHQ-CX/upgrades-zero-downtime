resource "kubernetes_manifest" "ingress_alb" {
  manifest = yamldecode(templatefile("ingress-template.yaml",
  {
    name = var.kong_gateway_name
  }))
}
