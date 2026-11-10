# fitapp-gitops

**Desired state of everything running inside the Kubernetes cluster.**
Argo CD watches this repo and applies every change automatically. Nobody runs `kubectl apply` by hand.

```
bootstrap/                 read by the "root" Argo CD app (created by fitapp-infra/ansible)
  platform.yaml            -> Application "platform" (namespaces, quotas, network policies)
  microservices.yaml       -> ApplicationSet: one Application per envs/<env>/<service>/
platform/                  namespaces dev/test/prod (Pod Security "restricted"), quotas, NetworkPolicies
charts/microservice/       ONE generic Helm chart for every microservice (Deployment, Service, Ingress)
envs/
  cluster.yaml             cluster-wide values (domain)
  dev/<service>/values.yaml
  test/<service>/values.yaml
  prod/<service>/values.yaml
```

## How a deployment works
1. CI builds image `auth-service:<git-sha>` and pushes it to the registry.
2. CI changes **one line** here: `envs/dev/auth-service/values.yaml` → `image.tag: <git-sha>`.
3. Argo CD sees the commit and updates the `dev` namespace (rolling update, zero downtime).
4. Promotion to test / prod = copying the same tag into `envs/test/...` / `envs/prod/...`.
5. Rollback = `git revert`.

## Add a new microservice
Create `envs/dev/<name>/values.yaml` (and test/prod). The ApplicationSet creates the Argo CD apps by itself.

## URLs (nip.io wildcard DNS, master public IP)
| env | URL |
|---|---|
| dev | http://demo-service-dev.&lt;IP&gt;.nip.io |
| test | http://demo-service-test.&lt;IP&gt;.nip.io |
| prod | http://demo-service.&lt;IP&gt;.nip.io |

## Security baseline
- Pod Security Standard **restricted** on every environment namespace
- Containers: non-root, read-only root filesystem, no privilege escalation, all capabilities dropped, seccomp
- NetworkPolicies: default deny; only same-environment pods and the ingress controller can reach a pod
- ResourceQuota + LimitRange per environment (dev/test cannot starve prod)
