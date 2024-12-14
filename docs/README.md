# gcp-infrastructure-project
Simple gcp-infrastructure-project with nginx server


## Purpose
Deploy a simple Nginx web server on a Google Cloud VM

## Technologies
- Google Cloud Platform
- Terraform
- Nginx
- Ubuntu

## Setup Instructions
1. Install Terraform
2. Configure GCP credentials
3. Run `terraform init`
4. Run `terraform apply`

## Enhanced Infrastructure Features

### Monitoring
- CPU Utilization Alerts set at 80%
- Automatic notification system for performance issues

### Auto-Scaling
- Managed Instance Group with dynamic scaling
- Minimum 1 instance, maximum 3 instances
- Scales based on CPU utilization (60% threshold)

### Security
- Firewall rules configured to allow HTTP traffic
- Nginx server deployed across multiple instances