resource "kubernetes_service" "nodeport" {
  metadata {
    name = "${var.kong_gateway_name}-alb-port"
    namespace = "kong-failover"
  }

  spec {
    selector = {
      "app.kubernetes.io/component" = "app"
      "app.kubernetes.io/instance" = var.kong_gateway_name
      "app.kubernetes.io/name" = "kong"
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 8000
    }

    type = "NodePort"
  }
}
