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

data "aws_ebs_volume" "ebs" {
  filter {
    name   = "tag:name"
    values = ["node-group-ebs"]
  }
}

resource "kubernetes_persistent_volume_v1" "jenkins" {
  metadata {
    name = var.module-name
    labels = {
      app = var.module-name
      type = "local"
    }
  }
  spec {
    storage_class_name = kubernetes_storage_class_v1.jenkins.metadata.0.name
    claim_ref {
      name = var.module-name
      namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    }    
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    # node_affinity {
    #   required {
    #     node_selector_term {
    #       match_expressions {
    #         key = "kubernetes.io/hostname"
    #         operator = "In"
    #         values = ["ip-10-0-0-29.ca-central-1.compute.internal"]
    #       }
    #     }
    #   }
    # }
    
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = data.aws_ebs_volume.ebs.volume_id
        fs_type = "ext4"
      }
      # local {
      #   path = "/mnt"
      # }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "jenkins" {
  metadata {
    name = var.module-name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
  }
  spec {
    storage_class_name = kubernetes_storage_class_v1.jenkins.metadata.0.name
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
    volume_name = kubernetes_persistent_volume_v1.jenkins.metadata.0.name
  }
}

data "aws_eks_cluster" "eks-cluster" {
  name = var.eks_cluster_name
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
          fs_group = 1000
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
            name = "httpport"
          }
          port {
            container_port = 50000
            name = "jnlpport"
          }

          liveness_probe {
            http_get {
              path = "/login"
              port = 8080    
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds = 5
            failure_threshold = 3
          }

          volume_mount {
            name = "${var.module-name}-data"
            mount_path = "/var/jenkins_home"
          }
        }
        volume {
          name = "${var.module-name}-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.jenkins.metadata.0.name
          }
        }
        
      }      
    }
  }
    provisioner "local-exec" {
    command = "echo ${jsonencode(data.aws_eks_cluster.eks-cluster.tags)} > debug2.txt "
  }
}

resource "kubernetes_service_v1" "jenkins" {
  metadata {
    name = var.module-name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/path" = "/"
      "prometheus.io/port" = "80"
    }
  }
  spec {
    selector = {
      app = var.module-name
    }
    port {
      port = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
  
}