# Syslog to Loki

A Kubernetes deployment solution for collecting syslog messages and forwarding them to Grafana Loki for centralized log management.

## Overview

This project provides a complete pipeline for:
- **Syslog Collection**: RSyslog container that receives UDP/TCP syslog messages on port 514
- **Log Forwarding**: Grafana Agent configured to ship logs to Loki
- **Container Management**: Docker containerization with automated CI/CD
- **Kubernetes Deployment**: Complete K8s manifests with Flux GitOps automation
- **Auto-Updates**: Flux image automation for seamless deployments

## Architecture

The solution consists of:
1. **RSyslog Container** - Receives and stores syslog messages
2. **Grafana Agent** - Forwards logs from RSyslog to Loki
3. **Persistent Storage** - 10GB PVC for log retention
4. **LoadBalancer Service** - External access on port 514 (TCP/UDP)

## Quick Start

### Prerequisites
- Kubernetes cluster with Flux v2 installed
- Grafana Loki instance running in `monitoring` namespace
- Docker registry access (DockerHub)

### Deployment

1. **Deploy via Flux GitOps:**
   ```bash
   kubectl apply -f flux-kustomization.yaml
   ```

2. **Manual deployment:**
   ```bash
   kubectl apply -k .
   ```

### Configuration

- **External IP**: Configure in `service.yaml` (currently set to `192.168.0.141`)
- **Storage**: 10GB persistent volume using `default-retain` storage class
- **Loki Endpoint**: Configured in `configmap.yaml` to push to Loki gateway
- **Log Rotation**: Automatic log rotation at 7.5MB using custom script

## Development

### Building the Docker Image

```bash
# Build locally
make build

# Build and publish
make publish
```

### CI/CD Pipeline

The project uses CircleCI for automated building and publishing:
- Triggers on `main` branch commits
- Builds Docker image using BuildKit
- Publishes to `ninjatec/rsyslog` repository
- Current version: `1.0.13`

### Testing Syslog Reception

Send test logs to verify functionality:
```bash
# TCP test
echo "Test message" | nc <external-ip> 514

# UDP test  
echo "Test message" | nc -u <external-ip> 514
```

## Files Structure

- `Dockerfile` - RSyslog container definition
- `deployment.yaml` - K8s deployment and PVC
- `service.yaml` - LoadBalancer service
- `configmap.yaml` - Grafana Agent configuration
- `kustomization.yaml` - Kustomize resource manifest
- `log_rotation.sh` - Log rotation script
- `Makefile` - Build and publish commands
- `.circleci/config.yml` - CI/CD pipeline

## Monitoring

Logs are automatically forwarded to Grafana Loki at:
```
http://grafana-loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push
```

Use Grafana to query and visualize the collected syslog data.

## Troubleshooting

1. **Check RSyslog container logs:**
   ```bash
   kubectl logs -n monitoring deployment/rsyslog
   ```

2. **Verify service connectivity:**
   ```bash
   kubectl get svc -n monitoring rsyslog
   ```

3. **Check Grafana Agent status:**
   ```bash
   kubectl logs -n monitoring deployment/grafana-agent-logs
   ```

## Contributing

1. Make changes to the codebase
2. Update version in `Makefile`
3. Commit to `main` branch
4. CircleCI will automatically build and deploy
5. Flux will detect new image and update deployment
