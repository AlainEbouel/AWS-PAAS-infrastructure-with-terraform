
data "tls_certificate" "eks-cluster" {
  url = aws_eks_cluster.dev-cluster.identity[0]["oidc"][0]["issuer"]
}

resource "aws_iam_openid_connect_provider" "eks-iam-oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-cluster.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks-cluster.url

}

data "aws_iam_policy_document" "ebs-csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks-iam-oidc.arn]
      
    }
    condition {
      test = "StringEquals"
      variable =  "${aws_iam_openid_connect_provider.eks-iam-oidc.url}:aud"
      values = ["sts.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable =  "${aws_iam_openid_connect_provider.eks-iam-oidc.url}:sub"
      values = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }

}

resource "aws_iam_role" "ebs-csi" {
  name = "KS_EBS_CSI_DriverRole"
  assume_role_policy = data.aws_iam_policy_document.ebs-csi.json
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs-csi.name
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name = aws_eks_cluster.dev-cluster.name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs-csi.arn
}
