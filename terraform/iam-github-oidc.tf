
# GitHub OIDC Provider
# Allows AWS to trust GitHub Actions workflows

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}


# IAM Role for GitHub Actions
# This role will be assumed by GitHub Actions workflow via OIDC

resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::746669235620:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            # GitHub JWT audience must match
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Must match this repository and branch exactly
            "token.actions.githubusercontent.com:sub" = "repo:DanielleTchonla/Hardening-cicd-pipeline:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}
# allows our GitHub Actions role to update kubeconfig and 
# interact with our EKS cluster without giving full admin access.
resource "aws_iam_policy" "github_actions_eks_policy" {
  name        = "GitHubActionsEKSMinimalPolicy"
  description = "Minimal permissions for GitHub Actions to access EKS cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:ListFargateProfiles"
        ]
        Resource = "arn:aws:eks:us-east-1:746669235620:cluster/cicd-cluster"
      },
      {
        Effect   = "Allow"
        Action   = [
          "sts:AssumeRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_github_actions_eks_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_eks_policy.arn
}


# IAM Role Policy Attachments
# Attach AWS managed policies for ECR, EKS, CloudWatch

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_poweruser" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

