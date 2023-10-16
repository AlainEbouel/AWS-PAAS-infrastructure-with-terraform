resource "kubernetes_service_account_v1" "jenkins" {
  metadata {
    name      = var.module-name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    labels = {
      app = var.module-name
    }
  }
}

resource "kubernetes_role_v1" "jenkins" {
  metadata {
    name      = var.module-name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    labels = {
      app = var.module-name
    }
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }
}

resource "kubernetes_role_binding_v1" "jenkins" {
  metadata {
    name      = var.module-name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
    labels = {
      app = var.module-name
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.jenkins.metadata.0.name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account_v1.jenkins.metadata.0.name
    namespace = kubernetes_namespace_v1.jenkins.metadata.0.name
  }
}
