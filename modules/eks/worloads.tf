# provider "kubernetes" {
#   host                   = aws_eks_cluster.dev-cluster.endpoint
#   cluster_ca_certificate = base64decode(aws_eks_cluster.dev-cluster.certificate_authority[0].data)
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args        = ["eks", "get-token", "--cluster-name", "dev-cluster"]
#     command     = "aws"
#   }
# }
# # resource "kubernetes_secret_v1" "example" {
# #   metadata {
# #     name = "basic-auth"
# #   }

# #   data = {
# #     username = "admin"
# #     password = "P4ssw0rd"
# #   }

# #   type = "kubernetes.io/basic-auth"
# # }

# # provider "kubernetes" {
# #   host                   = "https://${aws_eks_cluster.dev-cluster.endpoint}"
# #   client_certificate     = base64decode("${aws_eks_cluster.dev-cluster.kube_config.0.client_certificate}")
# #   client_key             = base64decode("${aws_eks_cluster.dev-cluster.kube_config.0.client_key}")
# #   cluster_ca_certificate = base64decode("${aws_eks_cluster.dev-cluster.kube_config.0.cluster_ca_certificate}")
# # }

# # provider "kubernetes" {
# #   config_path = "~/.kube/config"
# # }

# resource "kubernetes_pod" "test" {
#   metadata {
#     name = "terraform-example"
#   }

#   spec {
#     container {
#       image = "nginx:1.21.6"
#       name  = "example"

#       env {
#         name  = "environment"
#         value = "test"
#       }

#       port {
#         container_port = 80
#       }
#     }
#   }
# }