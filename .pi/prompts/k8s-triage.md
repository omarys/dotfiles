Troubleshoot Kubernetes pod errors.

Namespace: {{namespace}}

Rules:

- Read-only only.
- Do not mutate the cluster.
- Do not print secret values.
- Do not run kubectl apply, patch, delete, rollout restart, scale, cordon, drain, or debug.
- Prefer evidence over guesses.

Workflow:

1. Use scout to inspect live cluster state:
   - kubectl get pods -n {{namespace}} -o wide
   - kubectl get events -n {{namespace}} --sort-by=.lastTimestamp
   - describe unhealthy pods
   - logs and previous logs for restarting containers
   - related deployments, statefulsets, jobs, cronjobs
   - probes, resources, image refs, env/configmap/secret references, service accounts, PVCs, node placement

2. Use oracle to challenge the diagnosis.

3. Use planner to produce a remediation plan with:
   - root cause hypotheses
   - confidence
   - evidence
   - validation commands
   - rollback commands
   - manifest changes if needed

Stop before implementation.
