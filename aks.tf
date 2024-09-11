
#Authenticate to Terraform Kubernetes Module

#Provider for K8, used after built
provider "kubernetes" {
    host                   = azurerm_kubernetes_cluster.vuln_k8_cluster.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.vuln_k8_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.vuln_k8_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.vuln_k8_cluster.kube_config.0.cluster_ca_certificate)
  
}


#Perform Configuration on K8 cluster itself



resource "kubernetes_namespace" "vulnk8" {
  metadata {
    name                   = "vulnk8"
  }
}


resource "kubernetes_deployment" "vuln-k8-deployment" {
  metadata {
    name                   = "vulnk8"
    namespace              = kubernetes_namespace.vulnk8.metadata.0.name
    labels                 = {
      app                  = "vulnk8"
    }
  }

  spec {
    replicas               = 2

    selector {
      match_labels         = {
        app                = "vulnk8"
      }
    }

    template {
      metadata {
        labels             = {
          app              = "vulnk8"
        }
      }

      spec {
        container {
          image            = "yonatanph/logicdemo:latest"
          name             = "user-app"
          port {
            container_port = "80"
          }
          security_context {
            capabilities {
              add          = ["SYS_ADMIN"]
            }
          }
        }
      }
    }
  }

}


resource "kubernetes_service" "vuln-k8-service" {
  metadata {
    name                   = "vulnk8"
    namespace              = kubernetes_namespace.vulnk8.metadata.0.name
  }
  spec {
    selector               = {
      app                  = "vulnk8"
    }
    port {
      port                 = 80
    }

    type                   = "LoadBalancer"
  }
}
