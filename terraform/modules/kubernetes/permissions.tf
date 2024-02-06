resource "kubernetes_service_account_v1" "eks" {
  metadata {
    name      = var.service-name
    namespace = kubernetes_namespace_v1.eks.metadata.0.name
    labels = {
      app = var.service-name
    }
  }
}

resource "kubernetes_role_v1" "eks" {
  metadata {
    name      = var.service-name
    namespace = kubernetes_namespace_v1.eks.metadata.0.name
    labels = {
      app = var.service-name
    }
  }
  rule {
    api_groups = ["", "apps", "batch"]
    resources  = ["pods", "configmaps", "secrets", "deployments", "jobs", "cronjobs", "pods/log"]
    verbs      = ["get", "create", "update", "patch", "delete", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "eks" {
  metadata {
    name      = var.service-name
    namespace = kubernetes_namespace_v1.eks.metadata.0.name
    labels = {
      app = var.service-name
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.eks.metadata.0.name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account_v1.eks.metadata.0.name
    namespace = kubernetes_namespace_v1.eks.metadata.0.name
  }
}

resource "kubernetes_config_map_v1" "pactbroker_configmap" {
  metadata {
    name      = "pactbroker-configmap"
    namespace = kubernetes_namespace_v1.eks.metadata.0.name
  }

  data = {
    PACT_BROKER_DATABASE_HOST       = "10.0.1.144"
    PACT_BROKER_DATABASE_NAME       = "packbroker"
    PACT_BROKER_DATABASE_USERNAME   = "eks-node"
    PACT_BROKER_DATABASE_PORT       = "5432"
    PACT_BROKER_BASIC_AUTH_USERNAME = "eks-node"
    PACT_BROKER_PUBLIC_HEARTBEAT    = "true"
  }
}

resource "kubernetes_secret_v1" "pactbroker_db_login_secret" {
  metadata {
    name      = "pactbroker-db-secret"
    namespace = kubernetes_namespace_v1.eks.metadata.0.name
  }

  data = {
    PACT_BROKER_DATABASE_PASSWORD   = "adminpass"
    PACT_BROKER_BASIC_AUTH_PASSWORD = "adminpass"
  }
}

data "aws_ssm_parameter" "ecr-login" {
  name = "ecr-login"
}

resource "kubernetes_secret_v1" "packbroker-image" {
  metadata {
    name = "pactbroker-image-secret"
    namespace = kubernetes_namespace_v1.eks.metadata.0.name
  }
  type = "kubernetes.io/dockerconfigjson"
  data =  {".dockerconfigjson" = jsonencode(data.aws_ssm_parameter.ecr-login)}   
}
