module "keda_operator_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~>6.0"

  name = "keda-operator-role"
  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      principals = [{
        type = "Service"
        identifiers = [
          "pods.eks.amazonaws.com",
        ]
      }]

    }
  }

  policies = {
    s3_access = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }
}

resource "kubernetes_namespace_v1" "ns_keda" {
  metadata {
    name = var.keda_namespace
    labels = {
      name = var.keda_namespace
    }
  }
}

# EKS Pod Identity Association for KEDA Operator
resource "aws_eks_pod_identity_association" "keda_operator" {
  count           = var.enable_pod_identity ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = var.keda_namespace
  service_account = "keda-operator"
  role_arn        = module.keda_operator_role.arn

  tags = var.tags
}

# EKS Pod Identity Association for KEDA Metrics Server
resource "aws_eks_pod_identity_association" "keda_metrics_server" {
  count           = var.enable_pod_identity ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = var.keda_namespace
  service_account = "keda-metrics-server"
  role_arn        = module.keda_operator_role.arn

  tags = var.tags
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = var.keda_version
  namespace  = var.keda_namespace

  values = [
    yamlencode({
      serviceAccount = {
        operator = {
          create = true
          name   = "keda-operator"
        }
        metricServer = {
          create = true
          name   = "keda-metrics-apiserver"
        }
        webhooks = {
          create = true
          name   = "keda-admission-webhooks"
        }
      }

      # Resource limits and requests
      resources = {
        operator = {
          limits = {
            cpu    = "1"
            memory = "1000Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "100Mi"
          }
        }
        metricServer = {
          limits = {
            cpu    = "1"
            memory = "1000Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "100Mi"
          }
        }
        webhooks = {
          limits = {
            cpu    = "50m"
            memory = "100Mi"
          }
          requests = {
            cpu    = "10m"
            memory = "10Mi"
          }
        }
      }

      # Security context
      securityContext = {
        operator = {
          capabilities = {
            drop = ["ALL"]
          }
          allowPrivilegeEscalation = false
          readOnlyRootFilesystem   = true
          seccompProfile = {
            type = "RuntimeDefault"
          }
        }
      }

      # Logging configuration
      logging = {
        operator = {
          level  = "info"
          format = "console"
        }
        metricServer = {
          level = 0
        }
      }

      tolerations = [
        {
          key      = "CriticalAddonsOnly"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        }
      ]
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.ns_keda,
  ]
}

# Wait for KEDA to be ready
resource "time_sleep" "wait_for_keda" {
  depends_on      = [helm_release.keda]
  create_duration = "30s"
}
