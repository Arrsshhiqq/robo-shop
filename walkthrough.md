# Project 3 Walkthrough: Automated Multi-Tier Deployment

This document serves as a detailed walkthrough of the implementation process for Project 3, detailing the challenges, decisions, and outcomes of migrating Stan's Robot Shop to a Single EC2 + MicroK8s architecture.

## 1. Architectural Shift
The original configuration relied on an AWS Elastic Kubernetes Service (EKS) cluster and a dedicated Jenkins EC2 server. To align with the Project 3 rubric, this was completely refactored.
- **Terraform Refactoring**: The `eks.tf` module was removed. The `ec2.tf` file was expanded to deploy a single, robust `t3.large` instance. The security group was modified to open specific ports: `22` (SSH), `80/443` (HTTP/S), `16443` (MicroK8s API), and `30080` (NodePort for the frontend).
- **Ansible Automation**: The Jenkins setup was discarded in favor of a `setup-microk8s.yml` playbook. This script installs `snapd`, installs MicroK8s, adds the `ubuntu` user to the correct groups, and automatically enables `dns`, `ingress`, and `hostpath-storage`.

## 2. CI/CD Implementation
The pipeline was migrated to **GitHub Actions** (`.github/workflows/deploy.yml`), eliminating the need to maintain a separate Jenkins server. 
- The workflow triggers automatically on pushes to the `master` branch.
- It logs into the GitHub Container Registry (GHCR) securely using the default `GITHUB_TOKEN`.
- It executes `docker compose build` and `docker compose push` to compile the 8 microservices and push them to GHCR.
- **Challenge Overcome:** The Node.js services initially failed to build on Alpine Linux due to missing Python/C++ build tools required by `node-gyp`. This was resolved by modifying the Dockerfiles to dynamically install `python3`, `make`, and `g++` before executing `npm install`.

## 3. Kubernetes Orchestration
The massive `docker-compose.yaml` was translated into Kubernetes native `Deployment` and `Service` descriptors, organized neatly into `K8s/manifests/`.
- **01-databases.yaml**: Provisions MongoDB, MySQL, Redis, and RabbitMQ using standard, stable images.
- **02-microservices.yaml**: Provisions the 8 core services (catalogue, user, cart, shipping, ratings, payment, dispatch, web).
- **Challenge Overcome:** Kubernetes rejected generic image placeholders (`<YOUR_REGISTRY>`). This was resolved by correctly formatting the image paths to point directly to the public GHCR packages (e.g., `ghcr.io/arrsshhiqq/rs-web:latest`). 

## 4. Final Validation
With the GHCR packages set to public, Kubernetes successfully pulled the images and scheduled the pods. The application was successfully routed through the `web` service's NodePort `30080`, allowing external HTTP access via the EC2 instance's public IP.

---
### Required Screenshots Checklist for Submission:
- [ ] Screenshot of the functional Robot Shop webpage on `http://<EC2-IP>:30080`.
- [ ] Screenshot of the passing GitHub Actions workflow.
- [ ] Screenshot of `kubectl get pods` showing all 12 services in a `Running` state.
