terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
      config_context = "minikube"
}

resource "kubernetes_namespace" "terraform" {
  metadata {
    name = "tf-namespace"
  }
}

resource "kubernetes_deployment" "terraform" {
  metadata {
    name = "tf-deployment"
    namespace = kubernetes_namespace.terraform.metadata.0.name
    labels = {
      test = "tfDeployment"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        test = "tfDeployment"
      }
    }
    template {
      metadata {
        labels = {
          test = "tfDeployment"
        }
      }
      spec {
        container {
          image = "joaovictornsv/portfolio"
          name = "tf-container"
        }
      }
    }
  }
}

resource "kubernetes_service" "terraform" {
  metadata {
    name = "tf-service"
    namespace = kubernetes_namespace.terraform.metadata.0.name
  }
  spec {
    selector = {
      test = kubernetes_deployment.terraform.metadata.0.labels.test
    }
    session_affinity = "ClientIP"
    port {
      node_port   = 32765
      port        = 3000
      target_port = 3000
    }

    type = "NodePort"
  }
}