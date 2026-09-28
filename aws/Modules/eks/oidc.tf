# Lets Kubernetes service accounts assume IAM roles directly (IRSA),
# instead of every pod inheriting the node's IAM role - the difference
# between "any pod on this node can touch S3" and "only the pods that
# opted in, with only the permissions they asked for."
data "tls_certificate" "cluster_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_oidc.certificates[0].sha1_fingerprint]
}
