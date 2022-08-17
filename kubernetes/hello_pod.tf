variable "app_source" {
  default = ""
  description = "String that defines where the image for the app container should be pulled from"
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "crispy-test"
  }
}

resource "kubernetes_deployment" "test" {
  metadata {
    namespace = "crispy-test"
    name = "crispy-clone"
    labels = {
      app = "HelloWorld"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "HelloWorld"
      }
    }

    template {
      metadata {
        labels = {
          app = "HelloWorld"
        }
      }

      spec {
        container {
          image = "docker.io/library/postgres:latest"
          name  = "database"
        
          env {
            name  = "POSTGRES_DB"
            value = "crispydb"
          }

          env {
            name  = "POSTGRES_USER"
            value = "crispycritter"
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "extracrispy"
          }
        }

        container {
          image = var.app_source
          name  = "app"

          env {
            name  = "CLOUD_SQL_DATABASE_NAME"
            value = "crispydb"
          }

          env {
            name  = "CLOUD_SQL_USERNAME"
            value = "crispycritter"
          }

          env {
            name  = "CLOUD_SQL_PASSWORD"
            value = "extracrispy"
          }

          port {
            container_port = 8080
            host_port      = 8080
          }
        }


      }
    }
  }
}

resource "kubernetes_service" "test" {
  metadata {
    name      = "test-lb-service"
    namespace = kubernetes_namespace.test.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.test.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 8080
      target_port = 8080
    }
  }
}