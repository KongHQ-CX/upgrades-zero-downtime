resource "kubernetes_service" "nodeport" {
  metadata {
    name = var.kong_app_name
    namespace = "kong-gateways"
  }
  spec {
    selector = {
      app = var.kong_app_name
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 8000
    }

    type = "NodePort"
  }
}
