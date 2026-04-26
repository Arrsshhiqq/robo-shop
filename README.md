# Stan's Robot Shop (Deployment Refactored)

This repository contains the source code for Stan's Robot Shop, a sample microservices application. This fork has been specifically configured for an automated deployment pipeline to a single EC2 instance running a local Kubernetes cluster (MicroK8s), managed via Terraform, Ansible, and GitHub Actions.

## Architecture & Deployment Strategy

- **Infrastructure (Terraform)**: Provisions a single AWS EC2 instance (`t3.large`) inside a public subnet.
- **Configuration (Ansible)**: Installs and configures MicroK8s, including essential add-ons (dns, ingress, hostpath-storage) on the EC2 instance.
- **CI/CD Pipeline (GitHub Actions)**: Automatically builds the Docker images for all 8 microservices upon a push to the `main` branch, pushing them to GitHub Container Registry (GHCR).
- **Deployment (ArgoCD / Kubernetes)**: Kubernetes manifests are located in `K8s/manifests/` and deployed to the MicroK8s cluster.

## Deployment Instructions

### 1. Provision Infrastructure
Configure your AWS credentials locally, then initialize and apply the Terraform configuration:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```
*Note the outputs for the `k8s_node_public_ip` and `k8s_node_private_key` after completion.*

### 2. Configure MicroK8s
Run the Ansible playbook to install MicroK8s on the new EC2 instance:

```bash
cd ansible
# Create an inventory file containing your EC2 IP
echo "[all]" > hosts
echo "<YOUR_EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/k8s_node_key.pem" >> hosts

ansible-playbook -i hosts setup-microk8s.yml
```

### 3. Deploy Kubernetes Manifests
Log into the EC2 instance and apply the K8s manifests directly, or use ArgoCD.
```bash
ssh -i terraform/k8s_node_key.pem ubuntu@<YOUR_EC2_PUBLIC_IP>
# Clone this repository on the EC2 instance or configure ArgoCD to sync the repo
kubectl apply -f K8s/manifests/
```

### 4. CI/CD (GitHub Actions)
Ensure you have the repository on GitHub.
1. The `.github/workflows/deploy.yml` workflow automatically triggers on pushes to the `main` branch.
2. It builds and pushes the images to your GitHub Container Registry.
3. *Note: Ensure you update the image tags in `K8s/manifests/` to point to your specific GHCR repository if you wish to use your newly built images.*

## Accessing the Store
Once the pods are running (`kubectl get pods -A`), the frontend (`web` service) is exposed via NodePort `30080`.
Access the application in your browser at:
`http://<YOUR_EC2_PUBLIC_IP>:30080`
