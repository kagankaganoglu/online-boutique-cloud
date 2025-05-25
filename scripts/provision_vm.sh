#!/usr/bin/env bash
set -e

# 1) Create the VM with Redis + AdService
gcloud compute instances create ad-redis-vm \
  --zone=us-central1-c \
  --machine-type=e2-medium \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --tags=ad-redis-server \
  --boot-disk-size=20GB

# 2) Open firewall ports for Redis (6379) & AdService (9555)
gcloud compute firewall-rules create allow-ad-redis \
  --network=default \
  --action=ALLOW \
  --rules=tcp:6379,tcp:9555 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=ad-redis-server

# 3) SSH in once to install Docker & launch containers
gcloud compute ssh ad-redis-vm --zone=us-central1-c --command="
  sudo apt-get update &&
  sudo apt-get install -y docker.io &&
  docker run -d --name redis -p 6379:6379 redis:6.0.9 &&
  docker run -d --name adservice -p 9555:9555 gcr.io/google-samples/microservices-demo/adservice:v0.10.1
"
