
resource "kubernetes_namespace_v1" "jenkins" {
  metadata {

    labels = {
      app = var.module-name
    }
    name = var.module-name
  }

}

resource "kubernetes_storage_class_v1" "jenkins" {
  metadata {
    name = "ebs"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
}

data "aws_instances" "node-group-instances" {
  instance_tags = {
    "eks:nodegroup-name" = var.eks-node-group-name
  }
  instance_state_names = ["running"]
}

# resource "kubernetes_namespace_v1" "name" {
#   metadata {
#     name = "test"
#   }
#   provisioner "local-exec" {
#     command = "echo ${jsonencode(data.aws_instances.node-group-instances)} > debug.txt"
#   }
# }

data "aws_instance" "node-group-instance" {
  for_each = toset(data.aws_instances.node-group-instances.ids)
  instance_id = each.value
}
resource "kubernetes_persistent_volume_v1" "jenkins" {
  metadata {
    name = var.module-name
    labels = {
      app  = var.module-name
      type = "local"
    }
  }
  spec {
    storage_class_name = kubernetes_storage_class_v1.jenkins.metadata.0.name
    claim_ref {
      name      = var.module-name
      namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    }
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key = "kubernetes.io/hostname"
            operator = "In"
            values = [for k, v in data.aws_instance.node-group-instance : v.private_dns]
          }
        }
      }
    }

    persistent_volume_source {
      local {
        path = "/mnt"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "jenkins" {
  metadata {
    name      = var.module-name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
  }
  spec {
    storage_class_name = kubernetes_storage_class_v1.jenkins.metadata.0.name
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.jenkins.metadata.0.name
  }
}

resource "kubernetes_deployment_v1" "jenskins" {
  metadata {
    name = var.module-name
    labels = {
      app = var.module-name
    }
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.module-name
      }
    }

    template {
      metadata {
        labels = {
          app = var.module-name
        }
      }

      spec {
        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }
        container {
          image = "jenkins/jenkins:lts"
          name  = var.module-name

          resources {
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "500Mi"
            }
          }
          port {
            container_port = 8080
            name           = "httpport"
          }
          port {
            container_port = 50000
            name           = "jnlpport"
          }

          liveness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          volume_mount {
            name       = "${var.module-name}-data"
            mount_path = "/var/jenkins_home"
          }
        }
        service_account_name = kubernetes_service_account_v1.jenkins.metadata.0.name
        volume {
          name = "${var.module-name}-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.jenkins.metadata.0.name
          }
        }

      }
    }
  }

}

resource "kubernetes_service_v1" "jenkins" {
  metadata {
    name      = var.module-name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/path"   = "/"
      "prometheus.io/port"   = "80"
    }
  }
  spec {
    selector = {
      app = var.module-name
    }
    port {
      port        = 80
      target_port = 8080
      protocol = "TCP"
    }
    type = "NodePort"
  }

}

resource "kubernetes_ingress_v1" "jenkins" {
  metadata {
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    name = var.module-name
    annotations = {
      "kubernetes.io/ingress.class": "alb"
      "alb.ingress.kubernetes.io/scheme": "internet-facing"
    }
  }
  spec {
    default_backend {
      service {
        name = kubernetes_service_v1.jenkins.metadata.0.name
        port {
          number = 80
        }
      }
    }
    # ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.jenkins.metadata.0.name
              port {
                number = 80
              }
            }
          }
          path = "/"
          # path_type = "Prefix"
        }
      }
    }

    # tls {
    #   secret_name = "tls-secret"
    # }
  }
}

# resource "kubernetes_namespace_v1" "test" {
#   metadata {
#     name = "game"
#   }
# }

# resource "kubernetes_deployment_v1" "name" {
#   metadata {
#     name = "game"
#     namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
#   }
#   spec {
#     selector {
#       match_labels = {
#         "app.kubernetes.io/name" = "app-2048"
#       }
#     }
#     replicas = 2
#     template {
#       metadata {
#         labels = {
#           "app.kubernetes.io/name" = "app-2048"
#         }
#       }
#       spec {
#         container {
#           image = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
#           image_pull_policy = "Always"
#           name = "app-2048"
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service_v1" "name" {
#   metadata {
#     name = "game"
#     namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
#   }
#   spec {
#     port {
#       port = 80
#       target_port = 80
#       protocol = "TCP"
#     }
#     type = "NodePort"
#     selector = {
#       "app.kubernetes.io/name": "app-2048"
#     }
#   }
# }

# resource "kubernetes_ingress_v1" "name" {
#   metadata {
#     name = "game"
#     namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
#     annotations = {
#       "alb.ingress.kubernetes.io/scheme" = "internet-facing"
#       # "alb.ingress.kubernetes.io/target-type" = "ip"
#       "kubernetes.io/ingress.class": "alb"
#     }
#   }
#   spec {
#   #  ingress_class_name = "alb"
#    rule {
#      http {
#         path {
#           path = "/"
#           # path_type = "Prefix"
#           backend {
#             service {
#               name = kubernetes_service_v1.name.metadata.0.name
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#      }
#    } 
#   }
# }