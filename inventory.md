# Project Inventory

## Repository Structure

```
syslogtoloki/
├── .circleci/
│   └── config.yml                # CircleCI pipeline configuration
├── configmap.yaml                # Grafana Agent configuration
├── deployment.yaml               # RSyslog deployment and PVC
├── Dockerfile                    # RSyslog container image
├── kustomization.yaml            # Kustomize resources
├── log_rotation.sh               # Log rotation script
├── Makefile                      # Build and publish commands
├── README.md                     # Project documentation
├── service.yaml                  # LoadBalancer service
└── inventory.md                  # This file
```

## Container Images

| Image | Version | Registry | Purpose |
|-------|---------|----------|---------|
| `ninjatec/rsyslog` | 1.0.13 | DockerHub | RSyslog daemon container |

## Kubernetes Resources

### Namespace: `monitoring`

| Resource Type | Name | Purpose |
|---------------|------|---------|
| Deployment | `rsyslog` | RSyslog daemon container |
| Service | `rsyslog` | LoadBalancer for syslog ingress |
| PersistentVolumeClaim | `rsyslog-pv-claim` | Log storage (10GB) |
| ConfigMap | `grafana-agent-logs` | Grafana Agent configuration |

### Namespace: `flux-system`

| Resource Type | Name | Purpose |
|---------------|------|---------|
| Kustomization | `rsyslog` | Flux deployment automation |
| ImagePolicy | `rsyslog` | Image version policy |
| ImageUpdateAutomation | `rsyslog` | Auto-update configuration |

## Network Configuration

| Service | Type | Ports | External IP |
|---------|------|-------|-------------|
| rsyslog | LoadBalancer | 514/TCP, 514/UDP | 192.168.0.141 |

## Storage

| PVC Name | Size | Storage Class | Mount Path |
|----------|------|---------------|------------|
| rsyslog-pv-claim | 10Gi | default-retain | /mnt/rsyslog |

## CI/CD Pipeline

### CircleCI Workflow
- **Trigger**: Commits to `main` branch
- **Executor**: `ubuntu-2204:2024.11.1` (medium resource class)
- **Steps**:
  1. Docker login using `DOCKER_USER` and `DOCKER_PASS`
  2. Build image using `make build`
  3. Publish image using `make publish`

### Flux GitOps
- **Source**: Git repository
- **Sync Interval**: 1 minute
- **Image Update**: 5 minutes
- **Decryption**: SOPS with GPG key
- **Auto-commit**: Enabled for image updates

## Configuration Details

### RSyslog Configuration
- **Modules**: `imudp`, `imtcp`
- **Ports**: 514 (TCP/UDP)
- **Log File**: `/mnt/rsyslog/rsyslog.log`
- **Rotation**: 7.5MB threshold
- **Template**: `RemoteStore` for external logs

### Grafana Agent
- **Log Source**: `/var/log/{syslog,messages,*.log}`
- **Loki Endpoint**: `http://grafana-loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push`
- **Job Name**: `varlogs`
- **Position File**: `/tmp/positions.yaml`

### Resource Limits
- **CPU Limit**: 400m
- **Memory Limit**: 1000Mi
- **CPU Request**: 50m
- **Memory Request**: 10Mi

## Dependencies

### External Services
- Grafana Loki (monitoring namespace)
- Kubernetes cluster with Flux v2
- DockerHub registry access

### Build Dependencies
- Docker with BuildKit
- Make
- Git

## Security

### Image Policy
- **Semver Range**: `>=1.0.0`
- **Pattern**: `^(?P<semversion>\d+.\d+.\d+)(-.*)? `
- **Auto-update**: Enabled for patch versions

### SOPS Encryption
- **Provider**: GPG
- **Secret**: `sops-gpg` (flux-system namespace)

## Monitoring & Observability

### Logs
- RSyslog container logs available via `kubectl logs`
- Application logs forwarded to Loki
- Grafana Agent metrics on port 12345

### Health Checks
- Container liveness: RSyslog process
- Service readiness: Port 514 availability
- Storage: PVC mount status

## Version History

| Version | Changes |
|---------|---------|
| 1.0.13 | Current stable version |

## Contact & Support

- **Git Repository**: Main branch for production deployments
- **Docker Registry**: `ninjatec/rsyslog`
- **Flux Automation**: `flux@ninjatec.co.uk`
