# DevOps & Cloud Infrastructure Runbook

Welcome to my central repository for DevOps operations, server automation, and cloud architecture. This document outlines my hands-on experience with cloud deployments, containerization, observability, and Linux system administration.

## 1. Cloud Architecture & Containerization

AWS Auto Scaling (ASG) & Cost Optimization
Configured dynamic scaling policies for EC2 instances behind Application Load Balancers (ALB) to handle traffic spikes automatically based on CPU utilization and memory thresholds, ensuring high availability and fault tolerance.

CloudFront + S3 (Cost Optimization)
Handled heavy outbound traffic in live food-delivery apps caused by continuous image retrieval. By implementing AWS CloudFront (CDN) in front of S3, image caching was pushed to edge locations. This reduced S3 Data Transfer Out costs by ~80% and drastically improved load times for end-users.

Docker & Container Management
- Image Optimization: Writing multi-stage Dockerfile to reduce image size and improve security.
- Orchestration: Managing multi-container local environments using docker-compose (API, Database, Message Brokers).
- Core Commands:
  docker system prune -a (Clearing dead containers/images to free up server space)
  docker exec -it <container> /bin/sh (Live debugging inside containers)
  docker logs --tail 100 -f <container> (Real-time log tracking)

## 2. Event-Driven Architecture & Message Brokers

Implemented and managed modern message brokers to facilitate asynchronous microservices communication and real-time data streaming.
- Apache Kafka: High-throughput event streaming for real-time analytics and scalable data pipelines.
- RabbitMQ: Task queuing and asynchronous message delivery (e.g., email notifications, order processing) using Exchanges and Queues.
- MQTT: Lightweight messaging protocol used for real-time, low-bandwidth device communication (IoT/Live Tracking).

## 3. Observability, Logging & Monitoring

To ensure system reliability, I configure centralized logging and visual dashboards for proactive monitoring.
- ELK Stack (Elasticsearch, Logstash, Kibana): Aggregating distributed logs from multiple microservices into a single dashboard for quick error tracing and RCA (Root Cause Analysis).
- Grafana: Building custom visual dashboards connected to time-series databases (like Prometheus) to monitor server health, CPU spikes, and API response times.

## 4. Linux System Administration & Networking

Advanced Log Parsing (grep & Text Processing)
Find all case-insensitive "ERROR" or "Exception" logs in real-time:
tail -f /var/log/app.log | grep -iE "error|exception"

Search recursively for a specific API failure inside a folder:
grep -rnw '/var/log/nginx/' -e "502 Bad Gateway"

Count the number of occurrences of an error:
grep -c "Connection Timeout" /var/log/syslog

Essential Linux Server Commands
df -h                 (Check disk space to prevent server crashes)
htop / top            (Monitor live CPU and RAM usage)
netstat -tulpn        (Check which ports are actively listening)
chmod 755 script.sh   (Modify execution permissions)
chown -R user:group   (Change ownership of application directories)

Secure Copy Protocol (SCP)
Upload configuration files to AWS EC2 securely:
scp -i key.pem local_config.yml ubuntu@server_ip:/opt/app/

Download backup dumps or logs from remote server to local machine:
scp -i key.pem -r ubuntu@server_ip:/var/log/nginx/ ./local_logs/

OpenVPN Server Setup (Ubuntu)
Securing internal database traffic and admin dashboards by routing them exclusively through a private VPN.
wget https://git.io/vpn -O openvpn-install.sh
sudo chmod +x openvpn-install.sh
sudo bash openvpn-install.sh (Selected TCP & Port 1194 during configuration)

## 5. Database Automation (Scripts inside Repo)

Instead of running manual backups, I rely on automated shell and batch scripts (available in this repository).

- db_backup.sh (Linux): Cron-automated script that dumps PostgreSQL microservice databases (auth, customer, restaurant), compresses them (-F c), and securely uploads them to AWS S3.
- db_restore.sh (Linux): Pulls the latest target backup from AWS S3 and performs a clean --if-exists database restoration.
- rds_backup.bat (Windows): A batch script utilizing Windows Task Scheduler to pull backups from remote AWS RDS instances into localized cold storage.

## 6. Amazon EKS (Kubernetes) Basics

Familiar with managing Kubernetes resources for highly available applications.

Connect to AWS EKS Cluster:
aws eks update-kubeconfig --region ap-south-1 --name production-cluster

Check running pods across all namespaces:
kubectl get pods --all-namespaces

Restart a deployment gracefully without downtime:
kubectl rollout restart deployment/backend-api -n production