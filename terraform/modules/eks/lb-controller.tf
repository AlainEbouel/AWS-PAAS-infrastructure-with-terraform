resource "aws_iam_policy" "lb-controller" {
  name   = "loadbalancer-controller"
  policy = file("../../modules/eks/files/lb-controller-iam-policy.json")
}

data "aws_iam_policy_document" "lb-controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks-iam-oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks-iam-oidc.url}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks-iam-oidc.url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb-controller" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.lb-controller.json
}

resource "aws_iam_role_policy_attachment" "lb-controller" {
  policy_arn = aws_iam_policy.lb-controller.arn
  role       = aws_iam_role.lb-controller.name
}
resource "kubernetes_service_account_v1" "lb-controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.aws-account}:role/${aws_iam_role.lb-controller.name}"
    }
  }
}

resource "null_resource" "certmanager" {
  provisioner "local-exec" {
    command = "kubectl apply -f ../../modules/eks/files/cert-manager.yml"
  }
}

resource "null_resource" "lb-controller" {
  provisioner "local-exec" {
    command = "kubectl apply -f ../../modules/eks/files/lb-manifests.yml"
  }
}
