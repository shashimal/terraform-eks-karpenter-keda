# EKS Cost Optimization with KEDA and Karpenter

### Architecture

![Architecture Diagram](architecture.png)


### The Strategy

#### KEDA

 We use KEDA’s Cron scaler to define explicit working hours for our development and staging workloads.

##### Monday–Friday, 8:00 8:00 PM

Pods scale up to their required baseline to support active development and testing.

##### Off-hours and weekends 
Pods scale down to zero, effectively putting the environment to sleep when it’s not in use.

#### Karpenter 

Once KEDA scales the pods down, Karpenter takes over at the infrastructure layer. It detects underutilized capacity and automatically terminates the associated EC2 instances. Because Karpenter provisions nodes directly. It can scale node capacity down to zero significantly faster and more reliably than the traditional Cluster Autoscaler.


### K8S Manifests

KEDA ScaledObject 
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: nginx-cron-scaler
  namespace: app
spec:
  scaleTargetRef:
    name: nginx-app
  minReplicaCount: 1
  maxReplicaCount: 10
  idleReplicaCount: 0
  cooldownPeriod: 30
  triggers:
    - type: cron
      metadata:
        timezone: Asia/Singapore
        start: "0 8 * * 1-5"   # 8:00 AM, Monday to Friday
        end: "0 20 * * 1-5"    # 8:00 PM, Monday to Friday
        desiredReplicas: "5"

```

Application Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```